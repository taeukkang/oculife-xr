import SwiftUI
import WorldAssets

/// The main entry point of the Hello World experience.
@main
struct OculifeApp: App {
    // The view model.
    @State private var model = ViewModel()

    var body: some Scene {
        // The main window that presents the app's modules.
        WindowGroup("Oculife", id: "modules") {
            Modules()
                .environment(model)
        }
        .windowStyle(.plain)
        .defaultSize(CGSize(width: 800, height: 500))
        
        WindowGroup(id: "assist_new") {
            AssistWindow()
                .environment(model)
        }
        .windowStyle(.plain)
        .defaultSize(width: 1, height: 3, depth: 0.6, in: .meters)
        
    }
}
