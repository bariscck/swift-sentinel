public protocol FunctionCallsProviding: Declaration {
    var functionCalls: [FunctionCall] { get }
}
