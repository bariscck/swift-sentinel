import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SentinelMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        SentinelRuleMacro.self,
    ]
}
