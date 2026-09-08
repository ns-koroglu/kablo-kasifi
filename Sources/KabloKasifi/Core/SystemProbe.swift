import Foundation
import CoreGraphics
import AppKit

/// Sistemden ham veriyi toplar ve düz Türkçe yorumlara çevirir.
///
/// Sürüm dayanıklılığı: USB, güç ve ekran bilgisi doğrudan native API'lerden
/// (IOKit, CoreGraphics) okunur — bunlar macOS sürümleri arasında değişmiyor.
/// `system_profiler` yalnızca Thunderbolt için kullanılır ve veri tipi adı
/// çalışma anında keşfedilir; bulunamazsa bölüm sessizce boş kalmaz, uyarı basılır.
/// (macOS 26'da `SPUSBDataType` → `SPUSBHostDataType` değişikliği tam olarak
/// böyle bir sessiz boşluğa yol açmıştı.)
enum SystemProbe {

    // MARK: - Giriş

    static func probe() -> ProbeResult {
        var result = ProbeResult()
        let usb = USBProbe.devices()
        result.devices = usbRows(usb)
        result.power = powerRows()
        result.displays = displayRows()
        let (ports, warning) = thunderboltRows()
        result.ports = ports
        result.failure = warning
        return result
    }

    // MARK: - USB (IOKit)

    private static func usbRows(_ devices: [USBDeviceInfo]) -> [Connection] {
        devices.map { device in
            let gbps = device.linkGbps
            var c = Connection(kind: .usb,
                               title: device.name,
                               subtitle: subtitle(for: device, in: devices),
                               badge: badge(for: gbps),
                               gbps: gbps)
            c.icon = device.isHub ? "point.3.connected.trianglepath.dotted" : nil
            c.verdicts = verdicts(for: device, in: devices)
            return c
        }
    }

    private static func subtitle(for device: USBDeviceInfo, in all: [USBDeviceInfo]) -> String {
        var parts: [String] = []
        if !device.vendor.isEmpty { parts.append(device.vendor) }
        parts.append(device.usbVersionText + " aygıtı")
        if let parent = USBProbe.parent(of: device, in: all) {
            parts.append("\(parent.name) üzerinden")
        }
        return parts.joined(separator: " · ")
    }

    private static func verdicts(for device: USBDeviceInfo, in all: [USBDeviceInfo]) -> [Verdict] {
        var out: [Verdict] = []
        let link = device.linkGbps ?? 0
        let capability = device.capabilityGbps ?? 0
        let parent = USBProbe.parent(of: device, in: all)

        if device.isHub {
            out.append(Verdict(level: link >= 5 ? .good : .info,
                               text: link >= 5
                                   ? "Hub \(speedText(link)) hızında bağlı; altındaki aygıtlar bu bant genişliğini paylaşır."
                                   : "Hub USB 2.0 hızında (480 Mb/s) bağlı; altına taktığın her aygıt bu hızla sınırlanır."))
            return out
        }

        if link >= 5 {
            out.append(Verdict(level: .good,
                               text: "\(speedText(link)) hızında bağlı — aygıt, kablo ve port tam kapasite çalışıyor."))
        } else if capability <= 0.48 {
            // Suçlu kablo değil, aygıtın kendisi
            out.append(Verdict(level: .info,
                               text: "Aygıtın kendisi \(device.usbVersionText) — 480 Mb/s onun tavanı. Kablo veya port suçlu değil."))
        } else if let parent, (parent.linkGbps ?? 0) < 5 {
            out.append(Verdict(level: .warn,
                               text: "Aygıt USB 3.x destekliyor ama 480 Mb/s'de bağlı. Sınırlayan, üstündeki \(parent.name) (USB 2.0 hızında)."))
        } else {
            out.append(Verdict(level: .warn,
                               text: "Aygıt USB 3.x destekliyor ama yalnızca 480 Mb/s'de bağlanmış. Kablo büyük ihtimalle sadece şarj/USB 2.0 kablosu — veri kablosuyla 10 kat hızlanır."))
        }
        return out
    }

    private static func speedText(_ gbps: Double) -> String {
        if gbps >= 40 { return "40 Gb/s (USB4/Thunderbolt)" }
        if gbps >= 20 { return "20 Gb/s (USB 3.2 Gen 2x2)" }
        if gbps >= 10 { return "10 Gb/s (USB 3.2 Gen 2)" }
        if gbps >= 5 { return "5 Gb/s (USB 3.0)" }
        if gbps >= 0.48 { return "480 Mb/s (USB 2.0)" }
        return "\(Int(gbps * 1000)) Mb/s"
    }

