import Foundation

extension KKStrings {
    static let english = KKStrings(
        tagline: "What can that cable you just plugged in actually do?",
        scanning: "Scanning…",
        noUSBDevices: "No USB devices",
        usbDeviceCount: "%d USB devices",
        usbDeviceCountOne: "1 USB device",
        displayCount: "%d displays",
        displayCountOne: "1 display",
        refresh: "Scan again",
        badgeNew: "NEW",
        launchAtLogin: "Launch at login",
        quit: "Quit",
        language: "Language",
        systemLanguage: "System language (%@)",
        percentFormat: "%d%%",

        sectionDevices: "Connected devices",
        sectionPower: "Power",
        sectionDisplays: "Displays",
        sectionPorts: "Ports",
        emptyDevices: "No USB devices right now. Plug a cable in and I'll tell you what it carries.",

        portTitle: "Port %@",
        portEmptySubtitle: "Empty · up to %@",
        portEmptyNote: "Empty ports have no Thunderbolt/USB4 device. Regular USB devices appear in the list above.",
        portDeviceConnected: "Device connected",
        portFullSpeed: "40 Gb/s link established — your cable is a full-speed Thunderbolt/USB4 cable.",
        portSlow: "Link is %@. The cable may be passive or low-speed.",
        tbDevice: "Thunderbolt device",
        tbConnection: "Thunderbolt link: %@.",

        charge: "Charging",
        adapterNotConnected: "No adapter connected",
        adapterNotConnectedNote: "No charger plugged in. Once you connect one, you'll see how many watts it delivers and whether the cable is limiting it.",
        adapterFullPower: "The %d W adapter is delivering full power (%@ W negotiated). Your cable carries it without trouble.",
        adapterBatteryFull: "Currently drawing %@ W. The battery is at %d%%, so the Mac needs little power — this is normal.",
        adapterLimited: "The adapter is %d W but only %@ W is coming through. The cable may be power-limited (60 W) or not fully seated.",
        adapterProfile: "Negotiated profile: %@ V · %@ A.",
        adapterProfiles: "Profiles offered by the adapter: %@.",
        powerAdapterFallback: "Power adapter",

        battery: "Battery",
        batteryMaxCapacity: "maximum capacity %@",
        batteryCycles: "%d cycles",
        chargingWithTime: "Charging — about %d minutes to full.",
        charging: "Charging.",
        connectedNotCharging: "Adapter connected but not charging right now (battery is full enough).",
        batteryHealthGood: "Battery health is good.",
        batteryHealthWorn: "Battery capacity has dropped to %d%% of its design value; a replacement may be due.",

        usbDeviceFallback: "USB device",
        deviceVersionSuffix: "%@ device",
        viaParent: "via %@",
        hubFast: "Hub is connected at %@; devices behind it share that bandwidth.",
        hubSlow: "Hub is connected at USB 2.0 speed (480 Mb/s); everything you plug into it is capped at that speed.",
        deviceFast: "Connected at %@ — device, cable and port are all running at full capacity.",
        deviceOwnLimit: "The device itself is %@ — 480 Mb/s is its own ceiling. The cable and port are not at fault.",
        deviceHubLimit: "The device supports USB 3.x but is linked at 480 Mb/s. The limit comes from the %@ above it (running at USB 2.0).",
        deviceCableLimit: "The device supports USB 3.x but only linked at 480 Mb/s. Your cable is most likely a charge-only/USB 2.0 cable — a data cable would make it 10× faster.",
        linkSpeedUnknown: "The link speed could not be read, so I won't blame the cable, hub or device.",

        externalDisplay: "External display",
        displayCarriesVideo: "This cable carries video: %@.",
        displaySleeping: "The display is asleep right now.",

        thunderboltUnavailable: "Thunderbolt port data could not be read on this macOS version (the expected system_profiler data type is missing). USB devices and power info are unaffected."
    )
}
