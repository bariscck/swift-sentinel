import SwiftSyntax

public final class Parameter: NamedDeclaration, TypeProviding, SourceCodeProviding,
                              @unchecked Sendable {
    public let name: String
    public let label: String?
    public let typeAnnotation: TypeAnnotation?
    public let isVariadic: Bool
    public let sourceCodeLocation: SourceCodeLocation

    public var description: String {
        var result = ""
        if let label = label, label != name {
            result += "\(label) "
        }
        result += name
        if let type = typeAnnotation {
            result += ": \(type.name)"
        }
        if isVariadic {
            result += "..."
        }
        return result
    }

    init(functionParam: FunctionParameterSyntax) {
        let firstName = functionParam.firstName.text
        let secondName = functionParam.secondName?.text

        if let secondName = secondName {
            self.label = firstName == "_" ? nil : firstName
            self.name = secondName
        } else {
            self.label = nil
            self.name = firstName
        }

        self.typeAnnotation = TypeAnnotation(type: functionParam.type)
        self.isVariadic = functionParam.ellipsis != nil
        self.sourceCodeLocation = SourceCodeLocation(sourceFilePath: nil, sourceFileTree: functionParam)
    }

    init(enumCaseParam: EnumCaseParameterSyntax) {
        self.name = enumCaseParam.firstName?.text ?? ""
        self.label = enumCaseParam.secondName?.text
        self.typeAnnotation = TypeAnnotation(type: enumCaseParam.type)
        self.isVariadic = false
        self.sourceCodeLocation = SourceCodeLocation(sourceFilePath: nil, sourceFileTree: enumCaseParam)
    }
}
