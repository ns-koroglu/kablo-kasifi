import Foundation
import IOKit.ps

/// Sistemden ham veriyi toplar ve düz Türkçe yorumlara çevirir.
enum SystemProbe {

    // MARK: - Genel giriş

    static func probe() -> ProbeResult {
        guard let raw = runProfiler() else {
            var r = ProbeResult()
            r.failure = "Sistem bilgisi okunamadı (system_profiler yanıt vermedi)."
            return r
        }
        var result = ProbeResult()
        result.ports = parseThunderbolt(raw["SPThunderboltDataType"] as? [[String: Any]] ?? [])
        result.power = parsePower(raw["SPPowerDataType"] as? [[String: Any]] ?? [])
        result.devices = parseUSB(raw["SPUSBDataType"] as? [[String: Any]] ?? [])
        result.displays = parseDisplays(raw["SPDisplaysDataType"] as? [[String: Any]] ?? [])
        return result
    }

    private static func runProfiler() -> [String: Any]? {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/sbin/system_profiler")
        p.arguments = ["-json", "SPUSBDataType", "SPThunderboltDataType",
                       "SPPowerDataType", "SPDisplaysDataType"]
        let pipe = Pipe()
        p.standardOutput = pipe
        p.standardError = FileHandle.nullDevice
        do { try p.run() } catch { return nil }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        p.waitUntilExit()
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }

    // MARK: - Hız yorumlama

    /// "up_to_10Gb_per_sec" / "Up to 40 Gb/s" → (10.0, "USB 3.2 Gen 2")
    static func parseSpeed(_ raw: String?) -> (gbps: Double?, label: String) {
        guard let raw, !raw.isEmpty else { return (nil, "bilinmiyor") }
        let s = raw.lowercased()
        var gbps: Double?
        if s.contains("1.5mb") || s.contains("low_speed") { gbps = 0.0015 }
        else if s.contains("12mb") { gbps = 0.012 }
        else if s.contains("480mb") { gbps = 0.48 }
        else if s.contains("5gb") { gbps = 5 }
        else if s.contains("10gb") { gbps = 10 }
        else if s.contains("20gb") { gbps = 20 }
        else if s.contains("40gb") || s.contains("40 gb") { gbps = 40 }
        else if s.contains("80gb") || s.contains("80 gb") { gbps = 80 }

        switch gbps {
        case .some(let g) where g <= 0.012: return (g, "USB 1.x")
        case .some(0.48): return (0.48, "USB 2.0 · 480 Mb/s")
        case .some(5): return (5, "USB 3.0 · 5 Gb/s")
        case .some(10): return (10, "USB 3.2 Gen 2 · 10 Gb/s")
        case .some(20): return (20, "USB 3.2 Gen 2x2 · 20 Gb/s")
        case .some(40): return (40, "USB4 / Thunderbolt · 40 Gb/s")
        case .some(80): return (80, "Thunderbolt 5 · 80 Gb/s")
        default: return (gbps, raw)
        }
    }

    static func badge(for gbps: Double?) -> String? {
        guard let g = gbps else { return nil }
        if g < 1 { return "\(Int(g * 1000)) Mb/s" }
        return "\(Int(g)) Gb/s"
    }

    // MARK: - Thunderbolt / USB4 portları

    private static func parseThunderbolt(_ buses: [[String: Any]]) -> [Connection] {
        var out: [Connection] = []

        for bus in buses {
            // Her veri yolunun altındaki yuvalar: "receptacle_1_tag", "receptacle_2_tag", …
            let receptacles = bus.filter { $0.key.hasPrefix("receptacle_") }
                .compactMap { $0.value as? [String: Any] }
            let connectedDevices = (bus["_items"] as? [[String: Any]]) ?? []

            for rec in receptacles {
                let idText = (rec["receptacle_id_key"] as? String) ?? "?"
                let status = (rec["receptacle_status_key"] as? String) ?? ""
                let speedRaw = rec["current_speed_key"] as? String
                let speed = parseSpeed(speedRaw)
                let isEmpty = status.contains("no_devices_connected")

                var c = Connection(kind: .port,
                                   title: "Port \(idText)",
                                   subtitle: isEmpty
                                        ? "Boş · \(badge(for: speed.gbps) ?? "") hıza kadar destekler"
                                        : "Aygıt bağlı",
                                   badge: isEmpty ? nil : badge(for: speed.gbps),
                                   gbps: isEmpty ? nil : speed.gbps,
                                   isEmptyPort: isEmpty)

                if isEmpty {
                    c.verdicts = [Verdict(level: .info,
                                          text: "Bu port boş. Kablo taktığında burada ne taşıdığını yazacağım.")]
                } else if let g = speed.gbps, g >= 40 {
                    c.verdicts = [Verdict(level: .good,
                                          text: "40 Gb/s bağlantı kuruldu — kablon tam hızlı Thunderbolt/USB4 kablosu.")]
                } else {
                    c.verdicts = [Verdict(level: .warn,
                                          text: "Bağlantı \(speed.label). Kablo pasif ya da düşük hızlı olabilir; tam hız için sertifikalı Thunderbolt/USB4 kablosu gerekir.")]
                }
                out.append(c)
            }

            for device in connectedDevices {
                let name = (device["device_name_key"] as? String) ?? "Bilinmeyen aygıt"
                let vendor = (device["vendor_name_key"] as? String) ?? ""
                let speed = parseSpeed(device["current_speed_key"] as? String)
                var c = Connection(kind: .port,
                                   title: name,
                                   subtitle: vendor.isEmpty ? "Thunderbolt aygıtı" : vendor,
                                   badge: badge(for: speed.gbps),
                                   gbps: speed.gbps)
                c.verdicts.append(Verdict(level: speed.gbps.map { $0 >= 40 } == true ? .good : .info,
                                          text: "Thunderbolt bağlantısı: \(speed.label)."))
                out.append(c)
            }
        }
        return out.sorted { ($0.title) < ($1.title) }
    }

