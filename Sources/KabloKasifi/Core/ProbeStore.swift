import SwiftUI
import ServiceManagement

@MainActor
final class ProbeStore: ObservableObject {
    static let shared = ProbeStore()

    @Published private(set) var result = ProbeResult()
    @Published private(set) var isScanning = false
    /// "YENİ" rozeti — dile bağlı olmayan kararlı kimlikler
    @Published private(set) var newIDs: Set<String> = []

    /// Menü çubuğundaki watt: IOKit'ten anında okunur, tam taramayı beklemez.
    @Published private(set) var liveWatts: Int?
    @Published private(set) var isCharging = false

    @Published var launchAtLogin: Bool {
        didSet {
            guard launchAtLogin != oldValue else { return }
            do {
                if launchAtLogin { try SMAppService.mainApp.register() }
                else { try SMAppService.mainApp.unregister() }
            } catch { NSLog("Girişte başlatma ayarlanamadı: \(error.localizedDescription)") }
        }
    }

    private var monitor: LiveMonitor?
    private var backstopTimer: Timer?
    private var pendingFullScan: DispatchWorkItem?
    private var knownIDs: Set<String> = []
    private var panelOpen = false
    private var needsScanWhenPanelOpens = true

    private init() {
        launchAtLogin = (SMAppService.mainApp.status == .enabled)
    }

    // MARK: - Canlı izleme (uygulama açık olduğu sürece)

    /// Uygulama açılışında bir kez çağrılır. Yoklama yok: IOKit bildirimleri.
    func startLiveMonitoring() {
        guard monitor == nil else { return }
        let monitor = LiveMonitor { [weak self] trigger in
            MainActor.assumeIsolated { self?.handle(trigger) }
        }
        self.monitor = monitor
        monitor.start()
        refreshPowerFast()
        refresh()
    }

    private func handle(_ trigger: LiveMonitor.Trigger) {
        // Watt/pil her olayda anında güncellensin (saf IOKit, alt süreç yok).
        refreshPowerFast()
        // Ağır tarama yalnızca panel açıkken: kapalıyken görünen tek şey menü
        // çubuğundaki watt ve o zaten hızlı yoldan geliyor. (Aksi hâlde her
        // tak/çıkarda iki system_profiler alt süreci açılıyordu.)
        guard panelOpen else { needsScanWhenPanelOpens = true; return }
        // Tak/çıkarda IOKit art arda birkaç bildirim gönderiyor; kısa gecikme.
        scheduleFullScan(after: trigger == .power ? 0.4 : 0.25)
    }

    private func scheduleFullScan(after delay: TimeInterval) {
        pendingFullScan?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.refresh() }
        pendingFullScan = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    }

    /// Yalnızca güç: IOKit okuması, ölçülen maliyet ~1 ms.
    func refreshPowerFast() {
        let adapter = PowerProbe.adapter()
        let battery = PowerProbe.battery()
        isCharging = battery.isCharging
        liveWatts = adapter?.negotiatedWatts.map { Int($0.rounded()) } ?? adapter?.watts
    }

    // MARK: - Tam tarama

    func refresh() {
        guard !isScanning else { return }
        isScanning = true
        let strings = L10n.shared.s
        let names = SystemProbe.currentDisplayNames()   // NSScreen yalnızca ana aktörde
        Task.detached(priority: .userInitiated) {
            let fresh = SystemProbe.probe(strings, displayNames: names)
            await MainActor.run { self.apply(fresh) }
        }
    }

    func refreshSynchronously() {
        apply(SystemProbe.probe(L10n.shared.s, displayNames: SystemProbe.currentDisplayNames()))
    }

    private func apply(_ fresh: ProbeResult) {
        let ids = Set(fresh.devices.map(\.stableID)
                      + fresh.displays.map(\.stableID)
                      + fresh.ports.filter { !$0.isEmptyPort }.map(\.stableID))
        // "YENİ" rozeti biriktirilir: eskiden her taramada sıfırlandığı için
        // kullanıcı paneli açtığında rozet çoktan kaybolmuş oluyordu.
        if !knownIDs.isEmpty {
            newIDs.formUnion(ids.subtracting(knownIDs))
        }
        newIDs.formIntersection(ids)   // çıkarılan aygıtın rozeti kalmasın
        knownIDs = ids
        result = fresh
        isScanning = false
        if let charger = fresh.charger, charger.role == .charge {
            // Tam tarama da watt'ı tazelesin (bildirim kaçarsa diye).
            refreshPowerFast()
        }
    }

    // MARK: - Panel yaşam döngüsü

    /// Panel açıkken yavaş bir emniyet zamanlayıcısı: bildirimle yakalanmayan
    /// değişiklikler (ör. Thunderbolt bağlantı hızı) için. Eskiden 4 sn'de bir
    /// tam tarama yapılıyordu; bu iki `system_profiler` alt süreci demekti.
    func panelAppeared() {
        panelOpen = true
        refreshPowerFast()
        if needsScanWhenPanelOpens || result.all.isEmpty {
            needsScanWhenPanelOpens = false
            refresh()
        }
        backstopTimer?.invalidate()
        let t = Timer(timeInterval: 15, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.refresh() }
        }
        RunLoop.main.add(t, forMode: .common)
        backstopTimer = t
    }

    func panelDisappeared() {
        panelOpen = false
        backstopTimer?.invalidate()
        backstopTimer = nil
        // Kullanıcı gördü; rozetler bir sonraki değişikliğe kadar temizlensin.
        newIDs.removeAll()
    }

    /// Menü çubuğunda gösterilecek kısa özet.
    var menuBarText: String? {
        if let watts = liveWatts, watts > 0 { return "\(watts) W" }
        let count = result.devices.count
        // Çıplak "3" watt sanılabiliyordu; aygıt sayısı olduğu belli olsun.
        return count > 0 ? "×\(count)" : nil
    }
}
