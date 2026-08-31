import SwiftUI
import ServiceManagement

@MainActor
final class ProbeStore: ObservableObject {
    static let shared = ProbeStore()

    @Published private(set) var result = ProbeResult()
    @Published private(set) var isScanning = false
    @Published private(set) var newTitles: Set<String> = []
    @Published var launchAtLogin: Bool {
        didSet {
            guard launchAtLogin != oldValue else { return }
            do {
                if launchAtLogin { try SMAppService.mainApp.register() }
                else { try SMAppService.mainApp.unregister() }
            } catch { NSLog("Girişte başlatma ayarlanamadı: \(error.localizedDescription)") }
        }
    }

    private var timer: Timer?
    private var knownTitles: Set<String> = []

    private init() {
        launchAtLogin = (SMAppService.mainApp.status == .enabled)
    }

    func refresh() {
        guard !isScanning else { return }
        isScanning = true
        Task.detached(priority: .userInitiated) {
            let fresh = SystemProbe.probe()
            await MainActor.run { self.apply(fresh) }
        }
    }

    private func apply(_ fresh: ProbeResult) {
        let titles = Set(fresh.devices.map(\.title) + fresh.displays.map(\.title)
                         + fresh.ports.filter { !$0.isEmptyPort }.map(\.title))
        newTitles = knownTitles.isEmpty ? [] : titles.subtracting(knownTitles)
        knownTitles = titles
        result = fresh
        isScanning = false
    }

    /// Önizleme/CLI için eşzamanlı tarama.
    func refreshSynchronously() {
        let fresh = SystemProbe.probe()
        apply(fresh)
    }

    /// Panel açıkken canlı takip.
    func startWatching(interval: TimeInterval = 4) {
        stopWatching()
        refresh()
        let t = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.refresh() }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stopWatching() {
        timer?.invalidate()
        timer = nil
    }

    /// Menü çubuğunda gösterilecek kısa özet (şarj watt'ı ya da bağlı aygıt sayısı).
    var menuBarText: String? {
        if let adapter = result.power.first(where: { $0.title == "Şarj" }), adapter.badge != nil {
            return adapter.badge
        }
        let count = result.devices.count
        return count > 0 ? "\(count)" : nil
    }
}
