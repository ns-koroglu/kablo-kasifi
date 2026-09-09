import Foundation

extension KKStrings {
    static let french = KKStrings(
        tagline: "Que sait vraiment faire le câble que tu viens de brancher ?",
        scanning: "Analyse en cours…",
        noUSBDevices: "Aucun périphérique USB",
        usbDeviceCount: "%d périphériques USB",
        usbDeviceCountOne: "1 périphérique USB",
        displayCount: "%d écrans",
        displayCountOne: "1 écran",
        refresh: "Analyser à nouveau",
        badgeNew: "NOUVEAU",
        launchAtLogin: "Ouvrir à la session",
        quit: "Quitter",
        language: "Langue",
        systemLanguage: "Langue du système (%@)",
        percentFormat: "%d%%",

        sectionDevices: "Périphériques connectés",
        sectionPower: "Alimentation",
        sectionDisplays: "Écrans",
        sectionPorts: "Ports",
        emptyDevices: "Aucun périphérique USB pour l'instant. Branche un câble et je te dirai ce qu'il transporte.",

        portTitle: "Port %@",
        portEmptySubtitle: "Libre · jusqu'à %@",
        portEmptyNote: "Les ports libres n'ont aucun périphérique Thunderbolt/USB4. Les périphériques USB classiques figurent dans la liste ci-dessus.",
        portDeviceConnected: "Périphérique connecté",
        portFullSpeed: "Liaison à 40 Gb/s établie — ton câble est un vrai câble Thunderbolt/USB4.",
        portSlow: "Liaison à %@. Le câble est peut-être passif ou lent.",
        tbDevice: "Périphérique Thunderbolt",
        tbConnection: "Liaison Thunderbolt : %@.",

        charge: "Charge",
        adapterNotConnected: "Aucun adaptateur connecté",
        adapterNotConnectedNote: "Aucun chargeur branché. Dès que tu en branches un, tu verras combien de watts il délivre et si le câble le bride.",
        adapterFullPower: "L'adaptateur de %d W délivre toute sa puissance (%@ W négociés). Ton câble la transporte sans problème.",
        adapterBatteryFull: "Actuellement %@ W consommés. La batterie est à %d %%, le Mac demande donc peu de puissance : c'est normal.",
        adapterLimited: "L'adaptateur fait %d W mais seulement %@ W arrivent. Le câble est peut-être limité (60 W) ou mal enfoncé.",
        adapterProfile: "Profil négocié : %@ V · %@ A.",
        adapterProfiles: "Profils proposés par l'adaptateur : %@.",
        powerAdapterFallback: "Adaptateur secteur",

        battery: "Batterie",
        batteryMaxCapacity: "capacité maximale %@",
        batteryCycles: "%d cycles",
        chargingWithTime: "En charge — environ %d minutes avant la charge complète.",
        charging: "En charge.",
        connectedNotCharging: "Adaptateur branché mais pas de charge en cours (la batterie est suffisamment pleine).",
        batteryHealthGood: "L'état de la batterie est bon.",
        batteryHealthWorn: "La capacité de la batterie est tombée à %d %% de sa valeur d'origine ; un remplacement approche peut-être.",

        usbDeviceFallback: "Périphérique USB",
        deviceVersionSuffix: "périphérique %@",
        viaParent: "via %@",
        hubFast: "Le hub est connecté en %@ ; les périphériques branchés dessus partagent cette bande passante.",
        hubSlow: "Le hub est connecté à la vitesse USB 2.0 (480 Mb/s) ; tout ce que tu y branches sera bridé à cette vitesse.",
        deviceFast: "Connecté en %@ — périphérique, câble et port fonctionnent à pleine capacité.",
        deviceOwnLimit: "Le périphérique lui-même est %@ : 480 Mb/s est son propre plafond. Ni le câble ni le port ne sont en cause.",
        deviceHubLimit: "Le périphérique gère l'USB 3.x mais négocie 480 Mb/s. C'est le %@ en amont qui limite (il fonctionne en USB 2.0).",
        deviceCableLimit: "Le périphérique gère l'USB 3.x mais ne négocie que 480 Mb/s. Ton câble est très probablement un câble de charge/USB 2.0 — un câble de données le rendrait 10× plus rapide.",
        linkSpeedUnknown: "La vitesse de liaison n'a pas pu être lue : je n'accuse donc ni le câble, ni le hub, ni le périphérique.",
        usbVersionUnknown: "version USB inconnue",

        externalDisplay: "Écran externe",
        displayCarriesVideo: "Ce câble transporte la vidéo : %@.",
        displaySleeping: "L'écran est en veille.",

        thunderboltUnavailable: "Les données des ports Thunderbolt n'ont pas pu être lues sur cette version de macOS (type de données system_profiler attendu introuvable). Les périphériques USB et les informations d'alimentation ne sont pas affectés."
    )
}
