import SwiftUI

struct PanelView: View {
    /// ImageRenderer ScrollView içeriğini çizemediği için önizlemede kapatılır.
    var scrollable: Bool = true
    @EnvironmentObject var store: ProbeStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()

            if scrollable {
                ScrollView { sections.padding(14) }
                    .frame(maxHeight: 460)
            } else {
                sections.padding(14)
            }

            Divider()
            footer
        }
        .frame(width: 380)
        .onAppear { store.startWatching() }
        .onDisappear { store.stopWatching() }
    }

    private var sections: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let failure = store.result.failure {
                noticeCard(failure, level: .warn)
            }
            section("Portlar", items: store.result.ports)
            section("Güç", items: store.result.power)
            section("Bağlı aygıtlar", items: store.result.devices,
                    emptyText: "Şu an USB aygıtı yok. Bir kablo tak, ne taşıdığını anlatayım.")
            section("Ekranlar", items: store.result.displays)
        }
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
            .help("Yeniden tara")
        }
        .padding(14)
    }

    private var subtitleText: String {
        if store.isScanning && store.result.all.isEmpty { return "Taranıyor…" }
        let d = store.result.devices.count
        let s = store.result.displays.count
        var parts: [String] = []
        parts.append(d == 0 ? "USB aygıtı yok" : "\(d) USB aygıtı")
        if s > 0 { parts.append("\(s) ekran") }
        return parts.joined(separator: " · ")
    }

    // MARK: Bölümler

    @ViewBuilder
    private func section(_ title: String, items: [Connection], emptyText: String? = nil) -> some View {
        if !items.isEmpty || emptyText != nil {
            VStack(alignment: .leading, spacing: 8) {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .kerning(0.6)

                if items.isEmpty, let emptyText {
                    Text(emptyText)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
                } else {
                    ForEach(items) { item in
                        ConnectionRow(item: item, isNew: store.newTitles.contains(item.title))
                    }
                }
            }
        }
    }

    private func noticeCard(_ text: String, level: VerdictLevel) -> some View {
        Label(text, systemImage: level.symbol)
            .font(.system(size: 11))
            .foregroundStyle(.orange)
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
    }

    // MARK: Alt bar

    private var footer: some View {
        HStack {
            Toggle("Girişte başlat", isOn: $store.launchAtLogin)
                .toggleStyle(.checkbox)
                .font(.system(size: 11))
            Spacer()
            Button("Çıkış") { NSApp.terminate(nil) }
                .buttonStyle(.plain)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}

struct ConnectionRow: View {
    let item: Connection
    var isNew: Bool = false

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
                            Text("YENİ")
                                .font(.system(size: 8, weight: .bold))
                                .padding(.horizontal, 4).padding(.vertical, 1)
                                .background(Color.green.opacity(0.25), in: Capsule())
                        }
                    }
                    if !item.subtitle.isEmpty {
                        Text(item.subtitle)
                            .font(.system(size: 10.5))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
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
        .opacity(item.isEmptyPort ? 0.72 : 1)
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
