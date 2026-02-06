#!/usr/bin/env python3
"""Fetch all Swift source files from the Harmonize GitHub repository."""

import urllib.request
import os
import time

BASE_URL = "https://raw.githubusercontent.com/perrystreetsoftware/Harmonize/main"
OUTPUT_DIR = "/private/tmp/claude-501/-Users-bariscicek-Desktop-Sentinel/3bcdd13c-15d1-43fa-80ab-104e5cb6900d/scratchpad"
OUTPUT_FILE = os.path.join(OUTPUT_DIR, "harmonize-sources.md")

FILES = [
    "Sources/Harmonize/Core/Config/Config.swift",
    "Sources/Harmonize/Core/Config/Resolver/ResolveProjectConfigFilePath.swift",
    "Sources/Harmonize/Core/Finder/GetFiles.swift",
    "Sources/Harmonize/Core/Finder/Resolver/ResolveProjectWorkingDirectory.swift",
    "Sources/Harmonize/Core/ScopeBuilder/HarmonizeScopeBuilder.swift",
    "Sources/Harmonize/Core/ScopeBuilder/PlainSourceScopeBuilder.swift",
    "Sources/Harmonize/Frontend/API/Builder/Excluding.swift",
    "Sources/Harmonize/Frontend/API/Builder/On.swift",
    "Sources/Harmonize/Frontend/API/Extensions/String+LogicalOperators.swift",
    "Sources/Harmonize/Frontend/API/Extensions/TypeAnnotation+Equatable.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+AccessorBlocksProviding.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+AttributesProviding.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+Base.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+BodyProviding.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+ClassesProviding.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+ClosuresProviding.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+Declaration.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+Enum.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+EnumsProviding.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+Extensions.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+FunctionsProviding.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+InheritanceProviding.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+InitializerClauseProviding.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+InitializersProviding.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+ModifiersProviding.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+NamedDeclaration.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+ParametersProviding.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+ProtocolsProviding.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+ReturnProviding.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+SourceCodeProviding.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+StructsProviding.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+SwiftSourceCode.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+TypeProviding.swift",
    "Sources/Harmonize/Frontend/API/Filters/Array+VariablesProviding.swift",
    "Sources/Harmonize/Frontend/API/Harmonize.swift",
    "Sources/Harmonize/Frontend/API/HarmonizeScope.swift",
    "Sources/Harmonize/Frontend/API/SourceCode/Cache/SyntaxSourceCache.swift",
    "Sources/Harmonize/Frontend/API/SourceCode/SwiftSourceCode.swift",
    "Sources/Harmonize/Frontend/Assertion/Assertions+SwiftSourceCode.swift",
    "Sources/Harmonize/Frontend/Assertion/Assertions.swift",
    "Sources/Harmonize/Frontend/Assertion/Internal/CodeIssue.swift",
    "Sources/Harmonize/Frontend/Assertion/Internal/Report.swift",
    "Sources/HarmonizeSemantics/Collector/Cache/DeclarationsCache.swift",
    "Sources/HarmonizeSemantics/Collector/DeclarationsCollector.swift",
    "Sources/HarmonizeSemantics/Declaration.swift",
    "Sources/HarmonizeSemantics/Declaration/Class.swift",
    "Sources/HarmonizeSemantics/Declaration/Enum.swift",
    "Sources/HarmonizeSemantics/Declaration/EnumCase.swift",
    "Sources/HarmonizeSemantics/Declaration/Extension.swift",
    "Sources/HarmonizeSemantics/Declaration/Extension/Array+AsType.swift",
    "Sources/HarmonizeSemantics/Declaration/Extension/SyntaxProtocol+ResolveParent.swift",
    "Sources/HarmonizeSemantics/Declaration/Function.swift",
    "Sources/HarmonizeSemantics/Declaration/Import.swift",
    "Sources/HarmonizeSemantics/Declaration/Initializer.swift",
    "Sources/HarmonizeSemantics/Declaration/Parameter.swift",
    "Sources/HarmonizeSemantics/Declaration/ProtocolDeclaration.swift",
    "Sources/HarmonizeSemantics/Declaration/Provider/ClassesProviding.swift",
    "Sources/HarmonizeSemantics/Declaration/Provider/ClosuresProviding.swift",
    "Sources/HarmonizeSemantics/Declaration/Provider/DeclarationsProviding.swift",
    "Sources/HarmonizeSemantics/Declaration/Provider/EnumsProviding.swift",
    "Sources/HarmonizeSemantics/Declaration/Provider/FunctionsProviding.swift",
    "Sources/HarmonizeSemantics/Declaration/Provider/InitializersProviding.swift",
    "Sources/HarmonizeSemantics/Declaration/Provider/ParametersProviding.swift",
    "Sources/HarmonizeSemantics/Declaration/Provider/ParentDeclarationProviding.swift",
    "Sources/HarmonizeSemantics/Declaration/Provider/ProtocolsProviding.swift",
    "Sources/HarmonizeSemantics/Declaration/Provider/SourceCodeProviding.swift",
    "Sources/HarmonizeSemantics/Declaration/Provider/StructsProviding.swift",
    "Sources/HarmonizeSemantics/Declaration/Provider/VariablesProviding.swift",
    "Sources/HarmonizeSemantics/Declaration/Struct.swift",
    "Sources/HarmonizeSemantics/Declaration/Variable.swift",
    "Sources/HarmonizeSemantics/DeclarationDecoration.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Decoration/AccessorBlock.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Decoration/Attribute.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Decoration/Body.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Decoration/Closure.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Decoration/Condition.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Decoration/Else.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Decoration/FunctionCall.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Decoration/GetterBlock.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Decoration/Guard.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Decoration/If.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Decoration/InfixExpression.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Decoration/InitializerClause.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Decoration/ReturnClause.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Decoration/Statement.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Decoration/Switch.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Decoration/TypeAnnotation.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Extension/AttributeListSyntax+AttributesProviding.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Extension/CodeBlockItemListSyntax+ToString.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Extension/DeclModifierListSyntax+ModifiersProviding.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Extension/InheritanceClauseSyntax+ToString.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Extension/InitializerClauseSyntax+InitializerClauseProviding.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Modifier.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Provider/AccessorBlocksProviding.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Provider/AttributesProviding.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Provider/BodyProviding.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Provider/ConditionsProviding.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Provider/FunctionCallsProviding.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Provider/InheritanceProviding.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Provider/InitializerClauseProviding.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Provider/ModifiersProviding.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Provider/ReturnProviding.swift",
    "Sources/HarmonizeSemantics/GrammarComponents/Provider/TypeProviding.swift",
    "Sources/HarmonizeSemantics/NamedDeclaration.swift",
    "Sources/HarmonizeSemantics/SourceCode/SourceCodeLocation.swift",
    "Sources/HarmonizeSemantics/Syntax/SyntaxNodeProviding.swift",
    "Sources/HarmonizeUtils/Concurrency/ConcurrentDictionary.swift",
    "Sources/HarmonizeUtils/Imitator/StaticStringImitator.swift",
    "Sources/HarmonizeUtils/String/String+Extensions.swift",
]

