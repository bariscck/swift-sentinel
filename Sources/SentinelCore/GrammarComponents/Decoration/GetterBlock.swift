import SwiftSyntax

public struct GetterBlock: DeclarationDecoration, Sendable {
    public let body: Body?

    public var description: String {
        "getter"
    }

    init?(from accessorBlock: AccessorBlockSyntax?) {
        guard let block = accessorBlock else { return nil }
        switch block.accessors {
        case .getter(let codeBlock):
            self.body = Body(codeBlock: codeBlock)
        case .accessors(let list):
            guard let getter = list.first(where: { $0.accessorSpecifier.text == "get" }) else {
                return nil
            }
            self.body = getter.body.map { Body(codeBlock: $0.statements) }
        }
    }
}