    static func badge(for gbps: Double?) -> String? {
        guard let g = gbps, g > 0 else { return nil }
        if g < 1 { return "\(Int(g * 1000)) Mb/s" }
        return "\(Int(g)) Gb/s"
    }

    // MARK: - Güç (IOKit)

    private static func powerRows() -> [Connection] {
        var out: [Connection] = []
        let battery = PowerProbe.battery()

        var charge = Connection(kind: .power, title: "Şarj", icon: "bolt.fill")
        if let adapter = PowerProbe.adapter() {
            charge.subtitle = adapter.name ?? adapter.description ?? "Güç adaptörü"
            let negotiated = adapter.negotiatedWatts
            charge.badge = negotiated.map { "\(Int($0.rounded())) W" }
                ?? adapter.watts.map { "\($0) W" }

            if let label = adapter.labelWatts, let neg = negotiated {
                let negText = String(format: "%.0f", neg)
                let ratio = neg / Double(label)
                if ratio >= 0.88 {
                    charge.verdicts.append(Verdict(level: .good,
                        text: "\(label) W adaptör tam güçte veriyor (\(negText) W anlaşıldı). Kablo bu gücü sorunsuz taşıyor."))
                } else if battery.percent ?? 0 >= 90 || !battery.isCharging {
                    charge.verdicts.append(Verdict(level: .info,
                        text: "Şu an \(negText) W çekiliyor. Pil %\(battery.percent ?? 0) seviyesinde olduğu için Mac az güç istiyor; bu normal."))
                } else {
                    charge.verdicts.append(Verdict(level: .warn,
                        text: "Adaptör \(label) W ama yalnızca \(negText) W geliyor. Kablo düşük güçlü (60 W sınırlı) olabilir ya da tam oturmamış olabilir."))
                }
            }
            if let v = adapter.voltage, let a = adapter.current {
                charge.verdicts.append(Verdict(level: .info,
                    text: String(format: "Anlaşılan profil: %.0f V · %.2f A.", v, a)))
            }
            if adapter.profiles.count > 1 {
                let list = adapter.profiles
                    .map { String(format: "%.0fV/%.1fA", $0.volts, $0.amps) }
                    .joined(separator: " · ")
                charge.verdicts.append(Verdict(level: .info, text: "Adaptörün sunduğu profiller: \(list)."))
            }
        } else {
            charge.subtitle = "Adaptör bağlı değil"
            charge.verdicts.append(Verdict(level: .info,
                text: "Şarj kablosu takılı değil. Taktığında adaptörün kaç watt verdiğini ve kablonun bunu sınırlayıp sınırlamadığını buradan göreceksin."))
        }
        out.append(charge)

        if let percent = battery.percent {
            var b = Connection(kind: .power, title: "Pil", badge: "%\(percent)",
                               icon: batteryIcon(percent: percent, charging: battery.isCharging))
            var parts: [String] = []
            if let health = spBatteryHealthText() ?? battery.rawHealthPercent.map({ "%\($0)" }) {
                parts.append("azami kapasite \(health)")
            }
            if let cycles = battery.cycleCount { parts.append("\(cycles) döngü") }
            b.subtitle = parts.joined(separator: " · ")

            if battery.isCharging {
                if let minutes = battery.timeRemainingMinutes, minutes > 0, minutes < 60 * 12 {
                    b.verdicts.append(Verdict(level: .good, text: "Şarj oluyor — tam dolmasına yaklaşık \(minutes) dakika."))
                } else {
                    b.verdicts.append(Verdict(level: .good, text: "Şarj oluyor."))
                }
            } else if battery.externalConnected {
                b.verdicts.append(Verdict(level: .info, text: "Adaptör bağlı ama şu an şarj etmiyor (pil yeterince dolu)."))
            }
            if let raw = battery.rawHealthPercent {
                b.verdicts.append(Verdict(level: raw >= 80 ? .good : .warn,
                    text: raw >= 80 ? "Pil sağlığı iyi durumda." : "Pil kapasitesi tasarım değerinin %\(raw)'ine düşmüş; değişim zamanı yaklaşmış olabilir."))
            }
            out.append(b)
        }
        return out
    }

