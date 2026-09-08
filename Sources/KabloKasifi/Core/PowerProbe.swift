import Foundation
import IOKit

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
        if let voltage, let current { return voltage * current }
        if let watts { return Double(watts) }
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
        guard let props = batteryProperties() else { return nil }
        guard (props["ExternalConnected"] as? Bool) == true,
              let details = props["AdapterDetails"] as? [String: Any], !details.isEmpty else { return nil }

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
        info.labelWatts = info.name.flatMap(wattsFromName) ?? info.watts

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

    static func battery() -> BatteryInfo {
        var info = BatteryInfo()
        guard let props = batteryProperties() else { return info }
        info.percent = (props["CurrentCapacity"] as? NSNumber)?.intValue
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
