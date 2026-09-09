import Foundation
import IOKit
import IOKit.ps

/// Güç adaptörü ve pil bilgisi — doğrudan IOKit'ten.
///
/// `IOPSCopyExternalPowerAdapterDetails` bazı makinelerde voltajı "Voltage",
/// bazılarında "AdapterVoltage" anahtarıyla veriyor; AppleSmartBattery'nin
/// AdapterDetails sözlüğü ise tüm alanları (Watts, AdapterVoltage, Current,
/// UsbHvcMenu) tutarlı biçimde içeriyor.
struct AdapterInfo: Sendable {
    var name: String?
    var description: String?
    /// Adaptörün etiket gücü (adından çıkarılır, ör. "96W USB-C Power Adapter")
    var labelWatts: Int?
    /// Sistemin bildirdiği anlaşılmış güç
    var watts: Int?
    var voltage: Double?      // V
    var current: Double?      // A
    /// USB-PD profilleri (V, A)
    var profiles: [(volts: Double, amps: Double)] = []

    var negotiatedWatts: Double? {
        if let voltage, let current, voltage > 0, current > 0 { return voltage * current }
        if let watts, watts > 0 { return Double(watts) }
        return nil
    }
}

struct BatteryInfo: Sendable {
    var percent: Int?
    var isCharging = false
    var externalConnected = false
    var cycleCount: Int?
    /// Ham kapasite oranı (%), Sistem Ayarları'ndaki değerden farklı olabilir
    var rawHealthPercent: Int?
    var timeRemainingMinutes: Int?
}

enum PowerProbe {

    private static func batteryProperties() -> [String: Any]? {
        let service = IOServiceGetMatchingService(kIOMainPortDefault,
                                                  IOServiceMatching("AppleSmartBattery"))
        guard service != 0 else { return nil }
        defer { IOObjectRelease(service) }
        var unmanaged: Unmanaged<CFMutableDictionary>?
        guard IORegistryEntryCreateCFProperties(service, &unmanaged, kCFAllocatorDefault, 0) == KERN_SUCCESS,
              let dict = unmanaged?.takeRetainedValue() as? [String: Any] else { return nil }
        return dict
    }

    static func adapter() -> AdapterInfo? {
        // Pili olmayan Mac'lerde (Mac mini/Studio) AppleSmartBattery yok;
        // o durumda güç kaynağı API'sine düş.
        guard let props = batteryProperties() else { return adapterFromPowerSources() }
        guard (props["ExternalConnected"] as? Bool) == true,
              let details = props["AdapterDetails"] as? [String: Any], !details.isEmpty
        else { return adapterFromPowerSources() }

        var info = AdapterInfo()
        info.name = details["Name"] as? String
        info.description = details["Description"] as? String
        info.watts = (details["Watts"] as? NSNumber)?.intValue
        if let mv = (details["AdapterVoltage"] as? NSNumber ?? details["Voltage"] as? NSNumber) {
            info.voltage = mv.doubleValue / 1000
        }
        if let ma = (details["Current"] as? NSNumber) {
            info.current = ma.doubleValue / 1000
        }
        // Adaptör adından etiket gücü çıkarılamıyorsa nil kalsın: aksi hâlde
        // etiket == anlaşılan güç olur, oran daima 1.0 çıkar ve "kablo sınırlıyor"
        // uyarısı hiçbir zaman tetiklenmez.
        info.labelWatts = info.name.flatMap(wattsFromName)

        if let menu = details["UsbHvcMenu"] as? [[String: Any]] {
            info.profiles = menu.compactMap { entry in
                guard let mv = (entry["MaxVoltage"] as? NSNumber)?.doubleValue,
                      let ma = (entry["MaxCurrent"] as? NSNumber)?.doubleValue else { return nil }
                return (mv / 1000, ma / 1000)
            }
        }
        return info
    }

    /// "96W USB-C Power Adapter" → 96
    static func wattsFromName(_ name: String) -> Int? {
        let pattern = #"(\d{1,3})\s*[wW]\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let m = regex.firstMatch(in: name, range: NSRange(name.startIndex..., in: name)),
              let range = Range(m.range(at: 1), in: name) else { return nil }
        return Int(name[range])
    }

    /// Pilsiz makineler için yedek yol.
    private static func adapterFromPowerSources() -> AdapterInfo? {
        guard let details = IOPSCopyExternalPowerAdapterDetails()?.takeRetainedValue() as? [String: Any],
              !details.isEmpty else { return nil }
        var info = AdapterInfo()
        info.name = (details["Name"] as? String) ?? (details["Description"] as? String)
        info.watts = (details["Watts"] as? NSNumber)?.intValue
        if let mv = (details["AdapterVoltage"] as? NSNumber ?? details["Voltage"] as? NSNumber) {
            info.voltage = mv.doubleValue / 1000
        }
        if let ma = (details["Current"] as? NSNumber) { info.current = ma.doubleValue / 1000 }
        info.labelWatts = info.name.flatMap(wattsFromName)
        return info
    }

    static func battery() -> BatteryInfo {
        var info = BatteryInfo()
        guard let props = batteryProperties() else { return info }
        // Apple Silicon'da CurrentCapacity doğrudan yüzde (MaxCapacity = 100),
        // Intel'de mAh. Oranla hesaplamak ikisinde de doğru sonucu veriyor.
        let current = (props["CurrentCapacity"] as? NSNumber)?.doubleValue
        let maxCap = (props["MaxCapacity"] as? NSNumber)?.doubleValue
        if let current {
            if let maxCap, maxCap > 0, maxCap != 100 {
                info.percent = Int((current / maxCap * 100).rounded())
            } else {
                info.percent = Int(current.rounded())
            }
        }
        info.isCharging = (props["IsCharging"] as? Bool) ?? false
        info.externalConnected = (props["ExternalConnected"] as? Bool) ?? false
        info.cycleCount = (props["CycleCount"] as? NSNumber)?.intValue
        info.timeRemainingMinutes = (props["TimeRemaining"] as? NSNumber)?.intValue
        if let raw = (props["AppleRawMaxCapacity"] as? NSNumber)?.doubleValue,
           let design = (props["DesignCapacity"] as? NSNumber)?.doubleValue, design > 0 {
            info.rawHealthPercent = Int((raw / design * 100).rounded())
        }
        return info
    }
}
