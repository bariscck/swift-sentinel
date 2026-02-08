# Sentinel

**Compile-time linting for Swift projects with custom rules powered by SwiftSyntax — no YAML, no regex, just Swift.**

[![Swift 6.2](https://img.shields.io/badge/Swift-6.2-orange.svg)](https://swift.org)
[![macOS 13+](https://img.shields.io/badge/macOS-13%2B-blue.svg)](https://developer.apple.com/macos/)
[![SwiftSyntax 602](https://img.shields.io/badge/SwiftSyntax-602-green.svg)](https://github.com/swiftlang/swift-syntax)

> [!WARNING]
> **Work in Progress** — Sentinel is under active development. APIs, CLI interface, and
> integration patterns may change. See [Current Limitations](#current-limitations) for details.

---

Sentinel is a Swift linting tool that takes a fundamentally different approach: instead of
configuring rules with YAML or regex patterns, you write them in **pure Swift** using the full
power of the SwiftSyntax AST.

```swift
import SentinelKit

@SentinelRule(.error, id: "viewmodel-main-actor")
struct ViewModelMainActorRule {
    func validate(using scope: SentinelScope) -> [Violation] {
        expect("ViewModels should be annotated with @MainActor.",
               for: scope.classes().withNameEndingWith("ViewModel")) {
            $0.attributes.contains(where: { $0.annotation == .mainActor })
        }
    }
}
```

That's a complete, working lint rule. No YAML. No regex. Just Swift.

## Table of Contents

  - [Motivation](#motivation)
  - [Quick Start](#quick-start)
  - [Writing Rules](#writing-rules)
  - [Querying Declarations](#querying-declarations)
  - [Configuration](#configuration)
  - [Inline Rule Suppression](#inline-rule-suppression)
  - [Selective Linting](#selective-linting)
  - [CLI Usage](#cli-usage)
  - [Xcode Integration](#xcode-integration)
  - [Writing Rules in Your Project](#writing-rules-in-your-project)
  - [Testing Rules](#testing-rules)
  - [Installation](#installation)
  - [Architecture](#architecture)
  - [Current Limitations](#current-limitations)
  - [Roadmap](#roadmap)
  - [Acknowledgments](#acknowledgments)

## Motivation

Existing linters like SwiftLint work well for common patterns, but hit a wall when you need
project-specific architectural rules:

  - *"All ViewModels must have `@MainActor`"*
  - *"Service classes must be `final`"*
  - *"Every protocol must end with a descriptive suffix"*

These are **architectural decisions** that vary by team and by project. Encoding them in YAML or
regex is fragile and limited. With Sentinel, you express them as type-safe Swift code with full
IDE autocompletion, compiler checks, and the entire SwiftSyntax AST at your disposal.

Sentinel's core architecture is heavily based on
**[Harmonize](https://github.com/perrystreetsoftware/Harmonize)** by Perry Street Software,
which pioneered the idea of writing Swift architectural tests as pure Swift code using SwiftSyntax.

## Quick Start

**1.** Write a rule anywhere in your project — a plain `.swift` file that imports `SentinelKit`:

```swift
import SentinelKit

@SentinelRule(.warning, id: "service-final")
struct ServiceFinalRule {
    func validate(using scope: SentinelScope) -> [Violation] {
        expect("Service classes should be marked final.",
               for: scope.classes().withNameEndingWith("Service")) {
            $0.isFinal
        }
    }
}
```

**2.** Run `sentinel lint`:

```
Sources/NetworkService.swift:4:1: warning: [service-final] Service classes should be marked final.
Sentinel: Found 0 error(s), 1 warning(s), 0 info(s)
```

That's it. Sentinel discovers your rules from paths configured in `.sentinel.yml`.

## Writing Rules

Every rule is a struct annotated with `@SentinelRule`. The macro synthesizes `Rule` protocol
conformance along with `identifier` and `severity` properties — you only write `validate`:

```swift
@SentinelRule(.error, id: "viewmodel-main-actor")
struct ViewModelMainActorRule {
    func validate(using scope: SentinelScope) -> [Violation] {
        expect("ViewModels should be annotated with @MainActor.",
               for: scope.classes().withNameEndingWith("ViewModel")) {
            $0.hasAttribute(named: "MainActor")
        }
    }
}
```

### Severity Levels

| Severity   | Xcode Output | Exit Code |
|------------|-------------|-----------|
| `.error`   | `error:`    | 1 (fails build) |
| `.warning` | `warning:`  | 0 |
| `.info`    | `note:`     | 0 |

### Using `expect`

The `expect` DSL is the most concise way to write rules. Every declaration that fails the
predicate generates a violation automatically with file, line, and column information:

```swift
func validate(using scope: SentinelScope) -> [Violation] {
    expect("ViewModels should be annotated with @MainActor.",
           for: scope.classes().withNameEndingWith("ViewModel")) {
        $0.attributes.contains(where: { $0.annotation == .mainActor })
    }
}
```

You can compose multiple `expect` calls for rules that check several conditions:

```swift
func validate(using scope: SentinelScope) -> [Violation] {
    let vms = scope.classes().withNameEndingWith("ViewModel")
    return expect("ViewModels must inherit from BaseViewModel.", for: vms) {
               $0.inherits(from: "BaseViewModel")
           }
         + expect("ViewModels must be annotated with @MainActor.", for: vms) {
               $0.hasAttribute(named: "MainActor")
           }
}
```

### Using `violation(on:message:)`

For rules needing custom logic, create violations manually:

```swift
func validate(using scope: SentinelScope) -> [Violation] {
    scope.protocols()
        .filter { proto in
            !["Protocol", "able", "ible", "ing"].contains(where: { proto.name.hasSuffix($0) })
        }
        .map { violation(on: $0, message: "Protocol '\($0.name)' needs a descriptive suffix.") }
}
```

## Querying Declarations

`SentinelScope` provides access to all declaration types:

```swift
scope.classes()        scope.structs()        scope.enums()
scope.protocols()      scope.functions()      scope.variables()
scope.initializers()   scope.extensions()     scope.imports()
```

Use `includeNested: true` to include declarations nested inside other types.

### Filtering

Filters chain naturally and cover name, modifiers, inheritance, attributes, and more:

```swift
// By name
scope.classes().withNameEndingWith("ViewModel")
scope.classes().withNameContaining("Manager")

// By modifier
scope.classes().withFinalModifier()
scope.functions().withPublicModifier()

// By inheritance & conformance
scope.classes().inheriting(from: "UIViewController")
scope.structs().conforming(to: "Codable")

// By attribute
scope.classes().withAttribute(annotatedWith: .mainActor)

// By type
scope.variables().withOptionalType()
scope.variables().stored()

// By body
scope.functions().withBodyContaining("fatalError")

// Chaining
scope.classes()
    .withNameEndingWith("ViewController")
    .inheriting(from: "UIViewController")
    .withPublicModifier()
```

Declarations also expose computed properties: `isFinal`, `isPublic`, `isStatic`, `isOverride`,
`isLazy`, `isWeak`, and more.

## Configuration

Add a `.sentinel.yml` to your project root to configure rule paths, exclusions, and inclusions.

### `.sentinel.yml`

```yaml
rules:                           # paths to rule files or directories
  - SentinelRules/Sources        #   directory of .swift rule files
  - Rules/CustomRule.swift       #   or individual files

exclude:
  - Tests
  - Generated
  - Pods

include:                         # optional: analyze only these paths
  - Sources
```

### Programmatic Usage

For testing or embedding Sentinel in other tools:

```swift
import SentinelKit

let scope = Sentinel.on(source: """
    class MyViewModel {
        var name: String = ""
    }
    """)

let scope = Sentinel.productionCode(path: "/path/to/project")
```

## Inline Rule Suppression

You can suppress specific rules at the file or line level using inline comments — similar to
SwiftLint's `swiftlint:disable` directives.

### Disable a Rule for the Rest of the File

```swift
// sentinel:disable service-final

class NetworkService { }   // no violation
class CacheService { }     // no violation
```

### Re-enable a Disabled Rule

```swift
// sentinel:disable service-final
class NetworkService { }   // no violation

// sentinel:enable service-final
class CacheService { }     // violation reported
```

### Disable for the Next Line Only

```swift
// sentinel:disable:next no-force-unwrap
var name: String! = nil    // no violation

var age: Int! = nil        // violation reported
```

### Disable for the Current Line

```swift
class MyViewModel {} // sentinel:disable:this viewmodel-main-actor
```

### Disable All Rules

Use `all` instead of a rule identifier to suppress every rule:

```swift
// sentinel:disable all
class Legacy {
    var data: String! = nil
}
// sentinel:enable all
```

### Reference

| Directive | Scope |
|---|---|
| `// sentinel:disable <rule-id>` | From this line to end of file (or until re-enabled) |
| `// sentinel:enable <rule-id>` | Re-enables a previously disabled rule |
| `// sentinel:disable:next <rule-id>` | Next line only |
| `// sentinel:disable:this <rule-id>` | Current line only |

> [!TIP]
> The `<rule-id>` must match the `id` parameter from `@SentinelRule(.warning, id: "service-final")`.

## Selective Linting

Sentinel can lint only files that have changed in git, significantly speeding up iteration on large
projects. Use the `--changed-only` flag to restrict analysis to modified files.

### Lint Uncommitted Changes

Checks staged, unstaged, and untracked Swift files:

```bash
sentinel lint --changed-only
```

### Lint Changes Against a Branch

Compare against a base branch to lint all files changed in a feature branch:

```bash
sentinel lint --changed-only --base-branch main
```

This is especially useful in CI pipelines to lint only the diff introduced by a pull request.

### How It Works

| Mode | What gets linted |
|---|---|
| `--changed-only` (no base branch) | Staged + unstaged + untracked `.swift` files |
| `--changed-only --base-branch main` | All `.swift` files changed between `main` and `HEAD` |

When no changed Swift files are detected, Sentinel exits early with a message:

```
Sentinel: No changed Swift files found. Nothing to lint.
```

> [!TIP]
> Combine `--changed-only` with a git pre-commit hook for fast feedback — only the files you
> touched get linted, keeping the hook near-instant.

## CLI Usage

### `sentinel lint`

```
sentinel lint [OPTIONS]

OPTIONS:
  -c, --config <path>          Path to config file (default: .sentinel.yml)
  -p, --path <path>            Path to project directory (default: cwd)
      --sentinel-path <path>   Path to Sentinel package (auto-detected)
      --changed-only           Only lint files changed in git
      --base-branch <branch>   Base branch to diff against (used with --changed-only)
```

### `sentinel init`

Scaffolds a new Sentinel setup with a config file and example rule:

```
sentinel init
```

## Xcode Integration

### Build Phase Script

Add a **Run Script Build Phase** to your Xcode target:

1. Select your target → **Build Phases** → **+** → **New Run Script Phase**
2. Name it **"Run Sentinel"**
3. Paste:

```bash
unset SDKROOT
unset PLATFORM_DIR
unset PLATFORM_NAME
export DEVELOPER_DIR="$(xcode-select -p)"

SENTINEL_PACKAGE_PATH="/path/to/Sentinel"

swift run --package-path "$SENTINEL_PACKAGE_PATH" sentinel lint --path "$SRCROOT" 2>&1
```

4. In **Build Settings**, set **ENABLE_USER_SCRIPT_SANDBOXING** to **NO**

Violations appear inline in Xcode as errors, warnings, and notes.

<details>
<summary><strong>Why <code>unset SDKROOT</code>?</strong></summary>

SwiftLint is distributed as a pre-built macOS binary — it runs directly without an SDK.
Sentinel currently runs via `swift run`, which means the Swift toolchain compiles the tool on
the fly. Xcode exports `SDKROOT`, `PLATFORM_DIR`, and `PLATFORM_NAME` pointing to the target
platform's SDK (e.g. iPhoneSimulator). When `swift run` inherits these, it tries to compile
Sentinel using the iOS SDK, which fails. The `unset` lines reset to the default macOS SDK.

Once Sentinel is distributed as a pre-built binary, the script simplifies to:
```bash
sentinel lint --path "$SRCROOT"
```

You can also add `--changed-only` to the build phase script to speed up incremental builds by
linting only modified files.
</details>

## Writing Rules in Your Project

Add `SentinelKit` as a dependency to your project so you get autocompletion, type checking, and
compiler errors while writing rules:

```swift
dependencies: [
    .package(url: "https://github.com/bariscck/sentinel", from: "0.2.0"),
]
```

Then create a target for your rules that depends on `SentinelKit`:

```swift
.target(
    name: "SentinelRules",
    dependencies: [
        .product(name: "SentinelKit", package: "sentinel"),
    ],
    path: "SentinelRules/Sources"
)
```

Write your rules under `SentinelRules/Sources/` with `import SentinelKit`. Xcode will resolve
all types — `Rule`, `SentinelScope`, `@SentinelRule`, `expect`, filters — with full autocompletion.

Point `.sentinel.yml` to the same directory:

```yaml
rules:
  - SentinelRules/Sources
```

> [!TIP]
> See the `Example/SentinelExample` project for a working setup with a local SPM package and
> Xcode Build Phase integration.

## Testing Rules

Rules are testable Swift code. Use `Sentinel.on(source:)` to create a scope from inline Swift:

```swift
import Testing
import SentinelKit

@Test func detectsMissingMainActor() {
    let scope = Sentinel.on(source: """
        class UserViewModel {
            var name: String = ""
        }
        """)

    let violations = ViewModelMainActorRule().validate(using: scope)
    #expect(violations.count == 1)
}

@Test func passesWithMainActor() {
    let scope = Sentinel.on(source: """
        @MainActor
        class UserViewModel {
            var name: String = ""
        }
        """)

    let violations = ViewModelMainActorRule().validate(using: scope)
    #expect(violations.isEmpty)
}
```

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/bariscck/sentinel", from: "0.2.0"),
]
```

### Building from Source

```bash
git clone https://github.com/bariscck/sentinel.git
cd sentinel
swift build
```

### Requirements

  - Swift 6.2+
  - macOS 13+
  - SwiftSyntax 602.0.0+

## Architecture

```
┌─────────────────────────────────────────┐
│  Sentinel (CLI)                         │
│  Config parsing, rule compilation       │
├─────────────────────────────────────────┤
│  SentinelKit (Rule Framework)           │
│  Rule protocol, expect DSL, Violation   │
├─────────────────────────────────────────┤
│  SentinelMacros (Compiler Plugin)       │
│  @SentinelRule macro implementation     │
├─────────────────────────────────────────┤
│  SentinelCore (Analysis Engine)         │
│  SwiftSyntax parsing, declarations      │
│  Scope builder, filters, grammar        │
└─────────────────────────────────────────┘
```

## Current Limitations

  - **No pre-built binary yet.** Must run via `swift run`, which requires `unset SDKROOT`
    boilerplate in Xcode build phases.
  - **First-run overhead.** First `sentinel lint` invocation compiles all dependencies (~15-30s).
    Subsequent cached runs complete in ~1 second.
  - **macOS only.** Linux support is technically feasible but not tested.

## Roadmap

  - [x] Inline rule suppression (`sentinel:disable` / `sentinel:enable` directives)
  - [x] Selective linting (`--changed-only` for git-aware incremental lints)
  - [ ] Pre-built binary distribution (Homebrew, Mint, GitHub Releases)
  - [ ] SPM Build Tool Plugin support
  - [ ] `--fix` mode for auto-correctable rules
  - [ ] Parallel rule execution
  - [ ] Built-in rule library
  - [ ] Watch mode for continuous linting

## Acknowledgments

Sentinel is built on the shoulders of
**[Harmonize](https://github.com/perrystreetsoftware/Harmonize)** by
[Perry Street Software](https://github.com/perrystreetsoftware). The declaration model, the
SwiftSyntax-based collector, scope builder, and filter DSL all originate from Harmonize's
architecture. Sentinel extends these into a standalone CLI linter with config-driven rule
discovery, automatic compilation, and Xcode diagnostic output.

## License

This project is available under the MIT License.
