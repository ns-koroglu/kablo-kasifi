import Foundation

extension KKStrings {
    static let italian = KKStrings(
        tagline: "Cosa sa fare davvero il cavo che hai appena collegato?",
        scanning: "Scansione…",
        noUSBDevices: "Nessun dispositivo USB",
        usbDeviceCount: "%d dispositivi USB",
        usbDeviceCountOne: "1 dispositivo USB",
        displayCount: "%d display",
        displayCountOne: "1 display",
        refresh: "Scansiona di nuovo",
        badgeNew: "NUOVO",
        launchAtLogin: "Avvia al login",
        quit: "Esci",
        language: "Lingua",
        systemLanguage: "Lingua di sistema (%@)",
        percentFormat: "%d%%",

        sectionDevices: "Dispositivi collegati",
        sectionPower: "Alimentazione",
        sectionDisplays: "Display",
        sectionPorts: "Porte",
        emptyDevices: "Al momento non ci sono dispositivi USB. Collega un cavo e ti dirò cosa trasporta.",

        portTitle: "Porta %@",
        portEmptySubtitle: "Libera · fino a %@",
        portEmptyNote: "Le porte libere non hanno dispositivi Thunderbolt/USB4. I normali dispositivi USB compaiono nell'elenco qui sopra.",
        portDeviceConnected: "Dispositivo collegato",
        portFullSpeed: "Collegamento a 40 Gb/s stabilito: il tuo cavo è un cavo Thunderbolt/USB4 a piena velocità.",
        portSlow: "Collegamento a %@. Il cavo potrebbe essere passivo o lento.",
        tbDevice: "Dispositivo Thunderbolt",
        tbConnection: "Collegamento Thunderbolt: %@.",

        charge: "Ricarica",
        adapterNotConnected: "Nessun alimentatore collegato",
        adapterNotConnectedNote: "Nessun caricatore collegato. Quando ne colleghi uno, qui vedrai quanti watt eroga e se il cavo lo sta limitando.",
        adapterFullPower: "L'alimentatore da %d W eroga piena potenza (%@ W negoziati). Il tuo cavo la trasporta senza problemi.",
        adapterBatteryFull: "Al momento assorbe %@ W. La batteria è al %d %%, quindi il Mac chiede poca potenza: è normale.",
        adapterLimited: "L'alimentatore è da %d W ma arrivano solo %@ W. Il cavo potrebbe essere limitato (60 W) o non inserito bene.",
        adapterProfile: "Profilo negoziato: %@ V · %@ A.",
        adapterProfiles: "Profili offerti dall'alimentatore: %@.",
        powerAdapterFallback: "Alimentatore",

        battery: "Batteria",
        batteryMaxCapacity: "capacità massima %@",
        batteryCycles: "%d cicli",
        chargingWithTime: "In carica — circa %d minuti al completamento.",
        charging: "In carica.",
        connectedNotCharging: "Alimentatore collegato ma non sta caricando ora (la batteria è già abbastanza carica).",
        batteryHealthGood: "La salute della batteria è buona.",
        batteryHealthWorn: "La capacità della batteria è scesa al %d %% del valore di progetto; potrebbe essere ora di sostituirla.",

        usbDeviceFallback: "Dispositivo USB",
        deviceVersionSuffix: "dispositivo %@",
        viaParent: "tramite %@",
        hubFast: "L'hub è collegato a %@; i dispositivi collegati condividono questa banda.",
        hubSlow: "L'hub è collegato alla velocità USB 2.0 (480 Mb/s); tutto ciò che ci colleghi sarà limitato a questa velocità.",
        deviceFast: "Collegato a %@: dispositivo, cavo e porta lavorano a piena capacità.",
        deviceOwnLimit: "Il dispositivo stesso è %@: 480 Mb/s è il suo tetto. Cavo e porta non c'entrano.",
        deviceHubLimit: "Il dispositivo supporta USB 3.x ma è collegato a 480 Mb/s. A limitarlo è l'%@ a monte (che lavora in USB 2.0).",
        deviceCableLimit: "Il dispositivo supporta USB 3.x ma si è collegato solo a 480 Mb/s. Il tuo cavo è quasi certamente di sola ricarica/USB 2.0: con uno dati andrebbe 10 volte più veloce.",
        linkSpeedUnknown: "Non è stato possibile leggere la velocità del collegamento, quindi non incolpo né il cavo né l'hub né il dispositivo.",

        externalDisplay: "Display esterno",
        displayCarriesVideo: "Questo cavo trasporta il video: %@.",
        displaySleeping: "Il display è in stop.",

        thunderboltUnavailable: "Su questa versione di macOS non è stato possibile leggere i dati delle porte Thunderbolt (manca il tipo di dati system_profiler previsto). Dispositivi USB e informazioni di alimentazione non sono interessati."
    )
}
