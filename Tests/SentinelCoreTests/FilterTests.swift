import Testing
@testable import SentinelCore

@Test func filterByName() {
    let source = """
    class UserViewModel {}
    class ProductViewModel {}
    class UserService {}
    """
    let scope = Sentinel.on(source: source)
    let viewModels = scope.classes().withNameEndingWith("ViewModel")
    #expect(viewModels.count == 2)

    let userTypes = scope.classes().withNameStartingWith("User")
    #expect(userTypes.count == 2)

    let exact = scope.classes().withName("UserService")
    #expect(exact.count == 1)
}

@Test func filterByAttribute() {
    let source = """
    @MainActor class AnnotatedVM {}
    class PlainVM {}
    """
    let scope = Sentinel.on(source: source)
    let annotated = scope.classes().withAttribute(named: "MainActor")
    #expect(annotated.count == 1)
    #expect(annotated[0].name == "AnnotatedVM")

    let notAnnotated = scope.classes().withoutAttribute(named: "MainActor")
    #expect(notAnnotated.count == 1)
    #expect(notAnnotated[0].name == "PlainVM")
}

@Test func filterByModifier() {
    let source = """
    public class PublicClass {}
    private class PrivateClass {}
    final class FinalClass {}
    """
    let scope = Sentinel.on(source: source)
    #expect(scope.classes().withPublicModifier().count == 1)
    #expect(scope.classes().withPrivateModifier().count == 1)
    #expect(scope.classes().withFinalModifier().count == 1)
}

@Test func filterByInheritance() {
    let source = """
    class Base {}
    class Child: Base {}
    class GrandChild: Child {}
    class Unrelated {}
    """
    let scope = Sentinel.on(source: source)
    let inheriting = scope.classes().inheriting(from: "Base")
    #expect(inheriting.count == 1)
    #expect(inheriting[0].name == "Child")
}

@Test func filterByConformance() {
    let source = """
    struct CodableStruct: Codable {}
    struct PlainStruct {}
    struct MultiConformance: Codable, Hashable {}
    """
    let scope = Sentinel.on(source: source)
    let codable = scope.structs().conforming(to: "Codable")
    #expect(codable.count == 2)
}

@Test func filterVariables() {
    let source = """
    class Example {
        let constant = "hello"
        var mutable = 42
        var computed: String { "computed" }
        var optional: Int?
    }
    """
    let scope = Sentinel.on(source: source)
    let vars = scope.classes()[0].variables()
    #expect(vars.constants().count == 1)
    #expect(vars.variables().count == 3)
    #expect(vars.computed().count == 1)
    #expect(vars.stored().count == 3)
    #expect(vars.optional().count == 1)
}

@Test func filterFunctions() {
    let source = """
    class Service {
        func noParams() {}
        func withParam(x: Int) {}
        func withReturn() -> String { "" }
    }
    """
    let scope = Sentinel.on(source: source)
    let funcs = scope.classes()[0].functions()
    #expect(funcs.withParameters().count == 1)
    #expect(funcs.withoutParameters().count == 2)
    #expect(funcs.withReturnType().count == 1)
    #expect(funcs.withoutReturnType().count == 2)
}