    // MARK: - USB aygıtları

    private static func parseUSB(_ buses: [[String: Any]]) -> [Connection] {
        var out: [Connection] = []

        func walk(_ items: [[String: Any]], depth: Int) {
            for item in items {
                let name = (item["_name"] as? String) ?? "USB aygıtı"
                let isHubLike = name.lowercased().contains("hub")
                let speed = parseSpeed(item["device_speed"] as? String)
                let vendor = (item["manufacturer"] as? String) ?? ""

                // Yalnızca gerçek aygıtları listele (kök veri yollarını değil)
                if item["device_speed"] != nil {
                    var c = Connection(kind: .usb,
                                       title: name,
                                       subtitle: vendor,
                                       badge: badge(for: speed.gbps),
                                       gbps: speed.gbps)
                    c.verdicts.append(speedVerdict(name: name, speed: speed))

                    if let power = item["bus_power_used"] as? String ?? item["bus_power"] as? String {
                        c.subtitle = [vendor, "\(power) mA"].filter { !$0.isEmpty }.joined(separator: " · ")
                    }
                    if isHubLike {
                        c.verdicts.append(Verdict(level: .info,
                                                  text: "Bu bir hub; altına taktığın aygıtlar bant genişliğini paylaşır."))
                    }
                    out.append(c)
                }
                if let children = item["_items"] as? [[String: Any]] {
                    walk(children, depth: depth + 1)
                }
            }
        }
        walk(buses, depth: 0)
        return out
    }

    private static func speedVerdict(name: String, speed: (gbps: Double?, label: String)) -> Verdict {
        let lower = name.lowercased()
        let looksLikeStorage = ["ssd", "disk", "drive", "nvme", "hdd", "t5", "t7", "t9",
                                "sandisk", "samsung", "crucial", "lacie", "wd "]
            .contains { lower.contains($0) }

        guard let g = speed.gbps else {
            return Verdict(level: .info, text: "Bağlantı hızı okunamadı.")
        }
        if g <= 0.48 {
            if looksLikeStorage {
                return Verdict(level: .warn,
                               text: "Depolama aygıtı USB 2.0 hızında (480 Mb/s) bağlı. Kablon büyük ihtimalle sadece şarj/USB 2.0 kablosu — veri kablosuyla 10 kat hızlanır.")
            }
            return Verdict(level: .info,
                           text: "USB 2.0 hızında bağlı (480 Mb/s). Klavye, fare, adaptör gibi aygıtlar için bu normal.")
        }
        if g >= 10 {
            return Verdict(level: .good, text: "Hızlı bağlantı: \(speed.label). Kablo ve port tam kapasite çalışıyor.")
        }
        return Verdict(level: .good, text: "Bağlantı: \(speed.label).")
    }

    // MARK: - Ekranlar

    private static func parseDisplays(_ gpus: [[String: Any]]) -> [Connection] {
        var out: [Connection] = []
        for gpu in gpus {
            let screens = (gpu["spdisplays_ndrvs"] as? [[String: Any]]) ?? []
            for screen in screens {
                let connection = (screen["spdisplays_connection_type"] as? String) ?? ""
                let isInternal = connection.contains("internal")
                guard !isInternal else { continue }

                let name = (screen["_name"] as? String) ?? "Harici ekran"
                let resolution = (screen["_spdisplays_resolution"] as? String)
                    ?? (screen["_spdisplays_pixels"] as? String) ?? ""
                var c = Connection(kind: .display,
                                   title: name,
                                   subtitle: resolution,
                                   badge: "video")
                c.verdicts.append(Verdict(level: .good,
                                          text: "Bu kablo görüntü taşıyor\(resolution.isEmpty ? "" : ": \(resolution)")."))
                if connection.contains("displayport") || connection.contains("dp") {
                    c.verdicts.append(Verdict(level: .info, text: "Bağlantı DisplayPort üzerinden kuruldu."))
                } else if connection.contains("hdmi") {
                    c.verdicts.append(Verdict(level: .info, text: "Bağlantı HDMI üzerinden kuruldu."))
                }
                out.append(c)
            }
        }
        return out
    }

    // MARK: - Şarj

