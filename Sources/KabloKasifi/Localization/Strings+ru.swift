import Foundation

extension KKStrings {
    static let russian = KKStrings(
        tagline: "На что на самом деле способен только что подключённый кабель?",
        scanning: "Сканирование…",
        noUSBDevices: "USB-устройств нет",
        usbDeviceCount: "%d USB-устройств",
        displayCount: "%d дисплеев",
        refresh: "Сканировать снова",
        badgeNew: "НОВОЕ",
        launchAtLogin: "Запускать при входе",
        quit: "Выйти",
        language: "Язык",
        systemLanguage: "Язык системы (%@)",
        percentFormat: "%d%%",

        sectionDevices: "Подключённые устройства",
        sectionPower: "Питание",
        sectionDisplays: "Дисплеи",
        sectionPorts: "Порты",
        emptyDevices: "Сейчас USB-устройств нет. Подключите кабель — и я расскажу, что он передаёт.",

        portTitle: "Порт %@",
        portEmptySubtitle: "Свободен · до %@",
        portEmptyNote: "В свободных портах нет устройств Thunderbolt/USB4. Обычные USB-устройства показаны в списке выше.",
        portDeviceConnected: "Устройство подключено",
        portFullSpeed: "Установлено соединение 40 Гбит/с — у вас полноценный кабель Thunderbolt/USB4.",
        portSlow: "Соединение: %@. Кабель может быть пассивным или медленным.",
        tbDevice: "Устройство Thunderbolt",
        tbConnection: "Соединение Thunderbolt: %@.",

        charge: "Зарядка",
        adapterNotConnected: "Адаптер не подключён",
        adapterNotConnectedNote: "Зарядка не подключена. Как только подключите, здесь будет видно, сколько ватт отдаёт адаптер и не ограничивает ли их кабель.",
        adapterFullPower: "Адаптер %d Вт отдаёт полную мощность (согласовано %@ Вт). Кабель передаёт её без проблем.",
        adapterBatteryFull: "Сейчас потребляется %@ Вт. Батарея заряжена на %d %%, поэтому Mac просит мало мощности — это нормально.",
        adapterLimited: "Адаптер на %d Вт, но приходит только %@ Вт. Кабель может быть ограничен (60 Вт) или неплотно вставлен.",
        adapterProfile: "Согласованный профиль: %@ В · %@ А.",
        adapterProfiles: "Профили адаптера: %@.",
        powerAdapterFallback: "Блок питания",

        battery: "Батарея",
        batteryMaxCapacity: "максимальная ёмкость %@",
        batteryCycles: "%d циклов",
        chargingWithTime: "Заряжается — примерно %d минут до полного заряда.",
        charging: "Заряжается.",
        connectedNotCharging: "Адаптер подключён, но зарядка сейчас не идёт (батарея достаточно заряжена).",
        batteryHealthGood: "Состояние батареи хорошее.",
        batteryHealthWorn: "Ёмкость батареи упала до %d %% от исходной; возможно, пора её менять.",

        usbDeviceFallback: "USB-устройство",
        deviceVersionSuffix: "устройство %@",
        viaParent: "через %@",
        hubFast: "Хаб подключён на скорости %@; устройства за ним делят эту полосу.",
        hubSlow: "Хаб подключён на скорости USB 2.0 (480 Мбит/с); всё, что вы в него включите, будет ограничено этой скоростью.",
        deviceFast: "Подключено на %@ — устройство, кабель и порт работают на полную.",
        deviceOwnLimit: "Само устройство — %@, и 480 Мбит/с это его собственный потолок. Кабель и порт ни при чём.",
        deviceHubLimit: "Устройство поддерживает USB 3.x, но подключено на 480 Мбит/с. Ограничивает %@ перед ним (работает как USB 2.0).",
        deviceCableLimit: "Устройство поддерживает USB 3.x, но соединение всего 480 Мбит/с. Скорее всего, у вас кабель только для зарядки (USB 2.0) — с кабелем для данных будет в 10 раз быстрее.",

        externalDisplay: "Внешний дисплей",
        displayCarriesVideo: "Этот кабель передаёт видео: %@.",
        displaySleeping: "Дисплей сейчас спит.",

        thunderboltUnavailable: "В этой версии macOS не удалось прочитать данные портов Thunderbolt (нет ожидаемого типа данных system_profiler). На USB-устройства и информацию о питании это не влияет."
    )
}
