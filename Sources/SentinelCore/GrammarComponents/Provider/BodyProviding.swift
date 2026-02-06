public protocol BodyProviding: Declaration {
    var body: Body? { get }
}

extension BodyProviding {
    public var hasBody: Bool {
        body != nil
    }

    public var isEmptyBody: Bool {
        guard let body = body else { return true }
        return body.content.removingLeadingTrailingWhitespace().isEmpty
    }

    public var functionCalls: [FunctionCall] {
        body?.functionCalls ?? []
    }

    public var refersToSelf: Bool {
        body?.hasAnySelfReference ?? false
    }
}
