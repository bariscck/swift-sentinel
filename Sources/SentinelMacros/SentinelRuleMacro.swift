import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct SentinelRuleMacro: MemberMacro, ExtensionMacro {

    // MARK: - ExtensionMacro

    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard !protocols.isEmpty else { return [] }

        let ext: DeclSyntax = "extension \(type.trimmed): Rule {}"
        return [ext.cast(ExtensionDeclSyntax.self)]
    }

    // MARK: - MemberMacro

    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let arguments = node.arguments?.as(LabeledExprListSyntax.self) else {
            context.diagnose(Diagnostic(
                node: node,
                message: SentinelMacroDiagnostic(
                    message: "@SentinelRule requires (severity, id:) arguments",
                    id: "missing-arguments",
                    severity: .error
                )
            ))
            return []
        }

        let argList = Array(arguments)

        guard argList.count >= 2 else {
            context.diagnose(Diagnostic(
                node: node,
                message: SentinelMacroDiagnostic(
                    message: "@SentinelRule requires severity and id arguments",
                    id: "insufficient-arguments",
                    severity: .error
                )
            ))
            return []
        }

        // First argument: severity (positional, e.g. .warning)
        let severityExpr = argList[0].expression.trimmedDescription

        // Second argument: id (labeled "id")
        guard argList[1].label?.trimmedDescription == "id",
              let idLiteral = argList[1].expression.as(StringLiteralExprSyntax.self) else {
            context.diagnose(Diagnostic(
                node: node,
                message: SentinelMacroDiagnostic(
                    message: "@SentinelRule requires 'id' parameter as second argument",
                    id: "missing-id",
                    severity: .error
                )
            ))
            return []
        }

        let idValue = idLiteral.segments.trimmedDescription

        return [
            "var identifier: String { \(literal: idValue) }",
            "var severity: Severity { \(raw: severityExpr) }",
        ]
    }
}

private struct SentinelMacroDiagnostic: DiagnosticMessage {
    let message: String
    let id: String
    let severity: DiagnosticSeverity

    var diagnosticID: MessageID {
        MessageID(domain: "SentinelMacros", id: id)
    }
}
