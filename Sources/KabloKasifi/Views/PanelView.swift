import SwiftUI

struct PanelView: View {
    /// ImageRenderer ScrollView içeriğini çizemediği için önizlemede kapatılır.
    var scrollable: Bool = true
    @EnvironmentObject var store: ProbeStore
    @EnvironmentObject var l10n: L10n
    /// Ölçülen içerik yüksekliği; ScrollView yalnızca gerçekten taşınca devreye girer.
    @State private var contentHeight: CGFloat = 0

    private let maxContentHeight: CGFloat = 520
    private var s: KKStrings { l10n.s }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()

            // MenuBarExtra penceresinde ScrollView'ün ideal yüksekliği sıfır sayılıyor
            // ve içerik tamamen kayboluyor. Bu yüzden içerik sığdığı sürece doğal
            // yüksekliğiyle çiziliyor; yalnızca taştığında sabit yükseklikli
            // ScrollView'e geçiliyor.
            if scrollable && contentHeight > maxContentHeight {
                ScrollView { measuredSections }
                    .frame(height: maxContentHeight)
            } else {
                measuredSections
            }

            Divider()
            footer
        }
        .frame(width: 380)
        .onAppear { store.panelAppeared() }
        .onDisappear { store.panelDisappeared() }
        .onChange(of: l10n.selection) { _, _ in store.refresh() }
    }

    // MARK: Bölümler — ilgi sırasına göre: aygıtlar, güç, ekranlar, portlar

    /// İçeriği çizerken yüksekliğini de ölçer.
    private var measuredSections: some View {
        sections
            .padding(14)
            // Esnek yükseklik önerisi geldiğinde (MenuBarExtra penceresi) içerik
            // sıfıra çökmesin; doğal yüksekliğinde kalsın.
            .fixedSize(horizontal: false, vertical: true)
            .background(
                GeometryReader { geo in
                    Color.clear.preference(key: ContentHeightKey.self, value: geo.size.height)
                }
            )
            .onPreferenceChange(ContentHeightKey.self) { height in
                if abs(height - contentHeight) > 1 { contentHeight = height }
            }
    }

    private var sections: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let failure = store.result.failure {
                noticeCard(failure)
            }
            section(s.sectionDevices, items: store.result.devices, emptyText: s.emptyDevices)
            section(s.sectionPower, items: store.result.power)
            section(s.sectionDisplays, items: store.result.displays)
            portsSection
        }
    }

    /// Boş portlar tek satırda; sadece dolu portlar kart olur.
    @ViewBuilder
    private var portsSection: some View {
        let ports = store.result.ports
        if !ports.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                sectionTitle(s.sectionPorts)

                ForEach(ports.filter { !$0.isEmptyPort }) { item in
                    ConnectionRow(item: item, isNew: store.newIDs.contains(item.stableID))
                }

                let empty = ports.filter(\.isEmptyPort)
                if !empty.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(empty) { item in
                            HStack(spacing: 8) {
                                Image(systemName: "cable.connector")
                                    .font(.system(size: 11))
                                    .foregroundStyle(.tertiary)
                                    .frame(width: 16)
                                Text(item.title)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(item.subtitle)
                                    .font(.system(size: 10.5))
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        Text(s.portEmptyNote)
                            .font(.system(size: 10))
                            .foregroundStyle(.tertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.secondary.opacity(0.06), in: RoundedRectangle(cornerRadius: 9))
                }
            }
        }
    }

    @ViewBuilder
    private func section(_ title: String, items: [Connection], emptyText: String? = nil) -> some View {
        if !items.isEmpty || emptyText != nil {
            VStack(alignment: .leading, spacing: 8) {
                sectionTitle(title)
                if items.isEmpty, let emptyText {
                    Text(emptyText)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                } else {
                    ForEach(items) { item in
                        ConnectionRow(item: item, isNew: store.newIDs.contains(item.stableID))
                    }
                }
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.secondary)
            .kerning(0.6)
    }

    private func noticeCard(_ text: String) -> some View {
        Label(text, systemImage: "exclamationmark.triangle.fill")
            .font(.system(size: 11))
            .foregroundStyle(.orange)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
    }

    // MARK: Başlık

    private var header: some View {
        HStack(spacing: 10) {
            CableGlyph(size: 30)
            VStack(alignment: .leading, spacing: 1) {
                Text("Kablo Kaşifi")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                Text(subtitleText)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                store.refresh()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .rotationEffect(.degrees(store.isScanning ? 360 : 0))
                    .animation(store.isScanning
                               ? .linear(duration: 0.9).repeatForever(autoreverses: false)
                               : .default, value: store.isScanning)
            }
            .buttonStyle(.borderless)
            .help(s.refresh)
        }
        .padding(14)
    }

    private var subtitleText: String {
        if store.isScanning && store.result.all.isEmpty { return s.scanning }
        let devices = store.result.devices.count
        var parts: [String] = []
        parts.append(devices == 0 ? s.noUSBDevices
                     : devices == 1 ? s.usbDeviceCountOne
                     : String(format: s.usbDeviceCount, devices))
        let screens = store.result.displays.count
        if screens == 1 { parts.append(s.displayCountOne) }
        else if screens > 1 { parts.append(String(format: s.displayCount, screens)) }
        return parts.joined(separator: " · ")
    }

    // MARK: Alt bar

    private var footer: some View {
        HStack(spacing: 10) {
            Toggle(s.launchAtLogin, isOn: $store.launchAtLogin)
                .toggleStyle(.checkbox)
                .font(.system(size: 11))

            Spacer()

            Menu {
                Picker("", selection: $l10n.selection) {
                    Text(String(format: s.systemLanguage, l10n.systemResolvedName))
                        .tag(L10n.systemKey)
                    Divider()
                    ForEach(AppLanguage.allCases) { lang in
                        Text("\(lang.flag)  \(lang.nativeName)").tag(lang.rawValue)
                    }
                }
                .labelsHidden()
                .pickerStyle(.inline)
            } label: {
                Image(systemName: "globe")
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .frame(width: 26)
            .help(s.language)

            Button(s.quit) { NSApp.terminate(nil) }
                .buttonStyle(.plain)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

/// İçerik yüksekliğini yukarı taşıyan tercih anahtarı.
private struct ContentHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct ConnectionRow: View {
    let item: Connection
    var isNew: Bool = false
    @EnvironmentObject var l10n: L10n

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: item.symbol)
                    .font(.system(size: 13))
                    .foregroundStyle(item.isEmptyPort ? .secondary : .primary)
                    .frame(width: 18)

                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 6) {
                        Text(item.title)
                            .font(.system(size: 12.5, weight: .semibold))
                            .lineLimit(1)
                        if isNew {
                            Text(l10n.s.badgeNew)
                                .font(.system(size: 8, weight: .bold))
                                .padding(.horizontal, 4).padding(.vertical, 1)
                                .background(Color.green.opacity(0.25), in: Capsule())
                        }
                    }
                    if !item.subtitle.isEmpty {
                        Text(item.subtitle)
                            .font(.system(size: 10.5))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                Spacer(minLength: 4)
                if let badge = item.badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .monospacedDigit()
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(badgeColor.opacity(0.18), in: Capsule())
                        .foregroundStyle(badgeColor)
                }
            }

            ForEach(item.verdicts) { v in
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: v.level.symbol)
                        .font(.system(size: 9))
                        .foregroundStyle(color(for: v.level))
                        .padding(.top, 2)
                    Text(v.text)
                        .font(.system(size: 11))
                        .foregroundStyle(v.level == .warn ? .primary : .secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background, in: RoundedRectangle(cornerRadius: 9))
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .strokeBorder(item.worstLevel == .warn ? Color.orange.opacity(0.35) : Color.clear, lineWidth: 1)
        )
    }

    private var background: Color {
        item.worstLevel == .warn ? Color.orange.opacity(0.10) : Color.secondary.opacity(0.08)
    }

    private var badgeColor: Color {
        guard let g = item.gbps else { return .secondary }
        if g >= 40 { return .purple }
        if g >= 10 { return .blue }
        if g >= 5 { return .teal }
        return .orange
    }

    private func color(for level: VerdictLevel) -> Color {
        switch level {
        case .good: return .green
        case .info: return .secondary
        case .warn: return .orange
        }
    }
}

/// Basit USB-C kablo simgesi (kodla çizilmiş).
struct CableGlyph: View {
    var size: CGFloat = 28

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(LinearGradient(colors: [Color(red: 0.25, green: 0.55, blue: 0.95),
                                              Color(red: 0.13, green: 0.32, blue: 0.70)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
            Capsule()
                .fill(Color.white.opacity(0.95))
                .frame(width: size * 0.52, height: size * 0.22)
            Capsule()
                .fill(Color.white.opacity(0.45))
                .frame(width: size * 0.16, height: size * 0.5)
                .offset(y: size * 0.28)
        }
        .frame(width: size, height: size)
    }
}
