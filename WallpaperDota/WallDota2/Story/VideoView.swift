//
//  VideoView.swift
//  WallDota2
//
//  Created by QuangHo on 07/03/2024.
//

import SwiftUI

import SwiftUI
import AVKit

// Step 2: Create a SwiftUI view that wraps AVPlayerViewController
struct VideoPlayerView: UIViewRepresentable {
    var videoURL: URL

        func makeUIView(context: Context) -> UIView {
            // Initialize the UIView container
            let view = UIView(frame: .zero)

            // Step 4: Set up the AVPlayer
            let player = AVPlayer(url: videoURL)
            let playerLayer = AVPlayerLayer(player: player)
            
            // Configure AVPlayerLayer properties if needed, such as videoGravity
            playerLayer.videoGravity = .resizeAspectFill

            // Add the player layer to the UIView
            view.layer.addSublayer(playerLayer)
            playerLayer.frame = view.bounds
            
            // Start playing the video
            player.play()
            
            return view
        }

        func updateUIView(_ uiView: UIView, context: Context) {
            // Find the AVPlayerLayer in the UIView's layers and adjust its frame
            if let layer = uiView.layer.sublayers?.first as? AVPlayerLayer {
                layer.frame = UIScreen.main.bounds
            }
        }
}

// Step 5: Use the VideoPlayerView in your SwiftUI layout
struct VideoView: View {
    
    @State var player = AVPlayer()
    
    var body: some View {
        // Replace "videoURL" with your actual video URL
        
        VideoPlayer(player: player)
            .onAppear() {
                player = AVPlayer(url:  Bundle.main.url(forResource: "lina", withExtension: "mp4")!)
            }
            .ignoresSafeArea(.all)
        
    }
}

struct WrappedVideoView: View {
    
    var body: some View {
        VideoView()
    }
}

#Preview {
    WrappedVideoView()
}
