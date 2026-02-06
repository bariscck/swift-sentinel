import SwiftSyntax

public struct AccessorBlock: DeclarationDecoration, Sendable {
    public enum Kind: String, Sendable {
        case get
        case set
        case willSet
        case didSet
        case `init`
        case _read
        case _modify
        case unsafeAddress
        case unsafeMutableAddress
    }

    public let kind: Kind
    public let body: Body?

    public var description: String {
        kind.rawValue
    }

    init?(accessor: AccessorDeclSyntax) {
        guard let kind = Kind(rawValue: accessor.accessorSpecifier.text) else {
            return nil
        }
        self.kind = kind
        self.body = accessor.body.map { Body(codeBlock: $0.statements) }
    }

    public static func accessors(from block: AccessorBlockSyntax?) -> [AccessorBlock] {
        guard let block = block else { return [] }
        switch block.accessors {
        case .accessors(let list):
            return list.compactMap { AccessorBlock(accessor: $0) }
        case .getter:
            return []
        }
    }
}