os.makedirs(OUTPUT_DIR, exist_ok=True)

with open(OUTPUT_FILE, 'w') as out:
    out.write("# Harmonize Source Files\n\n")
    out.write("Fetched from https://github.com/perrystreetsoftware/Harmonize\n\n")

    total = len(FILES)
    success = 0
    failed = []

    for i, filepath in enumerate(FILES, 1):
        url = f"{BASE_URL}/{filepath}"
        print(f"Fetching ({i}/{total}): {filepath}")

        try:
            req = urllib.request.Request(url)
            req.add_header('User-Agent', 'Python/3')
            with urllib.request.urlopen(req, timeout=30) as response:
                content = response.read().decode('utf-8')
                out.write(f"## {filepath}\n")
                out.write("```swift\n")
                out.write(content)
                if not content.endswith('\n'):
                    out.write('\n')
                out.write("```\n\n")
                success += 1
        except Exception as e:
            print(f"  ERROR: {e}")
            failed.append(filepath)
            out.write(f"## {filepath}\n")
            out.write(f"```\nERROR: Failed to fetch - {e}\n```\n\n")

        if i % 10 == 0:
            time.sleep(0.5)

print(f"\nDone! Successfully fetched {success}/{total} files.")
if failed:
    print(f"Failed files: {failed}")
print(f"Output written to: {OUTPUT_FILE}")
