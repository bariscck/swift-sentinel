import Foundation

// OK: Has @MainActor
// OK: Inherits from BaseViewModel
@MainActor
class SettingsViewModel: BaseViewModel {
    var isDarkMode: Bool = false
    var notificationsEnabled: Bool = true
    var language: String = "en"

    func toggleDarkMode() {
        isDarkMode.toggle()
    }

    func updateLanguage(_ lang: String) {
        language = lang
    }
}
