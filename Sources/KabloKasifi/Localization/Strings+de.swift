import Foundation

extension KKStrings {
    static let german = KKStrings(
        tagline: "Was kann das eingesteckte Kabel wirklich?",
        scanning: "Wird gescannt…",
        noUSBDevices: "Keine USB-Geräte",
        usbDeviceCount: "%d USB-Geräte",
        usbDeviceCountOne: "1 USB-Gerät",
        displayCount: "%d Displays",
        displayCountOne: "1 Display",
        refresh: "Erneut scannen",
        badgeNew: "NEU",
        launchAtLogin: "Beim Anmelden starten",
        quit: "Beenden",
        language: "Sprache",
        systemLanguage: "Systemsprache (%@)",
        percentFormat: "%d%%",

        sectionDevices: "Verbundene Geräte",
        sectionPower: "Stromversorgung",
        sectionDisplays: "Displays",
        sectionPorts: "Anschlüsse",
        emptyDevices: "Derzeit keine USB-Geräte. Steck ein Kabel ein, dann sage ich dir, was es überträgt.",

        portTitle: "Anschluss %@",
        portEmptySubtitle: "Frei · bis zu %@",
        portEmptyNote: "An freien Anschlüssen hängt kein Thunderbolt/USB4-Gerät. Normale USB-Geräte stehen in der Liste oben.",
        portDeviceConnected: "Gerät verbunden",
        portFullSpeed: "40-Gb/s-Verbindung hergestellt — dein Kabel ist ein vollwertiges Thunderbolt/USB4-Kabel.",
        portSlow: "Verbindung: %@. Das Kabel ist möglicherweise passiv oder langsam.",
        tbDevice: "Thunderbolt-Gerät",
        tbConnection: "Thunderbolt-Verbindung: %@.",

        charge: "Laden",
        adapterNotConnected: "Kein Netzteil verbunden",
        adapterNotConnectedNote: "Kein Ladekabel angeschlossen. Sobald du eines einsteckst, siehst du hier, wie viel Watt ankommen und ob das Kabel bremst.",
        adapterFullPower: "Das %d-W-Netzteil liefert volle Leistung (%@ W ausgehandelt). Dein Kabel überträgt sie problemlos.",
        adapterBatteryFull: "Aktuell werden %@ W bezogen. Der Akku ist bei %d %%, deshalb braucht der Mac wenig Leistung — das ist normal.",
        adapterLimited: "Das Netzteil hat %d W, es kommen aber nur %@ W an. Das Kabel ist womöglich auf 60 W begrenzt oder sitzt nicht richtig.",
        adapterProfile: "Ausgehandeltes Profil: %@ V · %@ A.",
        adapterProfiles: "Profile des Netzteils: %@.",
        powerAdapterFallback: "Netzteil",

        battery: "Akku",
        batteryMaxCapacity: "maximale Kapazität %@",
        batteryCycles: "%d Ladezyklen",
        chargingWithTime: "Lädt — noch etwa %d Minuten bis voll.",
        charging: "Lädt.",
        connectedNotCharging: "Netzteil verbunden, lädt aber gerade nicht (Akku ist voll genug).",
        batteryHealthGood: "Der Akkuzustand ist gut.",
        batteryHealthWorn: "Die Akkukapazität liegt nur noch bei %d %% des Neuwerts; ein Austausch könnte anstehen.",

        usbDeviceFallback: "USB-Gerät",
        deviceVersionSuffix: "%@-Gerät",
        viaParent: "über %@",
        hubFast: "Hub ist mit %@ verbunden; alle Geräte daran teilen sich diese Bandbreite.",
        hubSlow: "Hub läuft mit USB-2.0-Tempo (480 Mb/s); alles, was du daran steckst, wird darauf begrenzt.",
        deviceFast: "Mit %@ verbunden — Gerät, Kabel und Anschluss laufen mit voller Leistung.",
        deviceOwnLimit: "Das Gerät selbst ist %@ — 480 Mb/s sind seine eigene Obergrenze. Kabel und Anschluss sind nicht schuld.",
        deviceHubLimit: "Das Gerät kann USB 3.x, ist aber mit 480 Mb/s verbunden. Die Bremse ist der %@ davor (läuft mit USB 2.0).",
        deviceCableLimit: "Das Gerät kann USB 3.x, ist aber nur mit 480 Mb/s verbunden. Dein Kabel ist höchstwahrscheinlich ein reines Lade-/USB-2.0-Kabel — mit einem Datenkabel wird es 10× schneller.",
        linkSpeedUnknown: "Die Verbindungsgeschwindigkeit ließ sich nicht lesen — deshalb beschuldige ich weder Kabel noch Hub oder Gerät.",
        usbVersionUnknown: "unbekannte USB-Version",

        externalDisplay: "Externes Display",
        displayCarriesVideo: "Dieses Kabel überträgt Bild: %@.",
        displaySleeping: "Das Display schläft gerade.",

        thunderboltUnavailable: "Die Thunderbolt-Anschlussdaten konnten unter dieser macOS-Version nicht gelesen werden (erwarteter system_profiler-Datentyp fehlt). USB-Geräte und Stromdaten sind nicht betroffen."
    )
}
