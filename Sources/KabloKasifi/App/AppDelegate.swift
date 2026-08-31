import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let args = CommandLine.arguments
        if let i = args.firstIndex(of: "--render"), i + 1 < args.count {
            MainActor.assumeIsolated { RenderPreview.run(path: args[i + 1]) }
            NSApp.terminate(nil)
            return
        }
        if args.contains("--print") {
            let r = SystemProbe.probe()
            for c in r.all {
                print("• [\(c.kind.rawValue)] \(c.title) \(c.badge.map { "(\($0))" } ?? "") — \(c.subtitle)")
                for v in c.verdicts { print("    - \(v.text)") }
            }
            NSApp.terminate(nil)
            return
        }

        MainActor.assumeIsolated { ProbeStore.shared.refresh() }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool { true }
}
