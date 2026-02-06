public enum Annotation: String, Sendable, CaseIterable {
    // Declaration attributes
    case available
    case discardableResult
    case dynamicCallable
    case dynamicMemberLookup
    case frozen
    case gkInspectable = "GKInspectable"
    case ibAction = "IBAction"
    case ibDesignable = "IBDesignable"
    case ibInspectable = "IBInspectable"
    case ibOutlet = "IBOutlet"
    case ibSegueAction = "IBSegueAction"
    case inlinable
    case main
    case nonobjc
    case nsApplicationMain = "NSApplicationMain"
    case nsCopying = "NSCopying"
    case nsManaged = "NSManaged"
    case objc
    case objcMembers
    case propertyWrapper
    case resultBuilder
    case requires_stored_property_inits
    case testable
    case uiApplicationMain = "UIApplicationMain"
    case unchecked
    case usableFromInline
    case warn_unqualified_access
    case unknown

    // Type attributes
    case autoclosure
    case convention
    case escaping
    case noescape
    case sendable = "Sendable"

    // Property wrappers (common)
    case state = "State"
    case binding = "Binding"
    case environment = "Environment"
    case environmentObject = "EnvironmentObject"
    case observedObject = "ObservedObject"
    case stateObject = "StateObject"
    case published = "Published"
    case appStorage = "AppStorage"
    case sceneStorage = "SceneStorage"
    case focusedValue = "FocusedValue"
    case focusedBinding = "FocusedBinding"
    case query = "Query"
    case model = "Model"
    case `override`

    // Concurrency
    case mainActor = "MainActor"
    case preconcurrency

    public static func from(name: String) -> Annotation? {
        Annotation(rawValue: name)
            ?? Annotation.allCases.first { $0.rawValue.lowercased() == name.lowercased() }
    }
}
