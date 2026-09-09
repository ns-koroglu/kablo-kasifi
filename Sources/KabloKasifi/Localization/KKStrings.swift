import Foundation

/// Uygulamanın tüm metinleri. Her dil bu yapının **tamamını** doldurmak zorunda —
/// yeni bir alan eklendiğinde çeviri dosyaları derlenmez, böylece eksik çeviri
/// sessizce İngilizce/Türkçe kalmaz.
///
/// Biçim dizgilerinde `%@` metin, `%d` sayı yerine geçer (String(format:)).
struct KKStrings: Sendable {
    // Genel arayüz
    let tagline: String
    let scanning: String
    let noUSBDevices: String
    let usbDeviceCount: String        // %d
    let usbDeviceCountOne: String     // tekil
    let displayCount: String          // %d
    let displayCountOne: String       // tekil
    let refresh: String
    let badgeNew: String
    let launchAtLogin: String
    let quit: String
    let language: String
    let systemLanguage: String        // %@ = çözümlenen dil
    /// Yüzde yazımı: Türkçe'de "%98", çoğu dilde "98%"
    let percentFormat: String         // %d

    // Bölümler
    let sectionDevices: String
    let sectionPower: String
    let sectionDisplays: String
    let sectionPorts: String
    let emptyDevices: String

    // Portlar
    let portTitle: String             // %@ = port no
    let portEmptySubtitle: String     // %@ = hız
    let portEmptyNote: String
    let portDeviceConnected: String
    let portFullSpeed: String
    let portSlow: String              // %@ = hız
    let tbDevice: String
    let tbConnection: String          // %@ = hız

    // Güç
    let charge: String
    let adapterNotConnected: String
    let adapterNotConnectedNote: String
    let adapterFullPower: String      // %d etiket, %@ anlaşılan
    let adapterBatteryFull: String    // %@ anlaşılan, %d pil yüzdesi
    let adapterLimited: String        // %d etiket, %@ anlaşılan
    let adapterProfile: String        // %@ volt, %@ amper
    let adapterProfiles: String       // %@ liste
    let powerAdapterFallback: String

    // Pil
    let battery: String
    let batteryMaxCapacity: String    // %@
    let batteryCycles: String         // %d
    let chargingWithTime: String      // %d dakika
    let charging: String
    let connectedNotCharging: String
    let batteryHealthGood: String
    let batteryHealthWorn: String     // %d

    // USB aygıtları
    let usbDeviceFallback: String
    let deviceVersionSuffix: String   // %@ = "USB 3.1"
    let viaParent: String             // %@ = hub adı
    let hubFast: String               // %@ = hız
    let hubSlow: String
    let deviceFast: String            // %@ = hız
    let deviceOwnLimit: String        // %@ = usb sürümü
    let deviceHubLimit: String        // %@ = hub adı
    let deviceCableLimit: String
    let linkSpeedUnknown: String

    // Ekranlar
    let externalDisplay: String
    let displayCarriesVideo: String   // %@ = çözünürlük
    let displaySleeping: String

    // Uyarılar
    let thunderboltUnavailable: String
}

extension KKStrings {
    static let table: [AppLanguage: KKStrings] = [
        .tr: .turkish, .en: .english, .de: .german, .es: .spanish, .fr: .french,
        .it: .italian, .pt: .portuguese, .ru: .russian, .zh: .chinese, .ja: .japanese
    ]
}
