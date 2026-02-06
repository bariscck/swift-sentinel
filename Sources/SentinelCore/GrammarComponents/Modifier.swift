import SwiftSyntax

public enum Modifier: String, DeclarationDecoration, Sendable, CaseIterable {
    case `public`
    case `private`
    case `fileprivate`
    case `internal`
    case open
    case package
    case `static`
    case `class`
    case `final`
    case `override`
    case `required`
    case `convenience`
    case `lazy`
    case `weak`
    case `unowned`
    case `mutating`
    case `nonmutating`
    case optional
    case nonisolated
    case indirect
    case `prefix`
    case `postfix`
    case `infix`
    case borrowing
    case consuming
    case isolated
    case distributed

    public var description: String {
        rawValue
    }

    public static func from(value: String) -> Modifier? {
        Modifier(rawValue: value)
    }

    public static func modifiers(from modifierList: DeclModifierListSyntax) -> [Modifier] {
        modifierList.compactMap { modifier in
            let name = modifier.name.text
            if let detail = modifier.detail?.detail.text {
                // Handle compound modifiers like private(set)
                return Modifier.from(value: "\(name)(\(detail))")
                    ?? Modifier.from(value: name)
            }
            return Modifier.from(value: name)
        }
    }
}
