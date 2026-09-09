import Foundation
import IOKit

/// IOKit kayıt defterinden USB aygıtları.
///
/// Not: macOS 26'da `system_profiler SPUSBDataType` diye bir veri tipi kalmadı
/// (`SPUSBHostDataType` oldu) ve eski adı isteyince sessizce boş dizi dönüyor.
/// IOKit hem sürüm bağımsız hem de alt süreç açmadan anında yanıt veriyor.
struct USBDeviceInfo: Sendable {
    var name: String
    var vendor: String
    /// Gerçekleşen bağlantı hızı (bit/s)
    var linkSpeedBps: Double?
    /// Aygıtın kendi desteklediği USB sürümü (bcdUSB, ör. 0x0320)
    var bcdUSB: Int?
    var isHub: Bool
    var locationID: UInt32
    var depth: Int

    var linkGbps: Double? {
        guard let bps = linkSpeedBps, bps > 0 else { return nil }
        return bps / 1_000_000_000
    }

    /// Aygıtın kendi yeteneği (Gb/s olarak alt sınır)
    var capabilityGbps: Double? {
        guard let bcd = bcdUSB else { return nil }
        if bcd >= 0x0320 { return 10 }
        if bcd >= 0x0300 { return 5 }
        return 0.48
    }

    var usbVersionText: String {
        guard let bcd = bcdUSB else { return "bilinmiyor" }
        let major = (bcd >> 8) & 0xFF
        let minor = (bcd >> 4) & 0x0F
        return "USB \(major).\(minor)"
    }
}

enum USBProbe {

    static func devices(fallbackName: String = "USB") -> [USBDeviceInfo] {
        var iterator: io_iterator_t = 0
        guard IOServiceGetMatchingServices(kIOMainPortDefault,
                                           IOServiceMatching("IOUSBHostDevice"),
                                           &iterator) == KERN_SUCCESS else { return [] }
        defer { IOObjectRelease(iterator) }

        var out: [USBDeviceInfo] = []
        while case let service = IOIteratorNext(iterator), service != 0 {
            defer { IOObjectRelease(service) }
            guard let props = properties(of: service) else { continue }

            let name = (props["USB Product Name"] as? String)
                ?? (props["kUSBProductString"] as? String)
                ?? fallbackName
            let vendor = (props["USB Vendor Name"] as? String)
                ?? (props["kUSBVendorString"] as? String) ?? ""
            let location = (props["locationID"] as? NSNumber)?.uint32Value ?? 0
            // Üç kademeli: UsbLinkSpeed (bit/s) → USBSpeed → Device Speed.
            // Anahtar adları macOS sürümleri arasında değişebiliyor.
            let speed = (props["UsbLinkSpeed"] as? NSNumber)?.doubleValue
                ?? fallbackSpeed(props["USBSpeed"] as? NSNumber)
                ?? fallbackSpeed(props["Device Speed"] as? NSNumber)
            let bcd = (props["bcdUSB"] as? NSNumber)?.intValue
            let isHub = ((props["bDeviceClass"] as? NSNumber)?.intValue ?? 0) == 9

            out.append(USBDeviceInfo(name: name, vendor: vendor,
                                     linkSpeedBps: speed, bcdUSB: bcd,
                                     isHub: isHub, locationID: location,
                                     depth: depth(of: location)))
        }
        return out.sorted { ($0.locationID, $0.depth) < ($1.locationID, $1.depth) }
    }

    private static func properties(of service: io_service_t) -> [String: Any]? {
        var unmanaged: Unmanaged<CFMutableDictionary>?
        guard IORegistryEntryCreateCFProperties(service, &unmanaged, kCFAllocatorDefault, 0) == KERN_SUCCESS,
              let dict = unmanaged?.takeRetainedValue() as? [String: Any] else { return nil }
        return dict
    }

    /// "Device Speed" numaralandırması → bit/s
    private static func fallbackSpeed(_ value: NSNumber?) -> Double? {
        guard let v = value?.intValue else { return nil }
        switch v {
        case 0: return 1_500_000
        case 1: return 12_000_000
        case 2: return 480_000_000
        case 3: return 5_000_000_000
        case 4: return 10_000_000_000
        case 5: return 20_000_000_000
        default: return nil
        }
    }

    /// locationID'de ilk bayttan sonraki sıfır olmayan nibble sayısı = ağaç derinliği.
    static func depth(of location: UInt32) -> Int {
        var d = 0
        for shift in stride(from: 20, through: 0, by: -4) {
            if (location >> UInt32(shift)) & 0xF != 0 { d += 1 }
        }
        return max(1, d)
    }

    /// Bir aygıtın üstündeki hub'ı locationID'den bulur.
    static func parent(of device: USBDeviceInfo, in all: [USBDeviceInfo]) -> USBDeviceInfo? {
        guard device.depth > 1 else { return nil }
        // Son sıfır olmayan nibble'ı sıfırla → üst düğümün locationID'si
        var mask: UInt32 = 0
        for shift in stride(from: 20, through: 0, by: -4) where (device.locationID >> UInt32(shift)) & 0xF != 0 {
            mask = 0xF << UInt32(shift)
        }
        let parentID = device.locationID & ~mask
        return all.first { $0.locationID == parentID && $0.isHub }
    }
}
