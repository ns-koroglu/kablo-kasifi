import Foundation

extension KKStrings {
    static let turkish = KKStrings(
        tagline: "Taktığın kablo gerçekte ne yapıyor?",
        scanning: "Taranıyor…",
        noUSBDevices: "USB aygıtı yok",
        usbDeviceCount: "%d USB aygıtı",
        displayCount: "%d ekran",
        refresh: "Yeniden tara",
        badgeNew: "YENİ",
        launchAtLogin: "Girişte başlat",
        quit: "Çıkış",
        language: "Dil",
        systemLanguage: "Sistem dili (%@)",
        percentFormat: "%%%d",

        sectionDevices: "Bağlı aygıtlar",
        sectionPower: "Güç",
        sectionDisplays: "Ekranlar",
        sectionPorts: "Portlar",
        emptyDevices: "Şu an USB aygıtı yok. Bir kablo tak, ne taşıdığını anlatayım.",

        portTitle: "Port %@",
        portEmptySubtitle: "Boş · %@ hıza kadar",
        portEmptyNote: "Boş portlarda Thunderbolt/USB4 aygıtı yok. Normal USB aygıtları yukarıdaki listede görünür.",
        portDeviceConnected: "Aygıt bağlı",
        portFullSpeed: "40 Gb/s bağlantı kuruldu — kablon tam hızlı Thunderbolt/USB4 kablosu.",
        portSlow: "Bağlantı %@. Kablo pasif ya da düşük hızlı olabilir.",
        tbDevice: "Thunderbolt aygıtı",
        tbConnection: "Thunderbolt bağlantısı: %@.",

        charge: "Şarj",
        adapterNotConnected: "Adaptör bağlı değil",
        adapterNotConnectedNote: "Şarj kablosu takılı değil. Taktığında adaptörün kaç watt verdiğini ve kablonun bunu sınırlayıp sınırlamadığını buradan göreceksin.",
        adapterFullPower: "%d W adaptör tam güçte veriyor (%@ W anlaşıldı). Kablo bu gücü sorunsuz taşıyor.",
        adapterBatteryFull: "Şu an %@ W çekiliyor. Pil %%%d seviyesinde olduğu için Mac az güç istiyor; bu normal.",
        adapterLimited: "Adaptör %d W ama yalnızca %@ W geliyor. Kablo düşük güçlü (60 W sınırlı) olabilir ya da tam oturmamış olabilir.",
        adapterProfile: "Anlaşılan profil: %@ V · %@ A.",
        adapterProfiles: "Adaptörün sunduğu profiller: %@.",
        powerAdapterFallback: "Güç adaptörü",

        battery: "Pil",
        batteryMaxCapacity: "azami kapasite %@",
        batteryCycles: "%d döngü",
        chargingWithTime: "Şarj oluyor — tam dolmasına yaklaşık %d dakika.",
        charging: "Şarj oluyor.",
        connectedNotCharging: "Adaptör bağlı ama şu an şarj etmiyor (pil yeterince dolu).",
        batteryHealthGood: "Pil sağlığı iyi durumda.",
        batteryHealthWorn: "Pil kapasitesi tasarım değerinin %%%d'ine düşmüş; değişim zamanı yaklaşmış olabilir.",

        usbDeviceFallback: "USB aygıtı",
        deviceVersionSuffix: "%@ aygıtı",
        viaParent: "%@ üzerinden",
        hubFast: "Hub %@ hızında bağlı; altındaki aygıtlar bu bant genişliğini paylaşır.",
        hubSlow: "Hub USB 2.0 hızında (480 Mb/s) bağlı; altına taktığın her aygıt bu hızla sınırlanır.",
        deviceFast: "%@ hızında bağlı — aygıt, kablo ve port tam kapasite çalışıyor.",
        deviceOwnLimit: "Aygıtın kendisi %@ — 480 Mb/s onun tavanı. Kablo veya port suçlu değil.",
        deviceHubLimit: "Aygıt USB 3.x destekliyor ama 480 Mb/s'de bağlı. Sınırlayan, üstündeki %@ (USB 2.0 hızında).",
        deviceCableLimit: "Aygıt USB 3.x destekliyor ama yalnızca 480 Mb/s'de bağlanmış. Kablo büyük ihtimalle sadece şarj/USB 2.0 kablosu — veri kablosuyla 10 kat hızlanır.",

        externalDisplay: "Harici ekran",
        displayCarriesVideo: "Bu kablo görüntü taşıyor: %@.",
        displaySleeping: "Ekran şu an uykuda.",

        thunderboltUnavailable: "Bu macOS sürümünde Thunderbolt port verisi okunamadı (beklenen system_profiler veri tipi yok). USB aygıtları ve güç bilgisi etkilenmez."
    )
}
