import Foundation

// VIOLATION: Missing @MainActor annotation
// VIOLATION: Does not inherit from BaseViewModel
class UserViewModel {
    var user: User?
    var isLoading: Bool = false
    var errorMessage: String! = nil // VIOLATION: Force unwrap

    func fetchUser(id: UUID) {
        isLoading = true
    }

    func updateName(_ name: String) {
        user?.name = name
    }
}
