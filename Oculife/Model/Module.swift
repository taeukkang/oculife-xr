import Foundation

/// A description of the modules that the app can present.
enum Module: String, Identifiable, CaseIterable, Equatable {
    case train, assist
    var id: Self { self }
    var name: String { rawValue.capitalized }
}
