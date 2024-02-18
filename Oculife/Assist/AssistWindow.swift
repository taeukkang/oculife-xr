//
//  AssistWindow.swift
//  Oculife
//
//  Created by Taeuk on 2/16/24.
//  Copyright © 2024 Taeuk Kang. All rights reserved.
//
import SwiftUI
import AVKit
import UIKit
import AVFoundation

let synth = AVSpeechSynthesizer()

struct AssistWindow: View {
    @Environment(ViewModel.self) private var model
    
    @State private var player: AVPlayer?
    @State var isPlaying: Bool = false
    @State private var timeObserverToken: Any?
    @State private var currentIndex: Int = 0
    
    var body: some View {
        VStack {
            // Header with assistActionName
            if !model.assistActionName.isEmpty {
                Text(model.assistActionName)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .lineLimit(1)
                    .padding()
                    .frame(alignment: .center)
                    .background(Color(red: 0.5, green: 0, blue: 0))
                    .glassBackgroundEffect(in: .rect(cornerRadius: 20))
            }
            
            
            HStack(spacing: 15) {
                // Video container
                if player != nil {
                    AVPlayerControllerRepresented(player: $player)
                        .onAppear {
                            self.player?.isMuted = true
                            setupVideoLooping()
                        }
                        .frame(width: 1000, height: 600) // Adjusted for simplicity
                        .aspectRatio(contentMode: .fill)
                        .cornerRadius(20)
                        .clipped()
                    
                } else {
                    Color.black.frame(width: 1000, height: 600) // Placeholder if no video
                }
            }
            .padding(20)
            .glassBackgroundEffect(in: .rect(cornerRadius: 20))
            .toolbar {
                ToolbarItem(placement: .bottomOrnament) {
                    Button("Previous step", systemImage: "chevron.left") {
                        decrementIndex()
                    }
                }
                
                ToolbarItem(placement: .bottomOrnament) {
                    Button("Next step", systemImage: "chevron.right") {
                        incrementIndex()
                    }
                }
            }
            .padding(.bottom, 20)
            .onChange(of: model.videoUrl) { newUrl in
                debugPrint("New videoUrl detected:", newUrl)
                setupPlayer(videoUrl: newUrl)
                currentIndex = 0
            }
            
            
            VStack {
                Text("Step \(currentIndex + 1) of \(model.videoTimestamps.count)")
                    .font(.system(size: 50))
                    .fontWeight(.bold)
                
                ProgressView(value: Double(currentIndex + 1), total: Double(model.videoTimestamps.count))
                    .progressViewStyle(LinearProgressViewStyle()) // Use the linear style
                    .padding(.horizontal, 10)
                
                if !model.videoTimestamps.isEmpty, currentIndex < model.videoTimestamps.count {
                    Text(model.videoTimestamps[currentIndex].text)
                        .font(.system(size: 40))
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .lineLimit(7)
                        .padding()
                    
                } else {
                    Text("Captions unavailable")
                        .multilineTextAlignment(.center)
                        .padding()
                        .font(.system(size: 40))
                }
            }
            .frame(width: 1000, height: 400)
            .glassBackgroundEffect(in: .rect(cornerRadius: 20))
        }
        .onAppear {
            model.isShowingAssistWindow = true
            setupPlayer(videoUrl: model.videoUrl)
        }
        .onChange(of: model.videoTimestamps.count) {
            if !model.videoTimestamps.isEmpty {
                let textToSpeak = model.videoTimestamps[currentIndex].text
                speakText(textToSpeak)
            }
        }
        .onChange(of: currentIndex) { _ in
            if !model.videoTimestamps.isEmpty, currentIndex < model.videoTimestamps.count {
                let textToSpeak = model.videoTimestamps[currentIndex].text
                speakText(textToSpeak)
            }
        }
        .onDisappear {
            model.isShowingAssistWindow = false
        }
    }
    
    
    private func setupPlayer(videoUrl: String) {
        // Ensure the existing time observer is removed before setting up a new player
        if let timeObserverToken = self.timeObserverToken {
            player?.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
        
        if !videoUrl.isEmpty {
            self.player = nil
            let url = URL(string: videoUrl)!
            self.player = AVPlayer(url: url)
            self.player?.isMuted = true
        }
    }
    
    private func setupVideoLooping() {
        guard let player = player, !model.videoTimestamps.isEmpty, currentIndex < model.videoTimestamps.count else { return }
        let timestamp = model.videoTimestamps[currentIndex]
        let startTime = CMTime(seconds: Double(timestamp.start), preferredTimescale: 600)
        let endTime = CMTime(seconds: Double(timestamp.end), preferredTimescale: 600)
        
        // Make sure to remove the existing observer before adding a new one
        if let timeObserverToken = self.timeObserverToken {
            player.removeTimeObserver(timeObserverToken)
            self.timeObserverToken = nil
        }
        
        // Seek to the start time of the current segment
        player.seek(to: startTime, toleranceBefore: .zero, toleranceAfter: .zero) { [self] _ in
            self.player?.play()
            self.isPlaying = true
        }
        
        // Add a new time observer for the current segment
        self.timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 2), queue: .main) { [self] time in
            if time >= endTime {
                self.player?.seek(to: startTime, toleranceBefore: .zero, toleranceAfter: .zero)
                self.player?.play()
            }
        }
    }
    
    private func incrementIndex() {
        if currentIndex < model.videoTimestamps.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0 // Loop back to the first index
        }
        setupVideoLooping() // Setup looping for the new index
    }
    
    private func decrementIndex() {
        if currentIndex > 1 {
            currentIndex -= 1
        } else {
            currentIndex = model.videoTimestamps.count - 1 // Loop back to the last index
        }
        setupVideoLooping() // Setup looping for the new index
    }
}

private func speakText(_ text: String) {
    let utterance = AVSpeechUtterance(string: text)
    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    
    synth.speak(utterance)
}


#Preview {
    AssistWindow()
}

// https://stackoverflow.com/questions/65927459/playback-controls-in-swiftui
struct AVPlayerControllerRepresented : UIViewControllerRepresentable {
    @Binding var player: AVPlayer?
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}
