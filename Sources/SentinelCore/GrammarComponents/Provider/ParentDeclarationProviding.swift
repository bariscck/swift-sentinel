public protocol ParentDeclarationProviding: Declaration {
    var parent: Declaration? { get }
}
