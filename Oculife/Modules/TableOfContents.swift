import SwiftUI

/// The launching point for the app's modules.
struct TableOfContents: View {
    @Environment(ViewModel.self) private var model
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some View {
        @Bindable var model = model
        
        VStack {
            Image("SunSliver")
                .accessibility(hidden: true)
            
            Spacer(minLength: 100)
            
            VStack {
                TitleText(title: model.appTitle)
                    .padding(.horizontal, 70)
                
                Text("An immersive and interactive first aid response with XR and AI")
                    .font(.title)
            }
            .alignmentGuide(.earthGuide) { context in
                context[VerticalAlignment.top]
            }
            .padding(.bottom, 40)

            AssistModuleDetail()
                .padding(.bottom, 50)
            
            Spacer()
        }
        .padding(.horizontal, 50)
        .background(alignment: Alignment(horizontal: .center, vertical: .earthGuide)) {
            Image("EarthHalf")
                .alignmentGuide(.earthGuide) { context in
                    context[VerticalAlignment.top] + 100
                }
                .accessibility(hidden: true)
        }
        .animation(.default.speed(0.25), value: 1)
    }
}

/// The text that displays the app's title.
private struct TitleText: View {
    var title: String
    var body: some View {
        Text(title)
            .monospaced()
            .font(.system(size: 50, weight: .bold))
    }
}

extension VerticalAlignment {
    /// A custom alignment that pins the background image to the title.
    private struct EarthAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.top]
        }
    }
    
    /// A custom alignment guide that pins the background image to the title.
    fileprivate static let earthGuide = VerticalAlignment(
        EarthAlignment.self
    )
}

#Preview {
    NavigationStack {
        TableOfContents()
            .environment(ViewModel())
    }
}
