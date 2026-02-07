import Foundation

class BaseViewModel {
    var isLoading: Bool = false
    var error: Error?

    func handleError(_ error: Error) {
        self.error = error
        isLoading = false
    }
}
