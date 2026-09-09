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

    static func probe(_ s: KKStrings) -> ProbeResult {
        var result = ProbeResult()
        let usb = USBProbe.devices(fallbackName: s.usbDeviceFallback)
        result.devices = usbRows(usb, s)
        result.power = powerRows(s)
        result.displays = displayRows(s)
        let (ports, warning) = thunderboltRows(s)
        result.ports = ports
        result.failure = warning
        return result
    }

    // MARK: - USB (IOKit)

    private static func usbRows(_ devices: [USBDeviceInfo], _ s: KKStrings) -> [Connection] {
        devices.map { device in
            let gbps = device.linkGbps
            var c = Connection(kind: .usb,
                               role: .usbDevice,
                               stableID: "usb:\(device.locationID)",
                               title: device.name,
                               subtitle: subtitle(for: device, in: devices, s),
                               badge: badge(for: gbps),
                               gbps: gbps)
            c.icon = device.isHub ? "point.3.connected.trianglepath.dotted" : nil
            c.verdicts = verdicts(for: device, in: devices, s)
            return c
        }
    }

    private static func subtitle(for device: USBDeviceInfo, in all: [USBDeviceInfo], _ s: KKStrings) -> String {
        var parts: [String] = []
        if !device.vendor.isEmpty { parts.append(device.vendor) }
        parts.append(String(format: s.deviceVersionSuffix, device.usbVersionText))
        if let parent = USBProbe.parent(of: device, in: all) {
            parts.append(String(format: s.viaParent, parent.name))
        }
        return parts.joined(separator: " · ")
    }

    private static func verdicts(for device: USBDeviceInfo, in all: [USBDeviceInfo], _ s: KKStrings) -> [Verdict] {
        var out: [Verdict] = []
        guard let link = device.linkGbps else {
            // Hız okunamadıysa kimseyi suçlama.
            return [Verdict(level: .info, text: s.linkSpeedUnknown)]
        }
        let capability = device.capabilityGbps ?? 0
        let parent = USBProbe.parent(of: device, in: all)

        if device.isHub {
            out.append(Verdict(level: link >= 5 ? .good : .info,
                               text: link >= 5
                                   ? String(format: s.hubFast, speedText(link))
                                   : s.hubSlow))
            return out
        }

        if link >= 5 {
            out.append(Verdict(level: .good, text: String(format: s.deviceFast, speedText(link))))
        } else if capability <= 0.48 {
            // Suçlu kablo değil, aygıtın kendisi
            out.append(Verdict(level: .info, text: String(format: s.deviceOwnLimit, device.usbVersionText)))
        } else if let parent, (parent.linkGbps ?? 0) < 5 {
            out.append(Verdict(level: .warn, text: String(format: s.deviceHubLimit, parent.name)))
        } else {
            out.append(Verdict(level: .warn, text: s.deviceCableLimit))
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

    /// Yüzdeyi seçili dilin yazımına göre biçimler (tr: %98, en: 98%)
    static func percentText(_ value: Int, _ s: KKStrings) -> String {
        String(format: s.percentFormat, value)
    }

    /// system_profiler'ın yerelleştirilmiş "%98" / "98%" metninden sayıyı çıkarır.
    static func percentValue(from text: String) -> Int? {
        let digits = text.filter(\.isNumber)
        return Int(digits)
    }

    static func badge(for gbps: Double?) -> String? {
        guard let g = gbps, g > 0 else { return nil }
        if g < 1 { return "\(Int(g * 1000)) Mb/s" }
        return "\(Int(g)) Gb/s"
    }

    // MARK: - Güç (IOKit)

    private static func powerRows(_ s: KKStrings) -> [Connection] {
        var out: [Connection] = []
        let battery = PowerProbe.battery()

        var charge = Connection(kind: .power, role: .charge, stableID: "power:charger",
                                title: s.charge, icon: "bolt.fill")
        if let adapter = PowerProbe.adapter() {
            charge.subtitle = adapter.name ?? adapter.description ?? s.powerAdapterFallback
            let negotiated = adapter.negotiatedWatts
            charge.badge = negotiated.map { "\(Int($0.rounded())) W" }
                ?? adapter.watts.map { "\($0) W" }

            if let label = adapter.labelWatts, let neg = negotiated {
                let negText = String(format: "%.0f", neg)
                let ratio = neg / Double(label)
                if ratio >= 0.88 {
                    charge.verdicts.append(Verdict(level: .good,
                        text: String(format: s.adapterFullPower, label, negText)))
                } else if battery.percent ?? 0 >= 90 || !battery.isCharging {
                    charge.verdicts.append(Verdict(level: .info,
                        text: String(format: s.adapterBatteryFull, negText, battery.percent ?? 0)))
                } else {
                    charge.verdicts.append(Verdict(level: .warn,
                        text: String(format: s.adapterLimited, label, negText)))
                }
            }
            if let v = adapter.voltage, let a = adapter.current {
                charge.verdicts.append(Verdict(level: .info,
                    text: String(format: s.adapterProfile,
                                 String(format: "%.0f", v), String(format: "%.2f", a))))
            }
            if adapter.profiles.count > 1 {
                let list = adapter.profiles
                    .map { String(format: "%.0fV/%.1fA", $0.volts, $0.amps) }
                    .joined(separator: " · ")
                charge.verdicts.append(Verdict(level: .info, text: String(format: s.adapterProfiles, list)))
            }
        } else {
            charge.subtitle = s.adapterNotConnected
            charge.verdicts.append(Verdict(level: .info, text: s.adapterNotConnectedNote))
        }
        out.append(charge)

        if let percent = battery.percent {
            var b = Connection(kind: .power, role: .battery, stableID: "power:battery",
                               title: s.battery, badge: percentText(percent, s),
                               icon: batteryIcon(percent: percent, charging: battery.isCharging))
            var parts: [String] = []
            // Sistem Ayarları'ndaki değeri kullan ama yazımı seçili dile göre biçimle
            let healthValue = spBatteryHealthText().flatMap(percentValue(from:)) ?? battery.rawHealthPercent
            if let healthValue {
                parts.append(String(format: s.batteryMaxCapacity, percentText(healthValue, s)))
            }
            if let cycles = battery.cycleCount { parts.append(String(format: s.batteryCycles, cycles)) }
            b.subtitle = parts.joined(separator: " · ")

            if battery.isCharging {
                if let minutes = battery.timeRemainingMinutes, minutes > 0, minutes < 60 * 12 {
                    b.verdicts.append(Verdict(level: .good, text: String(format: s.chargingWithTime, minutes)))
                } else {
                    b.verdicts.append(Verdict(level: .good, text: s.charging))
                }
            } else if battery.externalConnected {
                b.verdicts.append(Verdict(level: .info, text: s.connectedNotCharging))
            }
            // Altyazı ile yorum aynı sayıyı kullansın (biri Sistem Ayarları değeri,
            // diğeri ham oran olduğunda çelişkili görünüyordu).
            if let health = healthValue {
                b.verdicts.append(Verdict(level: health >= 80 ? .good : .warn,
                    text: health >= 80 ? s.batteryHealthGood : String(format: s.batteryHealthWorn, health)))
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

    private static func displayRows(_ s: KKStrings) -> [Connection] {
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
            let name = screenName(for: id) ?? s.externalDisplay

            var resolution = "\(width) × \(height)"
            if refresh > 0 { resolution += String(format: " @ %.0f Hz", refresh) }

            var c = Connection(kind: .display, role: .display, stableID: "display:\(id)",
                               title: name, subtitle: resolution, badge: "video")
            c.verdicts.append(Verdict(level: .good,
                text: String(format: s.displayCarriesVideo, resolution)))
            if CGDisplayIsAsleep(id) != 0 {
                c.verdicts.append(Verdict(level: .info, text: s.displaySleeping))
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

    private static func thunderboltRows(_ s: KKStrings) -> ([Connection], String?) {
        let found = profilerItems(["SPThunderboltDataType", "SPThunderboltHostDataType"])
        guard let buses = found.items else {
            return ([], s.thunderboltUnavailable)
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
                                   role: .port,
                                   stableID: "port:\(idText)",
                                   title: String(format: s.portTitle, idText),
                                   subtitle: isEmpty
                                        ? String(format: s.portEmptySubtitle, badge(for: speed) ?? "40 Gb/s")
                                        : s.portDeviceConnected,
                                   badge: isEmpty ? nil : badge(for: speed),
                                   gbps: isEmpty ? nil : speed,
                                   isEmptyPort: isEmpty)
                if isEmpty {
                    c.verdicts = []          // boş portlar tek satırda, açıklama bölüm altında
                } else if let g = speed, g >= 40 {
                    c.verdicts = [Verdict(level: .good, text: s.portFullSpeed)]
                } else {
                    c.verdicts = [Verdict(level: .warn,
                        text: String(format: s.portSlow, speed.map { speedText($0) } ?? "?"))]
                }
                out.append(c)
            }

            for device in connectedDevices {
                let name = (device["device_name_key"] as? String) ?? s.tbDevice
                let vendor = (device["vendor_name_key"] as? String) ?? ""
                let speed = speedFromText(device["current_speed_key"] as? String)
                var c = Connection(kind: .port, role: .port,
                                   stableID: "tb:\(name)",
                                   title: name,
                                   subtitle: vendor.isEmpty ? s.tbDevice : vendor,
                                   badge: badge(for: speed), gbps: speed)
                c.verdicts.append(Verdict(level: (speed ?? 0) >= 40 ? .good : .info,
                    text: String(format: s.tbConnection, speed.map { speedText($0) } ?? "?")))
                out.append(c)
            }
        }
        return (out.sorted { $0.title < $1.title }, nil)
    }

    /// "Up to 40 Gb/s" → 40, "Up to 480 Mb/s" → 0.48
    ///
    /// Not: eskiden alt dize aramasıyla yapılıyordu ve "480 Mb/s" içindeki "80"
    /// yüzünden 80 Gb/s okunuyordu. Artık sayı ve birim birlikte ayrıştırılıyor.
    static func speedFromText(_ raw: String?) -> Double? {
        guard let raw else { return nil }
        let pattern = #"(\d+(?:[.,]\d+)?)\s*(gb|mb)/s"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
              let m = regex.firstMatch(in: raw, range: NSRange(raw.startIndex..., in: raw)),
              let numberRange = Range(m.range(at: 1), in: raw),
              let unitRange = Range(m.range(at: 2), in: raw),
              let value = Double(raw[numberRange].replacingOccurrences(of: ",", with: "."))
        else { return nil }
        return raw[unitRange].lowercased() == "mb" ? value / 1000 : value
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
        let usb = USBProbe.devices(fallbackName: "USB")
        let adapter = PowerProbe.adapter()
        let strings = KKStrings.turkish
        let tb = profilerItems(["SPThunderboltDataType", "SPThunderboltHostDataType"])
        var lines: [String] = []
        lines.append("macOS: \(ProcessInfo.processInfo.operatingSystemVersionString)")
        lines.append("USB (IOKit)            : \(usb.count) aygıt")
        lines.append("Güç (IOKit)            : \(adapter == nil ? "adaptör bağlı değil" : (adapter?.name ?? "bağlı"))")
        lines.append("Pil (IOKit)            : %\(PowerProbe.battery().percent.map(String.init) ?? "-")")
        lines.append("Ekran (CoreGraphics)   : \(displayRows(strings).count) harici")
        lines.append("Thunderbolt            : \(tb.usedType ?? "VERİ TİPİ YOK") → \(tb.items?.count ?? 0) veri yolu")
        lines.append("system_profiler tipleri: \(availableDataTypes.count) adet")
        for t in ["SPUSBDataType", "SPUSBHostDataType", "SPThunderboltDataType", "SPPowerDataType", "SPDisplaysDataType"] {
            lines.append("  \(availableDataTypes.contains(t) ? "✓" : "✗") \(t)")
        }
        return lines.joined(separator: "\n")
    }
}
