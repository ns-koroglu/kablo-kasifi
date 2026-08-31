import SwiftUI
import AppKit

/// `--render <yol.png>` ile paneli dosyaya çizer (tasarım kontrolü için).
@MainActor
enum RenderPreview {
    static func run(path: String) {
        let store = ProbeStore.shared
        store.refreshSynchronously()

        let view = PanelView(scrollable: false)
            .environmentObject(store)
            .frame(width: 380)
            .background(Color(nsColor: .windowBackgroundColor))

        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        guard let image = renderer.nsImage,
              let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let png = rep.representation(using: .png, properties: [:]) else {
            FileHandle.standardError.write(Data("çizim başarısız\n".utf8))
            return
        }
        try? png.write(to: URL(fileURLWithPath: path))
        print("yazıldı: \(path)")
    }
}
