import SwiftUI
import Alamofire

/// The module detail content that's specific to the orbit module.
struct AssistModuleDetail: View {
    @Environment(ViewModel.self) private var model
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    
    var body: some View {
        VStack() {
            Button(action: toggleRecording) {
                Text(isRecording ? "End description" : "Request emergency assistance")
                    .foregroundColor(.white)
            }
            .background(isRecording ? Color.red : Color.blue)
            .clipShape(Capsule())
            
            Text(speechRecognizer.transcript)
                .padding()
        }
        
        .onAppear {
            startAssist()
        }
        
    }
    
    private func startAssist() {
        speechRecognizer.resetTranscript()
    }
    
    private func toggleRecording() {
        if isRecording {
            speechRecognizer.stopTranscribing()
            
            // send a POST request with the recording data
            sendTranscript(prompt: speechRecognizer.transcript, model: model)
            
            if (!model.isShowingAssistWindow) {
                openWindow(id: "assist_new")
            } else {
                dismissWindow(id: "assist_new")
                openWindow(id: "assist_new")
            }
        } else {
            speechRecognizer.startTranscribing()
        }
        isRecording.toggle()
    }
    
}

struct AssistPromptRequest: Encodable {
    let prompt: String
}


func sendTranscript(prompt: String, model: ViewModel) {
    let postBody = AssistPromptRequest(prompt: prompt)
    
    AF.request("https://improved-enigma-jvjv4rvr7p9hqwp6-5000.app.github.dev/assist",
               method: .post,
               parameters: postBody,
               encoder: JSONParameterEncoder.default).responseDecodable(of: AssistResponseWrapper.self) { response in
        switch response.result {
        case .success(let json):
            debugPrint("Response for assist module", json)
            model.assistActionName = json.data.condition
            
            if let videoUrl = json.data.videoUrl {
                model.videoUrl = videoUrl
            }
            
            if let videoTimestamps = json.data.videoTimestamps {
                model.videoTimestamps = videoTimestamps
            }
            
            
        case .failure(let error):
            print("Request failed with error: \(error)")
        }
    }
}


#Preview {
    AssistModuleDetail()
        .padding()
        .environment(ViewModel())
}
