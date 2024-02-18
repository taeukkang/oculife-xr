import SwiftUI

/// The top level navigation stack for the app.
struct Modules: View {
    @Environment(ViewModel.self) private var model

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        @Bindable var model = model

        ZStack {
            // The main navigation element for the app.
            NavigationStack(path: $model.navigationPath) {
                TableOfContents()
            }
        }
    }
}

#Preview {
    Modules()
        .environment(ViewModel())
}
