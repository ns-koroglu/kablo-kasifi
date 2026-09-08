import Foundation

extension KKStrings {
    static let portuguese = KKStrings(
        tagline: "O que o cabo que você acabou de ligar realmente faz?",
        scanning: "Analisando…",
        noUSBDevices: "Sem dispositivos USB",
        usbDeviceCount: "%d dispositivos USB",
        displayCount: "%d telas",
        refresh: "Analisar de novo",
        badgeNew: "NOVO",
        launchAtLogin: "Abrir ao iniciar sessão",
        quit: "Sair",
        language: "Idioma",
        systemLanguage: "Idioma do sistema (%@)",
        percentFormat: "%d%%",

        sectionDevices: "Dispositivos conectados",
        sectionPower: "Energia",
        sectionDisplays: "Telas",
        sectionPorts: "Portas",
        emptyDevices: "Nenhum dispositivo USB no momento. Conecte um cabo e eu digo o que ele transporta.",

        portTitle: "Porta %@",
        portEmptySubtitle: "Livre · até %@",
        portEmptyNote: "As portas livres não têm nenhum dispositivo Thunderbolt/USB4. Dispositivos USB comuns aparecem na lista acima.",
        portDeviceConnected: "Dispositivo conectado",
        portFullSpeed: "Enlace de 40 Gb/s estabelecido — seu cabo é um cabo Thunderbolt/USB4 de velocidade total.",
        portSlow: "O enlace é %@. O cabo pode ser passivo ou de baixa velocidade.",
        tbDevice: "Dispositivo Thunderbolt",
        tbConnection: "Enlace Thunderbolt: %@.",

        charge: "Carga",
        adapterNotConnected: "Nenhum adaptador conectado",
        adapterNotConnectedNote: "Nenhum carregador conectado. Assim que ligar um, você verá quantos watts ele entrega e se o cabo está limitando.",
        adapterFullPower: "O adaptador de %d W está entregando potência total (%@ W negociados). Seu cabo transporta isso sem problemas.",
        adapterBatteryFull: "Consumindo %@ W agora. A bateria está em %d %%, então o Mac pede pouca energia — isso é normal.",
        adapterLimited: "O adaptador é de %d W, mas só chegam %@ W. O cabo pode ser limitado (60 W) ou não estar bem encaixado.",
        adapterProfile: "Perfil negociado: %@ V · %@ A.",
        adapterProfiles: "Perfis oferecidos pelo adaptador: %@.",
        powerAdapterFallback: "Fonte de alimentação",

        battery: "Bateria",
        batteryMaxCapacity: "capacidade máxima %@",
        batteryCycles: "%d ciclos",
        chargingWithTime: "Carregando — cerca de %d minutos para completar.",
        charging: "Carregando.",
        connectedNotCharging: "Adaptador conectado, mas sem carregar agora (a bateria já está cheia o bastante).",
        batteryHealthGood: "A saúde da bateria está boa.",
        batteryHealthWorn: "A capacidade da bateria caiu para %d %% do valor de projeto; a troca pode estar próxima.",

        usbDeviceFallback: "Dispositivo USB",
        deviceVersionSuffix: "dispositivo %@",
        viaParent: "através de %@",
        hubFast: "O hub está conectado a %@; os dispositivos ligados a ele dividem essa banda.",
        hubSlow: "O hub está conectado na velocidade USB 2.0 (480 Mb/s); tudo que você ligar nele fica limitado a essa velocidade.",
        deviceFast: "Conectado a %@ — dispositivo, cabo e porta trabalhando em plena capacidade.",
        deviceOwnLimit: "O próprio dispositivo é %@ — 480 Mb/s é o teto dele. O cabo e a porta não têm culpa.",
        deviceHubLimit: "O dispositivo suporta USB 3.x, mas está ligado a 480 Mb/s. Quem limita é o %@ acima dele (rodando em USB 2.0).",
        deviceCableLimit: "O dispositivo suporta USB 3.x, mas só negociou 480 Mb/s. Seu cabo provavelmente é só de carga/USB 2.0 — com um cabo de dados ficaria 10× mais rápido.",

        externalDisplay: "Tela externa",
        displayCarriesVideo: "Este cabo transporta vídeo: %@.",
        displaySleeping: "A tela está em repouso.",

        thunderboltUnavailable: "Não foi possível ler os dados das portas Thunderbolt nesta versão do macOS (o tipo de dados esperado do system_profiler não existe). Dispositivos USB e informações de energia não são afetados."
    )
}
