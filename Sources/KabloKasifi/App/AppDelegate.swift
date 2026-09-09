import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let args = CommandLine.arguments
        if let i = args.firstIndex(of: "--render"), i + 1 < args.count {
            MainActor.assumeIsolated { RenderPreview.run(path: args[i + 1]) }
            NSApp.terminate(nil)
            return
        }
        // Gerçek AppKit yerleşimiyle panel boyutunu ölç (MenuBarExtra ile aynı yol)
        if args.contains("--measure") {
            MainActor.assumeIsolated {
                ProbeStore.shared.refreshSynchronously()
                let view = PanelView()
                    .environmentObject(ProbeStore.shared)
                    .environmentObject(L10n.shared)
                let host = NSHostingView(rootView: view)
                host.layoutSubtreeIfNeeded()
                let fitting = host.fittingSize
                let text = "fittingSize: \(Int(fitting.width)) x \(Int(fitting.height))"
                print(text)
                let path = NSTemporaryDirectory() + "kk-measure.txt"
                try? text.write(toFile: path, atomically: true, encoding: .utf8)
                print("yazıldı: \(path)")
            }
            NSApp.terminate(nil)
            return
        }
        if args.contains("--doctor") {
            let text = SystemProbe.doctor()
            print(text)
            let path = NSTemporaryDirectory() + "kk-doctor.txt"
            try? text.write(toFile: path, atomically: true, encoding: .utf8)
            print("yazıldı: \(path)")
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
            let path = NSTemporaryDirectory() + "kk-print.txt"
            try? out.write(toFile: path, atomically: true, encoding: .utf8)
            print("yazıldı: \(path)")
            NSApp.terminate(nil)
            return
        }

        MainActor.assumeIsolated { ProbeStore.shared.startLiveMonitoring() }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool { true }
}
