# Sentinel

**Compile-time Swift linting where rules are written in pure Swift.**

[![Swift 6.2](https://img.shields.io/badge/Swift-6.2-orange.svg)](https://swift.org)
[![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue.svg)](https://developer.apple.com/macos/)
[![SwiftSyntax 602](https://img.shields.io/badge/SwiftSyntax-602-green.svg)](https://github.com/swiftlang/swift-syntax)

> [!WARNING]
> **Work in Progress** — Sentinel is under active development. APIs, CLI interface, and
> integration patterns may change. It is not yet published as a release binary; see
> [Current Limitations](#current-limitations) for details.

---

Sentinel is a Swift linting tool that takes a fundamentally different approach: instead of
configuring rules with YAML or regex patterns, you write them in **pure Swift** using the full
power of the SwiftSyntax AST.

```swift
struct ViewModelMainActorRule: Rule {
    let identifier = "viewmodel-main-actor"
    let ruleDescription = "ViewModels should be annotated with @MainActor."
    let severity: Severity = .error

    func validate(using scope: SentinelScope) -> [Violation] {
        expect(scope.classes().withNameEndingWith("ViewModel")) {
            $0.attributes.contains(where: { $0.annotation == .mainActor })
        }
    }
}
```

That's a complete, working lint rule. No YAML. No regex. Just Swift.

## Motivation

Existing linters like SwiftLint work well for common patterns, but hit a wall when you need
project-specific architectural rules:

  - *"All ViewModels must have `@MainActor`"*
  - *"Service classes must be `final`"*
  - *"Every protocol must end with a descriptive suffix"*
  - *"No implicitly unwrapped optionals in view layer"*

These are **architectural decisions** — they vary by team, by project, by codebase. Encoding
them in YAML or regex is fragile and limited. With Sentinel, you express them as type-safe Swift
code with full IDE autocompletion, compiler checks, and the entire SwiftSyntax AST at your
disposal.

## Table of Contents

  - [Quick Start](#quick-start)
  - [Writing Rules](#writing-rules)
  - [The `expect` DSL](#the-expect-dsl)
  - [Querying Declarations](#querying-declarations)
  - [Scope & Configuration](#scope--configuration)
  - [CLI Usage](#cli-usage)
  - [Xcode Integration](#xcode-integration)
  - [Testing Rules](#testing-rules)
  - [API Reference](#api-reference)
  - [Installation](#installation)

## Quick Start

### 1. Add a `.sentinel.yml` to your project root

```yaml
rules:
  - SentinelRules

exclude:
  - Tests
  - Generated
```

### 2. Create a rule file

```
mkdir -p SentinelRules
```

**`SentinelRules/ServiceFinalRule.swift`**

```swift
import SentinelKit

struct ServiceFinalRule: Rule {
    let identifier = "service-final"
    let ruleDescription = "Service classes should be marked final."
    let severity: Severity = .warning

    func validate(using scope: SentinelScope) -> [Violation] {
        expect(scope.classes().withNameEndingWith("Service")) {
            $0.isFinal
        }
    }
}
```

### 3. Run

```
sentinel lint
```

Output (Xcode-compatible diagnostics):

```
Sources/NetworkService.swift:4:1: warning: [service-final] Service classes should be marked final.
Sources/StorageService.swift:8:1: warning: [service-final] Service classes should be marked final.
Sentinel: Found 0 error(s), 2 warning(s), 0 info(s)
```

That's it. No `Package.swift` in your project. No `main.swift`. Just rule files and a config.

## Writing Rules

Every rule implements the `Rule` protocol:

```swift
public protocol Rule: Sendable {
    var identifier: String { get }
    var ruleDescription: String { get }
    var severity: Severity { get }

    func validate(using scope: SentinelScope) -> [Violation]
}
```

The `validate` method receives a `SentinelScope` — a queryable view of every declaration in
the project. You return an array of `Violation`s for anything that doesn't meet your criteria.

### Severity Levels

| Severity   | Xcode Output | Exit Code |
|------------|-------------|-----------|
| `.error`   | `error:`    | 1 (fails build) |
| `.warning` | `warning:`  | 0 |
| `.info`    | `note:`     | 0 |

### Two Approaches

**Approach 1: The `expect` DSL** — for rules that check a predicate on a set of declarations:

```swift
func validate(using scope: SentinelScope) -> [Violation] {
    expect(scope.classes().withNameEndingWith("ViewModel")) {
        $0.isFinal
    }
}
```

Every class ending with `"ViewModel"` that fails the predicate generates a violation
automatically, with the correct file path, line, and column.

**Approach 2: Manual `violation(on:)`** — for rules needing custom logic or messages:

```swift
func validate(using scope: SentinelScope) -> [Violation] {
    scope.protocols()
        .filter { proto in
            !["Protocol", "able", "ible", "ing"].contains(where: { proto.name.hasSuffix($0) })
        }
        .map { violation(on: $0, message: "Protocol '\($0.name)' needs a descriptive suffix.") }
}
```

Both approaches produce the same `Violation` type with full source location metadata.

## The `expect` DSL

The `expect` helper is the most concise way to write rules. It takes a filtered array of
declarations and a predicate. Any declaration that fails the predicate becomes a violation:

```swift
// Every class ending with "Service" must be final
expect(scope.classes().withNameEndingWith("Service")) {
    $0.isFinal
}

// Every ViewModel must have @MainActor
expect(scope.classes().withNameEndingWith("ViewModel")) {
    $0.attributes.contains(where: { $0.annotation == .mainActor })
}

// Every public function must have a return type
expect(scope.functions().withPublicModifier()) {
    $0.returnClause != nil
}

// Stored properties in ObservableObject classes must use @Published
expect(
    scope.classes()
        .conforming(to: "ObservableObject")
        .flatMap { $0.variables() }
        .filter { $0.isStored }
) {
    $0.hasAttribute(annotatedWith: .published)
}
```

The auto-generated violation message uses the rule's `ruleDescription`. You can override it with
the `message:` parameter:

```swift
expect(scope.structs().withNameEndingWith("DTO"), message: "DTOs must conform to Codable.") {
    $0.conforms(to: "Codable")
}
```

## Querying Declarations

`SentinelScope` provides access to all declaration types in the analyzed project:

```swift
scope.classes()               // [Class]
scope.structs()               // [Struct]
scope.enums()                 // [Enum]
scope.protocols()             // [ProtocolDeclaration]
scope.functions()             // [Function]
scope.variables()             // [Variable]
scope.initializers()          // [Initializer]
scope.extensions()            // [Extension]
scope.imports()               // [Import]
```

Pass `includeNested: true` to include declarations nested inside other types:

```swift
scope.functions(includeNested: true)  // includes methods inside classes/structs
```

### Filtering by Name

```swift
scope.classes().withName("NetworkService")          // exact match
scope.classes().withNameEndingWith("ViewModel")     // suffix
scope.classes().withNameStartingWith("Base")        // prefix
scope.classes().withNameContaining("Manager")       // substring
scope.classes().withNameMatching(".*View(Model)?")  // regex
scope.classes().withoutName("BaseViewModel")        // exclusion
```

### Filtering by Modifiers

```swift
scope.classes().withFinalModifier()        // final classes
scope.functions().withPublicModifier()     // public functions
scope.functions().withStaticModifier()     // static functions
scope.variables().withLazyModifier()       // lazy properties
scope.variables().withWeakModifier()       // weak references
scope.classes().withoutModifier(.final)    // non-final classes
```

Declarations also expose computed properties for common checks:

```swift
class.isFinal          // Bool
class.isPublic         // Bool
function.isStatic      // Bool
function.isOverride    // Bool
variable.isLazy        // Bool
variable.isWeak        // Bool
```

### Filtering by Inheritance & Conformance

```swift
scope.classes().inheriting(from: "UIViewController")
scope.classes().notInheriting(from: "BaseViewModel")
scope.structs().conforming(to: "Codable")
scope.structs().conforming(to: "Hashable", "Sendable")
scope.classes().notConforming(to: "Sendable")
```

Instance-level checks:

```swift
myClass.inherits(from: "BaseViewModel")     // Bool
myStruct.conforms(to: "Codable")            // Bool
```

### Filtering by Attributes

```swift
scope.classes().withAttribute(annotatedWith: .mainActor)
scope.functions().withAttribute(named: "discardableResult")
scope.variables().withoutAttribute(annotatedWith: .published)
```

The `Annotation` enum covers all common Swift attributes:

```swift
.mainActor, .available, .objc, .objcMembers
.published, .state, .binding, .environment, .observedObject
.escaping, .sendable, .preconcurrency, .discardableResult
// ... and many more
```

### Filtering by Type

```swift
scope.variables().withType(named: "String")
scope.variables().withOptionalType()
scope.variables().withNonOptionalType()
scope.variables().withInferredType()       // type not explicitly declared
scope.variables().withExplicitType()       // type annotation present
```

### Variable-Specific Filters

```swift
scope.variables().stored()        // stored properties only
scope.variables().computed()      // computed properties only
scope.variables().constants()     // let bindings
scope.variables().optional()      // optional types
```

### Function-Specific Filters

```swift
scope.functions().withReturnType()
scope.functions().withoutReturnType()
scope.functions().withReturnType(named: "Bool")
scope.functions().withParameters()
scope.functions().withoutParameters()
scope.functions().withParameterCount(2)
```

### Body Inspection

```swift
scope.functions().withBody()                       // has implementation
scope.functions().withEmptyBody()                   // empty { }
scope.functions().withBodyContaining("fatalError")  // string search
scope.functions().withBodyMatching("print\\(")      // regex search
scope.functions().withSelfReference()               // references self
```

### Navigating Declaration Hierarchies

Types that contain other declarations (classes, structs, enums) conform to
`DeclarationsProviding`:

```swift
let viewModels = scope.classes().withNameEndingWith("ViewModel")

// Get all variables declared inside ViewModels
let allProperties = viewModels.flatMap { $0.variables() }

// Get all functions declared inside ViewModels
let allMethods = viewModels.flatMap { $0.functions() }

// Filter types that contain specific declarations
scope.classes().withVariables()     // classes with at least one property
scope.structs().withFunctions()     // structs with at least one method
```

### File-Based Filtering

```swift
scope.classes().inFile(named: "NetworkService.swift")
scope.functions().inFilePath(containing: "ViewModels/")
```

### Chaining Filters

All filters return arrays, so they chain naturally:

```swift
scope.classes()
    .withNameEndingWith("ViewController")
    .inheriting(from: "UIViewController")
    .withPublicModifier()
    .withAttribute(annotatedWith: .available)
```

## Scope & Configuration

### Using the CLI (Recommended)

When running via `sentinel lint`, the scope is configured automatically from `.sentinel.yml`:

```yaml
rules:
  - SentinelRules              # directory of .swift rule files
  - Rules/CustomRule.swift     # or individual files

exclude:
  - Tests
  - Generated
  - Pods

include:                        # optional: analyze only these paths
  - Sources
```

### Programmatic Usage

For testing or embedding Sentinel in other tools:

```swift
import SentinelKit

// Analyze a project directory
let scope = SentinelScopeBuilder(
    path: "/path/to/project",
    excludes: ["Tests", "Generated"]
)

// Analyze production code only (excludes Tests, Fixtures)
let scope = Sentinel.productionCode(path: "/path/to/project")

// Analyze test code only
let scope = Sentinel.testCode(path: "/path/to/project")

// Analyze a specific folder
let scope = Sentinel.on(folder: "Sources/Networking", path: "/path/to/project")

// Analyze inline Swift source (great for unit testing rules)
let scope = Sentinel.on(source: """
    class MyViewModel {
        var name: String = ""
    }
    """)
```

## CLI Usage

### `sentinel lint`

The primary command. Reads `.sentinel.yml`, discovers rules, compiles them, and runs analysis.

```
sentinel lint [OPTIONS]

OPTIONS:
  -c, --config <path>          Path to config file (default: .sentinel.yml)
  -p, --path <path>            Path to project directory (default: cwd)
      --sentinel-path <path>   Path to Sentinel package (auto-detected)
```

```
# Lint current directory
sentinel lint

# Lint a specific project
sentinel lint --path /path/to/project

# Use a custom config file
sentinel lint --config custom-sentinel.yml
```

### `sentinel init`

Scaffolds a new Sentinel setup with a config file and example rule:

```
sentinel init
```

Creates:

```
.sentinel.yml
SentinelRules/
  ExampleRule.swift
```

### How It Works

Behind the scenes, `sentinel lint` performs these steps:

1. **Parse** `.sentinel.yml` to discover rule file paths
2. **Collect** all `.swift` files from the rule paths
3. **Discover** `Rule`-conforming types via SwiftSyntax
4. **Generate** a `main.swift` entry point that instantiates your rules
5. **Compile** everything into a temporary SPM package (with build caching)
6. **Execute** the compiled binary and forward Xcode-compatible diagnostics

Subsequent runs with unchanged rules skip compilation entirely (content-hash based caching),
making cached runs complete in ~1 second.

## Xcode Integration

Add a **Run Script Build Phase** in your Xcode project:

1. Select your target → **Build Phases** → **+** → **New Run Script Phase**
2. Name it **"Run Sentinel"**
3. Paste:

```bash
# Reset SDK environment for macOS Swift toolchain
unset SDKROOT
unset PLATFORM_DIR
unset PLATFORM_NAME
export DEVELOPER_DIR="$(xcode-select -p)"

# Point to where Sentinel is checked out
SENTINEL_PACKAGE_PATH="/path/to/Sentinel"

swift run --package-path "$SENTINEL_PACKAGE_PATH" sentinel lint --path "$SRCROOT" 2>&1
```

4. In **Build Settings**, set **ENABLE_USER_SCRIPT_SANDBOXING** to **NO**

Violations appear inline in Xcode as errors, warnings, and notes — just like compiler
diagnostics:

```
BaseViewModel.swift:3:1: error: [viewmodel-main-actor] ViewModels should be annotated with @MainActor.
NetworkService.swift:4:1: warning: [service-final] Service classes should be marked final.
DataFetcher.swift:4:1: note: [protocol-naming] Protocol 'DataFetcher' should end with a descriptive suffix.
```

### Why `unset SDKROOT`?

You might notice that tools like SwiftLint don't need these `unset` lines in their build phase
scripts. The reason is how each tool is invoked:

**SwiftLint** is distributed as a **pre-built macOS binary** (via Homebrew, Mint, or direct
download). When you write `swiftlint` in a build phase, you're running a standalone executable
that was already compiled for macOS. It doesn't need any SDK — it just runs.

**Sentinel** currently runs via `swift run`, which means the Swift toolchain needs to **compile
and link** the tool on the fly. The problem is that Xcode exports environment variables like
`SDKROOT`, `PLATFORM_DIR`, and `PLATFORM_NAME` pointing to the target platform's SDK (e.g.
iPhoneSimulator) during build. When `swift run` inherits these variables, it tries to compile
Sentinel — a macOS command-line tool — using the iOS SDK, which fails.

The `unset` lines clear these inherited variables so that `swift run` falls back to the default
macOS SDK, which is what we need.

> [!NOTE]
> Once Sentinel is distributed as a pre-built binary (via Homebrew, Mint, or GitHub Releases),
> the build phase script simplifies to a single line — no `unset`, no `swift run`:
> ```bash
> sentinel lint --path "$SRCROOT"
> ```

## Testing Rules

One of Sentinel's key advantages: rules are testable Swift code. Use `Sentinel.on(source:)` to
create a scope from inline Swift and validate your rule against it:

```swift
import Testing
import SentinelKit

@Test func viewModelMainActorRule_detectsMissingAnnotation() {
    let scope = Sentinel.on(source: """
        class UserViewModel {
            var name: String = ""
        }
        """)

    let rule = ViewModelMainActorRule()
    let violations = rule.validate(using: scope)

    #expect(violations.count == 1)
    #expect(violations.first?.severity == .error)
}

@Test func viewModelMainActorRule_passesWithAnnotation() {
    let scope = Sentinel.on(source: """
        @MainActor
        class UserViewModel {
            var name: String = ""
        }
        """)

    let rule = ViewModelMainActorRule()
    let violations = rule.validate(using: scope)

    #expect(violations.isEmpty)
}
```

## API Reference

### Core Types

| Type | Description |
|------|-------------|
| `Rule` | Protocol for defining lint rules |
| `Violation` | A single lint violation with file, line, column, message, severity |
| `Severity` | `.info`, `.warning`, `.error` |
| `SentinelScope` | Queryable view of all declarations in analyzed code |
| `Configuration` | Project path, include/exclude paths |
| `SentinelRunner` | Runs rules and outputs Xcode diagnostics |

### Declaration Types

| Type | Accessed via | Description |
|------|-------------|-------------|
| `Class` | `scope.classes()` | Class declarations |
| `Struct` | `scope.structs()` | Struct declarations |
| `Enum` | `scope.enums()` | Enum declarations |
| `ProtocolDeclaration` | `scope.protocols()` | Protocol declarations |
| `Function` | `scope.functions()` | Function/method declarations |
| `Variable` | `scope.variables()` | Variable/property declarations |
| `Initializer` | `scope.initializers()` | Init declarations |
| `Extension` | `scope.extensions()` | Extension declarations |
| `Import` | `scope.imports()` | Import statements |

### Provider Protocols

Declarations conform to various provider protocols that expose different capabilities:

| Protocol | Provides | Available On |
|----------|----------|-------------|
| `AttributesProviding` | `attributes`, `hasAttribute(named:)`, `hasAttribute(annotatedWith:)` | Class, Struct, Enum, Protocol, Function, Variable |
| `ModifiersProviding` | `modifiers`, `isFinal`, `isPublic`, `isStatic`, `isLazy`, `isWeak` | Class, Struct, Enum, Protocol, Function, Variable |
| `InheritanceProviding` | `inheritanceTypesNames`, `inherits(from:)`, `conforms(to:)` | Class, Struct, Enum, Protocol, Extension |
| `DeclarationsProviding` | `declarations`, `classes()`, `functions()`, `variables()` | Class, Struct, Enum, Protocol, Extension |
| `BodyProviding` | `body`, `hasBody`, `isEmptyBody`, `functionCalls`, `refersToSelf` | Function, Initializer |
| `TypeProviding` | `typeAnnotation` | Variable, Parameter |
| `ParametersProviding` | `parameters` | Function, Initializer, EnumCase |
| `ReturnProviding` | `returnClause` | Function |
| `ParentDeclarationProviding` | `parent` | Class, Struct, Enum, Function, Variable |
| `AccessorBlocksProviding` | `accessors`, `getter`, `hasGetAccessor()`, `hasSetAccessor()` | Variable |

### Grammar Types

| Type | Description |
|------|-------------|
| `Attribute` | `name`, `annotation: Annotation?`, `arguments: [Argument]` |
| `Modifier` | Enum: `.public`, `.private`, `.final`, `.static`, `.lazy`, `.weak`, ... |
| `Annotation` | Enum: `.mainActor`, `.published`, `.available`, `.sendable`, ... |
| `TypeAnnotation` | `name`, `isOptional` |
| `Body` | `content`, `statements`, `functionCalls`, `closures`, `hasAnySelfReference` |
| `Parameter` | `name`, `label`, `typeAnnotation`, `isVariadic` |
| `ReturnClause` | `typeName` |
| `InitializerClause` | `value`, `isSelfReference` |

## Installation

### Swift Package Manager

Add Sentinel as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/nicklama/sentinel", from: "0.2.0"),
]
```

Then add `SentinelKit` to targets that define rules:

```swift
.target(
    name: "MyRules",
    dependencies: [
        .product(name: "SentinelKit", package: "sentinel"),
    ]
)
```

### Building from Source

```bash
git clone https://github.com/nicklama/sentinel.git
cd sentinel
swift build
```

### Requirements

  - **Swift 6.2+**
  - **macOS 13+**
  - **SwiftSyntax 602.0.0+**

## Example Rules

Here are practical rules covering common architectural patterns:

<details>
<summary><strong>Enforce @MainActor on ViewModels</strong></summary>

```swift
import SentinelKit

struct ViewModelMainActorRule: Rule {
    let identifier = "viewmodel-main-actor"
    let ruleDescription = "ViewModels should be annotated with @MainActor."
    let severity: Severity = .error

    func validate(using scope: SentinelScope) -> [Violation] {
        expect(scope.classes().withNameEndingWith("ViewModel")) {
            $0.attributes.contains(where: { $0.annotation == .mainActor })
        }
    }
}
```
</details>

<details>
<summary><strong>Require final on Service classes</strong></summary>

```swift
import SentinelKit

struct ServiceFinalRule: Rule {
    let identifier = "service-final"
    let ruleDescription = "Service classes should be marked final."
    let severity: Severity = .warning

    func validate(using scope: SentinelScope) -> [Violation] {
        expect(scope.classes().withNameEndingWith("Service")) {
            $0.isFinal
        }
    }
}
```
</details>

<details>
<summary><strong>Enforce ViewModel base class inheritance</strong></summary>

```swift
import SentinelKit

struct ViewModelInheritanceRule: Rule {
    let identifier = "viewmodel-inheritance"
    let ruleDescription = "ViewModels should inherit from BaseViewModel."
    let severity: Severity = .warning

    func validate(using scope: SentinelScope) -> [Violation] {
        expect(
            scope.classes()
                .withNameEndingWith("ViewModel")
                .filter { $0.name != "BaseViewModel" }
        ) {
            $0.inherits(from: "BaseViewModel")
        }
    }
}
```
</details>

<details>
<summary><strong>Ban implicitly unwrapped optionals</strong></summary>

```swift
import SentinelKit

struct NoForceUnwrapRule: Rule {
    let identifier = "no-force-unwrap"
    let ruleDescription = "Avoid implicitly unwrapped optionals."
    let severity: Severity = .warning

    func validate(using scope: SentinelScope) -> [Violation] {
        scope.classes()
            .flatMap { $0.variables() }
            .filter { $0.typeAnnotation?.name.hasSuffix("!") == true }
            .map {
                violation(on: $0,
                    message: "Variable '\($0.name)' uses implicitly unwrapped optional. Use '?' instead.")
            }
    }
}
```
</details>

<details>
<summary><strong>Protocol naming conventions</strong></summary>

```swift
import SentinelKit

struct ProtocolNamingRule: Rule {
    let identifier = "protocol-naming"
    let ruleDescription = "Protocols should end with a descriptive suffix."
    let severity: Severity = .info

    private let validSuffixes = ["Protocol", "able", "ible", "ing", "Type", "Convertible"]

    func validate(using scope: SentinelScope) -> [Violation] {
        scope.protocols()
            .filter { proto in
                !validSuffixes.contains(where: { proto.name.hasSuffix($0) })
            }
            .map {
                violation(on: $0,
                    message: "Protocol '\($0.name)' should end with a descriptive suffix.")
            }
    }
}
```
</details>

<details>
<summary><strong>Require Sendable conformance on public types</strong></summary>

```swift
import SentinelKit

struct PublicSendableRule: Rule {
    let identifier = "public-sendable"
    let ruleDescription = "Public types should conform to Sendable."
    let severity: Severity = .warning

    func validate(using scope: SentinelScope) -> [Violation] {
        let publicStructs = scope.structs().withPublicModifier()
            .filter { !$0.conforms(to: "Sendable") }
            .map { violation(on: $0, message: "Public struct '\($0.name)' should conform to Sendable.") }

        let publicClasses = scope.classes().withPublicModifier()
            .filter { !$0.conforms(to: "Sendable") && !$0.hasAttribute(annotatedWith: .mainActor) }
            .map { violation(on: $0, message: "Public class '\($0.name)' should conform to Sendable or be @MainActor.") }

        return publicStructs + publicClasses
    }
}
```
</details>

<details>
<summary><strong>No empty function bodies</strong></summary>

```swift
import SentinelKit

struct NoEmptyFunctionRule: Rule {
    let identifier = "no-empty-functions"
    let ruleDescription = "Functions should not have empty bodies."
    let severity: Severity = .warning

    func validate(using scope: SentinelScope) -> [Violation] {
        scope.functions(includeNested: true)
            .filter { $0.hasBody && $0.isEmptyBody }
            .filter { !$0.isOverride }  // allow empty overrides
            .map { violation(on: $0, message: "Function '\($0.name)' has an empty body.") }
    }
}
```
</details>

## Architecture

Sentinel is organized into three layers:

```
┌─────────────────────────────────────────┐
│  Sentinel (CLI)                         │
│  ArgumentParser commands, config parser │
│  Rule discovery, compilation pipeline   │
├─────────────────────────────────────────┤
│  SentinelKit (Rule Framework)           │
│  Rule protocol, expect DSL, Violation   │
│  SentinelRunner, DiagnosticFormatter    │
├─────────────────────────────────────────┤
│  SentinelCore (Analysis Engine)         │
│  SwiftSyntax parsing, declarations      │
│  Scope, filters, collector, grammar     │
└─────────────────────────────────────────┘
```

  - **SentinelCore** — Parses Swift source files via SwiftSyntax and builds a rich declaration
    model (classes, structs, functions, variables, etc.) with full attribute, modifier, and
    inheritance information.

  - **SentinelKit** — Provides the `Rule` protocol, `expect` DSL, violation helpers, and
    `SentinelRunner` for executing rules and formatting output. Depends on SentinelCore and
    re-exports it via `@_exported import`.

  - **Sentinel** — The CLI executable. Handles config parsing, rule file discovery, code
    generation, compilation (via temporary SPM packages), and execution.

## Current Limitations

Sentinel is under active development. Here's what to expect in the current state:

  - **No pre-built binary yet.** Sentinel must be run via `swift run`, which requires the source
    checkout and adds `unset SDKROOT` boilerplate in Xcode build phases. A Homebrew formula and
    GitHub Release binaries are planned, which will eliminate this entirely.

  - **First-run compilation overhead.** The very first `sentinel lint` invocation compiles a
    temporary SPM package with all dependencies (SwiftSyntax, SentinelKit, etc.), which can take
    15–30 seconds. Subsequent runs use content-hash based caching and complete in ~1 second when
    rule files haven't changed.

  - **macOS only.** Sentinel analyzes Swift source files on macOS. Linux support is technically
    feasible (SwiftSyntax supports Linux) but is not tested or prioritized.

  - **No SPM plugin integration.** Running Sentinel as a native SPM build tool plugin
    (`swift package sentinel`) is not yet supported.

## Roadmap

  - [ ] Pre-built binary distribution (Homebrew, Mint, GitHub Releases)
  - [ ] SPM Build Tool Plugin support
  - [ ] `--fix` mode for auto-correctable rules
  - [ ] Parallel rule execution
  - [ ] Built-in rule library (common Swift/SwiftUI patterns)
  - [ ] Rule severity override in `.sentinel.yml`
  - [ ] Watch mode for continuous linting during development

## License

This project is available under the MIT License.
