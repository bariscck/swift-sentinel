import Testing
@testable import SentinelCore

@Test func parsesClassDeclaration() {
    let source = """
    class MyClass: BaseClass {
        var name: String = ""
        func doSomething() {}
    }
    """
    let scope = Sentinel.on(source: source)
    let classes = scope.classes()
    #expect(classes.count == 1)
    #expect(classes[0].name == "MyClass")
    #expect(classes[0].inherits(from: "BaseClass"))
    #expect(classes[0].variables().count == 1)
    #expect(classes[0].functions().count == 1)
}

@Test func parsesStructDeclaration() {
    let source = """
    struct MyStruct: Codable {
        let id: Int
        var name: String
    }
    """
    let scope = Sentinel.on(source: source)
    let structs = scope.structs()
    #expect(structs.count == 1)
    #expect(structs[0].name == "MyStruct")
    #expect(structs[0].conforms(to: "Codable"))
    #expect(structs[0].variables().count == 2)
}

@Test func parsesEnumDeclaration() {
    let source = """
    enum Direction: String {
        case north
        case south
        case east
        case west
    }
    """
    let scope = Sentinel.on(source: source)
    let enums = scope.enums()
    #expect(enums.count == 1)
    #expect(enums[0].name == "Direction")
    #expect(enums[0].conforms(to: "String"))
}

@Test func parsesProtocolDeclaration() {
    let source = """
    protocol MyProtocol {
        var name: String { get }
        func doWork()
    }
    """
    let scope = Sentinel.on(source: source)
    let protocols = scope.protocols()
    #expect(protocols.count == 1)
    #expect(protocols[0].name == "MyProtocol")
}

@Test func parsesFunctionDeclaration() {
    let source = """
    func calculate(x: Int, y: Int) -> Int {
        return x + y
    }
    """
    let scope = Sentinel.on(source: source)
    let functions = scope.functions()
    #expect(functions.count == 1)
    #expect(functions[0].name == "calculate")
    #expect(functions[0].parameters.count == 2)
    #expect(functions[0].returnClause?.typeName == "Int")
}

@Test func parsesVariableDeclaration() {
    let source = """
    let constant: String = "hello"
    var variable: Int = 42
    var optional: String?
    """
    let scope = Sentinel.on(source: source)
    let vars = scope.variables()
    #expect(vars.count == 3)
    #expect(vars[0].isConstant == true)
    #expect(vars[1].isVariable == true)
    #expect(vars[2].isOptional == true)
}

@Test func parsesAttributes() {
    let source = """
    @MainActor
    class ViewModel {
        @Published var name: String = ""
    }
    """
    let scope = Sentinel.on(source: source)
    let classes = scope.classes()
    #expect(classes[0].hasAttribute(named: "MainActor"))
    let vars = classes[0].variables()
    #expect(vars[0].hasAttribute(named: "Published"))
}

@Test func parsesModifiers() {
    let source = """
    public final class Service {
        private var data: [String] = []
        public static func shared() -> Service { Service() }
    }
    """
    let scope = Sentinel.on(source: source)
    let classes = scope.classes()
    #expect(classes[0].isPublic)
    #expect(classes[0].isFinal)
    let vars = classes[0].variables()
    #expect(vars[0].isPrivate)
    let funcs = classes[0].functions()
    #expect(funcs[0].isPublic)
    #expect(funcs[0].isStatic)
}

@Test func parsesExtensions() {
    let source = """
    extension String {
        func trimmed() -> String {
            trimmingCharacters(in: .whitespaces)
        }
    }
    """
    let scope = Sentinel.on(source: source)
    let extensions = scope.extensions()
    #expect(extensions.count == 1)
    #expect(extensions[0].typeAnnotation.name == "String")
}

@Test func parsesImports() {
    let source = """
    import Foundation
    import UIKit
    """
    let scope = Sentinel.on(source: source)
    let imports = scope.imports()
    #expect(imports.count == 2)
    #expect(imports[0].name == "Foundation")
    #expect(imports[1].name == "UIKit")
}

@Test func parsesNestedDeclarations() {
    let source = """
    class Outer {
        class Inner {
            var value: Int = 0
        }
        struct NestedStruct {}
    }
    """
    let scope = Sentinel.on(source: source)
    #expect(scope.classes().count == 1)  // Only top-level
    #expect(scope.classes(includeNested: true).count == 2)
    #expect(scope.structs(includeNested: true).count == 1)
}
