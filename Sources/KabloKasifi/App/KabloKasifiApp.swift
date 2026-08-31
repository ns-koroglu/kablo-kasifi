import SwiftUI

@main
struct KabloKasifiApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @StateObject private var store = ProbeStore.shared

    var body: some Scene {
        MenuBarExtra {
            PanelView().environmentObject(store)
        } label: {
            HStack(spacing: 3) {
                Image(systemName: "cable.connector")
                if let text = store.menuBarText {
                    Text(text).font(.system(size: 11, weight: .medium))
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
