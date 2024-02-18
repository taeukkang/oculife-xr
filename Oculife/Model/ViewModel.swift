import SwiftUI

/// The data that the app uses to configure its views.
@Observable
class ViewModel {
    
    // MARK: - Navigation
    var navigationPath: [Module] = []
    var appTitle: String = "Oculife"
    
    // MARK: - Assist
    var assistActionName: String = ""
    var videoUrl: String = ""
    var videoTimestamps: VideoTimestamps = []
    var isShowingAssistWindow: Bool = false
    
}
