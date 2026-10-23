import Foundation

/// Shorthand for a string the catalog has to translate at run time: AppKit titles, error
/// descriptions, and labels that reach a view as `String` rather than `LocalizedStringKey`.
func L(_ key: String) -> String {
    NSLocalizedString(key, tableName: nil, bundle: .main, value: key, comment: "")
}

/// A format string from the catalog with its arguments. Positional placeholders (`%1$@`)
/// let a translation put the arguments in a different order.
func L(_ key: String, _ arguments: CVarArg...) -> String {
    String(format: NSLocalizedString(key, tableName: nil, bundle: .main, value: key, comment: ""),
           locale: .current, arguments: arguments)
}

/// An enum whose raw value is also its English display text. `displayName` goes through the
/// catalog; `rawValue` stays the value Codable, `.comp` files and asset names already use.
protocol LocalizedDisplayName {
    var displayName: String { get }
}

extension LocalizedDisplayName where Self: RawRepresentable, Self.RawValue == String {
    var displayName: String { L(rawValue) }
}
