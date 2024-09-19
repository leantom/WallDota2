//
//  VideoView.swift
//  WallDota2
//
//  Created by QuangHo on 07/03/2024.
//

import SwiftUI

import SwiftUI
import AVKit
import VideoPlayer

struct VideoPlayerView: View {
    var videoURL: URL
    @State private var player = AVPlayer()
    @State private var loading: Bool = true
    
    @State private var autoReplay: Bool = true
    @State private var mute: Bool = false
    @State private var play: Bool = true
    @State private var time: CMTime = .zero
    let gradient = LinearGradient(
        gradient: Gradient(colors: [.black.opacity(0.6), .white]),
               startPoint: .top,
               endPoint: .bottom
           )

    
    var body: some View {
        VStack {
            VideoPlayer(url: videoURL, play: $play)
                .autoReplay(true)
                .contentMode(.scaleAspectFill)
                .onBufferChanged { progress in
                                // Network loading buffer progress changed
                    print(progress)
                            }
                .onStateChanged({ stage in
                    switch stage {
                    case .loading:
                        loading = true
                        print("loading")
                    case .playing(let totalDuration):
                        loading = false
                    case .paused(let playProgress, let bufferProgress):
                        loading = false
                    case .error(let nSError):
                        loading = false
                    }
                })
                .clipped()
           
        }
        .background(gradient)
       
    }
    
    private func setupLooping() {
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: .main
        ) {  _ in
            self.player.seek(to: .zero)
            self.player.play()
        }
    }
}


struct VideoModel: Codable, Identifiable {
    var url: String
    var id: String
    var duration: Int
    var type: String
    var heroid: String
    var size: Int64
    init() {
        url = "https://firebasestorage.googleapis.com/v0/b/dotadressup.appspot.com/o/videos%2FBB74D14B-3723-461F-B335-BB809175FD66.mp4?alt=media&token=e364c142-1d06-41f6-a6c8-d30923c1c3a5"
        id = UUID().uuidString
        duration = 120
        type = "mp4"
        heroid = "Crystal Maiden"
        size = 22705
    }
    
}
// Step 5: Use the VideoPlayerView in your SwiftUI layout
struct VideoView: View {
    let dismissModal: () -> Void
    
    @State var videos: [VideoModel] = []
    
    @State var player = AVPlayer()
    
    @State var isShowFullScreen: Bool = false
    
    
    @State var currentIndex = 0
    @State var objectSelected: VideoModel?
    @State var firebaseData = FireStoreDatabase.shared
    
    var body: some View {
        // Replace "videoURL" with your actual video URL
        NavigationStack {
            ZStack {
                if #available(iOS 17.0, *) {
                    GeometryReader {geo in
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 50) {
                                ForEach(videos, id: \.id) { video in
                                    
                                    VideoPlayerView(videoURL: URL(string: video.url)!)
                                        .frame(width: geo.size.width, height: geo.size.height)
                                        .clipped()
                                        .onTapGesture {
                                            withAnimation {
                                                
                                                objectSelected = video
                                                
                                                self.isShowFullScreen.toggle()
                                            }
                                        }
                                }
                            }
                            
                        }
                        .scrollTargetBehavior(.paging)
                    }
                    
                } else {
                    
                }
                
            }
            .onAppear(perform: {
                self.videos = FireStoreDatabase.shared.listVideo
                let urls_str = self.videos.compactMap({ video in
                    return video.url
                })
                var urls = [URL]()
                for url in urls_str {
                    urls.append(URL(string: url)!)
                }
                
                VideoPlayer.preload(urls: urls)
            })
            
        }
        .navigationDestination(isPresented: $isShowFullScreen) {
            
            VideoFullScreenView(dismissModal: {
                self.isShowFullScreen.toggle()
            }, videos: $firebaseData.listVideo, object: objectSelected)
            .navigationBarBackButtonHidden()
        }
        
    }
}
