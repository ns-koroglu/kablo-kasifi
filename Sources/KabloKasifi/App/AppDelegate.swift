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
        if args.contains("--doctor") {
            let text = SystemProbe.doctor()
            print(text)
            try? text.write(toFile: "/tmp/kk-doctor.txt", atomically: true, encoding: .utf8)
            NSApp.terminate(nil)
            return
        }
        if args.contains("--print") {
            let r = SystemProbe.probe(L10n.shared.s)
            var out = ""
            for c in r.all {
                out += "• [\(c.kind.rawValue)] \(c.title) \(c.badge.map { "(\($0))" } ?? "") — \(c.subtitle)\n"
                for v in c.verdicts { out += "    - \(v.text)\n" }
            }
            out += "\n" + SystemProbe.doctor() + "\n" 
            print(out)
            try? out.write(toFile: "/tmp/kk-print.txt", atomically: true, encoding: .utf8)
            NSApp.terminate(nil)
            return
        }

        MainActor.assumeIsolated { ProbeStore.shared.refresh() }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool { true }
}