    private static func parsePower(_ items: [[String: Any]]) -> [Connection] {
        var battery: [String: Any] = [:]
        var charger: [String: Any] = [:]
        for item in items {
            switch item["_name"] as? String {
            case "spbattery_information": battery = item
            case "sppower_ac_charger_information": charger = item
            default: break
            }
        }

        let chargeInfo = battery["sppower_battery_charge_info"] as? [String: Any] ?? [:]
        let healthInfo = battery["sppower_battery_health_info"] as? [String: Any] ?? [:]
        let percent = chargeInfo["sppower_battery_state_of_charge"] as? Int
        let isCharging = (chargeInfo["sppower_battery_is_charging"] as? String) == "TRUE"
        let connected = (charger["sppower_battery_charger_connected"] as? String) == "TRUE"

        let adapter = adapterDetails()
        var out: [Connection] = []

        var c = Connection(kind: .power, title: "Şarj")
        if !connected && adapter == nil {
            c.subtitle = "Adaptör bağlı değil"
            c.verdicts.append(Verdict(level: .info,
                                      text: "Şarj kablosu takılı değil. Taktığında adaptörün kaç watt verdiğini ve kablonun bunu sınırlayıp sınırlamadığını buradan göreceksin."))
        } else {
            let labelWatts = adapter?.watts ?? Int((charger["sppower_ac_charger_watts"] as? String) ?? "") ?? 0
            let negotiated = adapter?.negotiatedWatts
            let name = adapter?.name
                ?? (charger["sppower_ac_charger_name"] as? String)
                ?? "Güç adaptörü"

            c.subtitle = name
            c.badge = labelWatts > 0 ? "\(labelWatts) W" : nil

            if let neg = negotiated, labelWatts > 0 {
                let ratio = neg / Double(labelWatts)
                let negText = String(format: "%.1f", neg)
                if ratio >= 0.88 {
                    c.verdicts.append(Verdict(level: .good,
                                              text: "\(labelWatts) W adaptör tam güçte veriyor (şu an \(negText) W). Kablo bu gücü taşıyabiliyor."))
                } else if let p = percent, p >= 90 || !isCharging {
                    c.verdicts.append(Verdict(level: .info,
                                              text: "Şu an \(negText) W çekiliyor. Pil %\(p) seviyesinde olduğu için Mac az güç istiyor; bu normal."))
                } else {
                    c.verdicts.append(Verdict(level: .warn,
                                              text: "Adaptör \(labelWatts) W ama yalnızca \(negText) W geliyor. Kablo düşük güçlü (60 W sınırlı) olabilir ya da tam oturmamış olabilir."))
                }
            } else if labelWatts > 0 {
                c.verdicts.append(Verdict(level: .info, text: "\(labelWatts) W adaptör bağlı."))
            }

            if let v = adapter?.voltage, let a = adapter?.current {
                c.verdicts.append(Verdict(level: .info,
                                          text: String(format: "Anlaşılan güç profili: %.1f V · %.2f A.", v, a)))
            }
        }
        out.append(c)

        // Pil özeti
        if let percent {
            var b = Connection(kind: .power, title: "Pil", badge: "%\(percent)",
                               icon: batteryIcon(percent: percent, charging: isCharging))
            let cycles = healthInfo["sppower_battery_cycle_count"] as? Int
            let health = healthInfo["sppower_battery_health"] as? String
            let maxCap = healthInfo["sppower_battery_health_maximum_capacity"] as? String
            var parts: [String] = []
            if let maxCap { parts.append("azami kapasite \(maxCap)") }
            if let cycles { parts.append("\(cycles) döngü") }
            b.subtitle = parts.joined(separator: " · ")
            if isCharging {
                b.verdicts.append(Verdict(level: .good, text: "Şarj oluyor."))
            } else if connected {
                b.verdicts.append(Verdict(level: .info, text: "Adaptör bağlı ama şu an şarj etmiyor (pil yeterince dolu)."))
            }
            if health == "Good" || health == "Normal" {
                b.verdicts.append(Verdict(level: .good, text: "Pil sağlığı iyi durumda."))
            } else if let health {
                b.verdicts.append(Verdict(level: .warn, text: "Pil sağlığı: \(health)."))
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

    // MARK: - IOKit güç adaptörü ayrıntıları

    struct AdapterDetails {
        var watts: Int?
        var voltage: Double?     // V
        var current: Double?     // A
        var name: String?
        var negotiatedWatts: Double? {
            guard let voltage, let current else { return nil }
            return voltage * current
        }
    }

    static func adapterDetails() -> AdapterDetails? {
        guard let dict = IOPSCopyExternalPowerAdapterDetails()?.takeRetainedValue() as? [String: Any],
              !dict.isEmpty else { return nil }
        var a = AdapterDetails()
        a.watts = dict["Watts"] as? Int
        if let mv = dict["Voltage"] as? Int { a.voltage = Double(mv) / 1000.0 }
        if let ma = dict["Current"] as? Int { a.current = Double(ma) / 1000.0 }
        a.name = (dict["Name"] as? String) ?? (dict["Description"] as? String)
        return a
    }
}
