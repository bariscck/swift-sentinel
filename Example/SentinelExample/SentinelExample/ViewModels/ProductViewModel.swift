import Foundation

// VIOLATION: Missing @MainActor annotation
// OK: Inherits from BaseViewModel
@MainActor
class ProductViewModel: BaseViewModel {
    var products: [Product] = []
    var selectedProduct: Product?

    func fetchProducts() {
        // fetch logic
    }

    func selectProduct(_ product: Product) {
        selectedProduct = product
    }
}