    private static func batteryIcon(percent: Int, charging: Bool) -> String {
        if charging { return "battery.100percent.bolt" }
        switch percent {
        case ..<15: return "battery.0percent"
        case ..<40: return "battery.25percent"
        case ..<65: return "battery.50percent"
        case ..<90: return "battery.75percent"
        default: return "battery.100percent"
        }
    }

    /// Sistem Ayarları'ndaki "azami kapasite" değeri (varsa) — ham orandan farklı olabilir.
    private static func spBatteryHealthText() -> String? {
        guard let items = profilerItems(["SPPowerDataType"]).items else { return nil }
        for item in items where (item["_name"] as? String) == "spbattery_information" {
            if let health = item["sppower_battery_health_info"] as? [String: Any],
               let maxCap = health["sppower_battery_health_maximum_capacity"] as? String {
                return maxCap
            }
        }
        return nil
    }

    // MARK: - Ekranlar (CoreGraphics)

    private static func displayRows() -> [Connection] {
        var count: UInt32 = 0
        guard CGGetOnlineDisplayList(0, nil, &count) == .success, count > 0 else { return [] }
        var ids = [CGDirectDisplayID](repeating: 0, count: Int(count))
        guard CGGetOnlineDisplayList(count, &ids, &count) == .success else { return [] }

        var out: [Connection] = []
        for id in ids.prefix(Int(count)) where CGDisplayIsBuiltin(id) == 0 {
            let mode = CGDisplayCopyDisplayMode(id)
            let width = mode?.pixelWidth ?? 0
            let height = mode?.pixelHeight ?? 0
            let refresh = mode?.refreshRate ?? 0
            let name = screenName(for: id) ?? "Harici ekran"

            var resolution = "\(width) × \(height)"
            if refresh > 0 { resolution += String(format: " @ %.0f Hz", refresh) }

            var c = Connection(kind: .display, title: name, subtitle: resolution, badge: "video")
            c.verdicts.append(Verdict(level: .good,
                text: "Bu kablo görüntü taşıyor: \(resolution)."))
            if CGDisplayIsAsleep(id) != 0 {
                c.verdicts.append(Verdict(level: .info, text: "Ekran şu an uykuda."))
            }
            out.append(c)
        }
        return out
    }

    private static func screenName(for id: CGDirectDisplayID) -> String? {
        for screen in NSScreen.screens {
            if let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber,
               number.uint32Value == id {
                return screen.localizedName
            }
        }
        return nil
    }

    // MARK: - Thunderbolt (system_profiler, tip adı çalışma anında bulunur)

    private static func thunderboltRows() -> ([Connection], String?) {
        let found = profilerItems(["SPThunderboltDataType", "SPThunderboltHostDataType"])
        guard let buses = found.items else {
            return ([], "Bu macOS sürümünde Thunderbolt port verisi okunamadı (beklenen system_profiler veri tipi yok). USB aygıtları ve güç bilgisi etkilenmez.")
        }

        var out: [Connection] = []
        for bus in buses {
            let receptacles = bus.filter { $0.key.hasPrefix("receptacle_") }
                .compactMap { $0.value as? [String: Any] }
            let connectedDevices = (bus["_items"] as? [[String: Any]]) ?? []

            for rec in receptacles {
                let idText = (rec["receptacle_id_key"] as? String) ?? "?"
                let status = (rec["receptacle_status_key"] as? String) ?? ""
                let speed = speedFromText(rec["current_speed_key"] as? String)
                let isEmpty = status.contains("no_devices_connected")

                var c = Connection(kind: .port,
                                   title: "Port \(idText)",
                                   subtitle: isEmpty
                                        ? "Thunderbolt aygıtı yok · \(badge(for: speed) ?? "40 Gb/s") hıza kadar"
                                        : "Aygıt bağlı",
                                   badge: isEmpty ? nil : badge(for: speed),
                                   gbps: isEmpty ? nil : speed,
                                   isEmptyPort: isEmpty)
                if isEmpty {
                    c.verdicts = [Verdict(level: .info,
                        text: "Bu portta Thunderbolt/USB4 aygıtı yok. Normal USB aygıtları ve hub'lar aşağıdaki \"Bağlı aygıtlar\" bölümünde listelenir.")]
                } else if let g = speed, g >= 40 {
                    c.verdicts = [Verdict(level: .good,
                        text: "40 Gb/s bağlantı kuruldu — kablon tam hızlı Thunderbolt/USB4 kablosu.")]
                } else {
                    c.verdicts = [Verdict(level: .warn,
                        text: "Bağlantı \(speed.map { speedText($0) } ?? "düşük hızda"). Kablo pasif ya da düşük hızlı olabilir.")]
                }
                out.append(c)
            }

            for device in connectedDevices {
                let name = (device["device_name_key"] as? String) ?? "Thunderbolt aygıtı"
                let vendor = (device["vendor_name_key"] as? String) ?? ""
                let speed = speedFromText(device["current_speed_key"] as? String)
                var c = Connection(kind: .port, title: name,
                                   subtitle: vendor.isEmpty ? "Thunderbolt aygıtı" : vendor,
                                   badge: badge(for: speed), gbps: speed)
                c.verdicts.append(Verdict(level: (speed ?? 0) >= 40 ? .good : .info,
                    text: "Thunderbolt bağlantısı: \(speed.map { speedText($0) } ?? "hız okunamadı")."))
                out.append(c)
            }
        }
        return (out.sorted { $0.title < $1.title }, nil)
    }

