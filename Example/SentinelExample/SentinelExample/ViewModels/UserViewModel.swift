import Foundation

// OK: Has @MainActor
// VIOLATION: Does not inherit from BaseViewModel
@MainActor
class UserViewModel {
    var user: User?
    var isLoading: Bool = false
    var errorMessage: String! = nil // VIOLATION: Force unwrap (ImplicitlyUnwrappedOptional)

    func fetchUser(id: UUID) {
        isLoading = true
    }

    func updateName(_ name: String) {
        user?.name = name
    }
}
