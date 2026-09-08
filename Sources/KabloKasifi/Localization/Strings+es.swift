import Foundation

extension KKStrings {
    static let spanish = KKStrings(
        tagline: "¿Qué puede hacer realmente el cable que acabas de conectar?",
        scanning: "Analizando…",
        noUSBDevices: "Sin dispositivos USB",
        usbDeviceCount: "%d dispositivos USB",
        displayCount: "%d pantallas",
        refresh: "Volver a analizar",
        badgeNew: "NUEVO",
        launchAtLogin: "Abrir al iniciar sesión",
        quit: "Salir",
        language: "Idioma",
        systemLanguage: "Idioma del sistema (%@)",
        percentFormat: "%d%%",

        sectionDevices: "Dispositivos conectados",
        sectionPower: "Alimentación",
        sectionDisplays: "Pantallas",
        sectionPorts: "Puertos",
        emptyDevices: "Ahora mismo no hay dispositivos USB. Conecta un cable y te diré qué transporta.",

        portTitle: "Puerto %@",
        portEmptySubtitle: "Libre · hasta %@",
        portEmptyNote: "Los puertos libres no tienen ningún dispositivo Thunderbolt/USB4. Los dispositivos USB normales aparecen en la lista de arriba.",
        portDeviceConnected: "Dispositivo conectado",
        portFullSpeed: "Enlace de 40 Gb/s establecido: tu cable es un cable Thunderbolt/USB4 de velocidad completa.",
        portSlow: "El enlace es %@. El cable puede ser pasivo o de baja velocidad.",
        tbDevice: "Dispositivo Thunderbolt",
        tbConnection: "Enlace Thunderbolt: %@.",

        charge: "Carga",
        adapterNotConnected: "Sin adaptador conectado",
        adapterNotConnectedNote: "No hay cargador conectado. Cuando conectes uno, verás cuántos vatios entrega y si el cable lo está limitando.",
        adapterFullPower: "El adaptador de %d W entrega toda su potencia (%@ W negociados). Tu cable la transporta sin problema.",
        adapterBatteryFull: "Ahora mismo consume %@ W. La batería está al %d %%, así que el Mac pide poca potencia: es normal.",
        adapterLimited: "El adaptador es de %d W pero solo llegan %@ W. El cable puede estar limitado (60 W) o no estar bien conectado.",
        adapterProfile: "Perfil negociado: %@ V · %@ A.",
        adapterProfiles: "Perfiles que ofrece el adaptador: %@.",
        powerAdapterFallback: "Adaptador de corriente",

        battery: "Batería",
        batteryMaxCapacity: "capacidad máxima %@",
        batteryCycles: "%d ciclos",
        chargingWithTime: "Cargando: unos %d minutos hasta completarse.",
        charging: "Cargando.",
        connectedNotCharging: "Adaptador conectado pero sin cargar ahora mismo (la batería está bastante llena).",
        batteryHealthGood: "El estado de la batería es bueno.",
        batteryHealthWorn: "La capacidad de la batería ha bajado al %d %% de su valor de diseño; puede tocar sustituirla.",

        usbDeviceFallback: "Dispositivo USB",
        deviceVersionSuffix: "dispositivo %@",
        viaParent: "a través de %@",
        hubFast: "El hub está conectado a %@; los dispositivos que cuelgan de él comparten ese ancho de banda.",
        hubSlow: "El hub está conectado a velocidad USB 2.0 (480 Mb/s); todo lo que conectes a él quedará limitado a esa velocidad.",
        deviceFast: "Conectado a %@: dispositivo, cable y puerto funcionan a pleno rendimiento.",
        deviceOwnLimit: "El dispositivo en sí es %@: 480 Mb/s es su propio techo. El cable y el puerto no tienen la culpa.",
        deviceHubLimit: "El dispositivo admite USB 3.x pero está enlazado a 480 Mb/s. Lo limita el %@ que tiene por encima (a velocidad USB 2.0).",
        deviceCableLimit: "El dispositivo admite USB 3.x pero solo se ha enlazado a 480 Mb/s. Lo más probable es que tu cable sea de solo carga/USB 2.0: con uno de datos iría 10 veces más rápido.",

        externalDisplay: "Pantalla externa",
        displayCarriesVideo: "Este cable transporta vídeo: %@.",
        displaySleeping: "La pantalla está en reposo.",

        thunderboltUnavailable: "No se han podido leer los datos de los puertos Thunderbolt en esta versión de macOS (falta el tipo de datos de system_profiler esperado). Los dispositivos USB y la información de alimentación no se ven afectados."
    )
}