    /// "Up to 40 Gb/s" → 40
    static func speedFromText(_ raw: String?) -> Double? {
        guard let s = raw?.lowercased() else { return nil }
        if s.contains("80") { return 80 }
        if s.contains("40") { return 40 }
        if s.contains("20") { return 20 }
        if s.contains("10") { return 10 }
        if s.contains("5") { return 5 }
        if s.contains("480") { return 0.48 }
        return nil
    }

    // MARK: - system_profiler yardımcıları

    /// Sistemde tanımlı veri tipleri (bir kez okunur).
    static let availableDataTypes: Set<String> = {
        guard let out = run("/usr/sbin/system_profiler", ["-listDataTypes"]) else { return [] }
        return Set(String(decoding: out, as: UTF8.self)
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { $0.hasPrefix("SP") })
    }()

    /// Adaylardan sistemde var olan ilk veri tipini okur.
    static func profilerItems(_ candidates: [String]) -> (items: [[String: Any]]?, usedType: String?) {
        guard let type = candidates.first(where: { availableDataTypes.contains($0) }) else {
            return (nil, nil)
        }
        guard let out = run("/usr/sbin/system_profiler", ["-json", type]),
              let json = (try? JSONSerialization.jsonObject(with: out)) as? [String: Any],
              let items = json[type] as? [[String: Any]] else {
            return (nil, type)
        }
        return (items, type)
    }

    private static func run(_ path: String, _ args: [String]) -> Data? {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: path)
        p.arguments = args
        let pipe = Pipe()
        p.standardOutput = pipe
        p.standardError = FileHandle.nullDevice
        do { try p.run() } catch { return nil }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        p.waitUntilExit()
        return data
    }

    // MARK: - Tanılama

    /// Hangi veri kaynağı çalışıyor? (--doctor)
    static func doctor() -> String {
        let usb = USBProbe.devices()
        let adapter = PowerProbe.adapter()
        let tb = profilerItems(["SPThunderboltDataType", "SPThunderboltHostDataType"])
        var lines: [String] = []
        lines.append("macOS: \(ProcessInfo.processInfo.operatingSystemVersionString)")
        lines.append("USB (IOKit)            : \(usb.count) aygıt")
        lines.append("Güç (IOKit)            : \(adapter == nil ? "adaptör bağlı değil" : (adapter?.name ?? "bağlı"))")
        lines.append("Pil (IOKit)            : %\(PowerProbe.battery().percent.map(String.init) ?? "-")")
        lines.append("Ekran (CoreGraphics)   : \(displayRows().count) harici")
        lines.append("Thunderbolt            : \(tb.usedType ?? "VERİ TİPİ YOK") → \(tb.items?.count ?? 0) veri yolu")
        lines.append("system_profiler tipleri: \(availableDataTypes.count) adet")
        for t in ["SPUSBDataType", "SPUSBHostDataType", "SPThunderboltDataType", "SPPowerDataType", "SPDisplaysDataType"] {
            lines.append("  \(availableDataTypes.contains(t) ? "✓" : "✗") \(t)")
        }
        return lines.joined(separator: "\n")
    }
}
