import Foundation

// Placeholder for SwiftUI views
// In a real project these would import SwiftUI

struct ContentView {
    let viewModel: UserViewModel

    func body() -> String {
        "Hello, \(viewModel.user?.name ?? "World")"
    }
}

@MainActor
struct SettingsView {
    let viewModel: SettingsViewModel

    func body() -> String {
        "Settings: Dark Mode = \(viewModel.isDarkMode)"
    }
}
