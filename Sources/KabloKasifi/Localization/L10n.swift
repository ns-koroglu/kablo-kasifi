import SwiftUI

/// Aktif dili tutar. "system" seçiliyken sistem diline uyar,
/// sistem dili desteklenmiyorsa Türkçe kullanılır.
@MainActor
final class L10n: ObservableObject {
    static let shared = L10n()
    static let systemKey = "system"

    /// "system" ya da bir AppLanguage.rawValue
    @Published var selection: String {
        didSet {
            UserDefaults.standard.set(selection, forKey: "language")
            refresh()
        }
    }

    @Published private(set) var current: AppLanguage = .tr
    @Published private(set) var s: KKStrings = .turkish

    private init() {
        selection = UserDefaults.standard.string(forKey: "language") ?? L10n.systemKey
        refresh()
        // Kullanıcı sistem dilini değiştirirse (uygulama açıkken) yakala
        NotificationCenter.default.addObserver(
            forName: NSLocale.currentLocaleDidChangeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.refresh() }
        }
    }

    private func refresh() {
        let language = (selection == L10n.systemKey)
            ? AppLanguage.fromSystem()
            : (AppLanguage(rawValue: selection) ?? .tr)
        current = language
        s = KKStrings.table[language] ?? .turkish
    }

    /// Sistem seçiliyken listede hangi dilin etkin olduğunu göstermek için
    var systemResolvedName: String { AppLanguage.fromSystem().nativeName }
}

/// Kısa erişim: `T.s.sectionPorts`
enum T {
    @MainActor static var s: KKStrings { L10n.shared.s }
}
