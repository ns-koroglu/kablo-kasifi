import Foundation

/// Bir bulgunun tonu.
enum VerdictLevel: Int, Sendable, Comparable {
    case good = 0, info = 1, warn = 2

    static func < (l: VerdictLevel, r: VerdictLevel) -> Bool { l.rawValue < r.rawValue }

    var symbol: String {
        switch self {
        case .good: return "checkmark.circle.fill"
        case .info: return "info.circle.fill"
        case .warn: return "exclamationmark.triangle.fill"
        }
    }
}

/// Düz Türkçe tek cümlelik yorum.
struct Verdict: Identifiable, Sendable {
    var id = UUID()
    var level: VerdictLevel
    var text: String
}

/// Satırın işlevi — arayüz metninden bağımsız, dile duyarsız.
/// (Menü çubuğu rozetini başlık metniyle eşleştirmek 10 dilin 9'unda kırılıyordu.)
enum ConnectionRole: String, Sendable {
    case port, charge, battery, usbDevice, display
}

enum LinkKind: String, Sendable {
    case port, power, usb, display, network, audio

    var icon: String {
        switch self {
        case .port: return "cable.connector"
        case .power: return "bolt.fill"
        case .usb: return "externaldrive.connected.to.line.below"
        case .display: return "display"
        case .network: return "network"
        case .audio: return "hifispeaker"
        }
    }
}

/// Panelde tek bir satır: port, aygıt, ekran ya da şarj.
struct Connection: Identifiable, Sendable {
    var id = UUID()
    var kind: LinkKind
    /// İşlevsel rol (dile bağlı değil)
    var role: ConnectionRole = .usbDevice
    /// Dile ve çeviriye bağlı olmayan kalıcı kimlik ("YENİ" rozeti bunu kullanır)
    var stableID: String = ""
    var title: String
    var subtitle: String = ""
    /// "40 Gb/s", "35 W" gibi kısa rozet
    var badge: String?
    /// Gb/s cinsinden bağlantı hızı (bilinmiyorsa nil)
    var gbps: Double?
    var verdicts: [Verdict] = []
    var isEmptyPort: Bool = false
    /// Hub ağacındaki derinlik (0 = doğrudan porta bağlı)
    var indent: Int = 0
    /// Satıra özel SF Symbol (yoksa türün simgesi kullanılır)
    var icon: String?

    var symbol: String { icon ?? kind.icon }

    var worstLevel: VerdictLevel { verdicts.map(\.level).max() ?? .good }
}

struct ProbeResult: Sendable {
    var ports: [Connection] = []
    var power: [Connection] = []
    var devices: [Connection] = []
    var displays: [Connection] = []
    var scannedAt = Date()
    var failure: String?

    var all: [Connection] { ports + power + devices + displays }

    /// Menü çubuğu için şarj satırı — metin eşleşmesi yok.
    var charger: Connection? { power.first { $0.role == .charge } }
    var connectedCount: Int { devices.count + displays.count + ports.filter { !$0.isEmptyPort }.count }
}
