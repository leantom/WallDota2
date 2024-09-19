//
//  VideoFullScreenView.swift
//  WallDota2
//
//  Created by QuangHo on 8/5/24.
//


import SwiftUI

import SwiftUI
import AVKit
import VideoPlayer


// Step 5: Use the VideoPlayerView in your SwiftUI layout
struct VideoFullScreenView: View {
    let dismissModal: () -> Void
    
    @Binding var videos: [VideoModel]
    
    @State var player = AVPlayer()
    @State var currentIndex = 0
    @State var object: VideoModel?
    
    var body: some View {
        // Replace "videoURL" with your actual video URL
        NavigationStack {
            ZStack {
                if #available(iOS 17.0, *) {
                    ScrollViewReader { proxy in
                        ScrollView() {
                            LazyVStack(spacing: 0) {
                                ForEach(videos, id: \.id) { video in
                                    if let index = videos.firstIndex(where: { vid in
                                        return vid.id == video.id
                                    }) {
                                        VideoPlayerView(videoURL: URL(string: video.url)!)
                                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                                            .clipped()
                                            .onTapGesture {
                                                withAnimation {
                                                    dismissModal()
                                                }
                                            }
                                            .id(index)
                                    }
                                    
                                }
                            }
                            
                        }
                        .scrollTargetBehavior(.paging)
                        .onChange(of: currentIndex) { targetIndex in
                            proxy.scrollTo(targetIndex, anchor: .top)
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        HStack {
                            Button(action: {
                                withAnimation {
                                    dismissModal()
                                }
                                
                            }, label: {
                                Image(systemName: "arrow.backward")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            })
                            .frame(width: 40, height: 40)
                            .background(Color("kC6C2D8").opacity(0.8))
                            .cornerRadius(10)
                            Spacer()
                            
                        }.padding()
                            .frame(width: UIScreen.main.bounds.width)
                            Spacer()
                    }
                    
                    
                } else {
                    
                }
                
            }
            .onAppear(perform: {
                
                guard let videoCurrent = self.object else {return}
                
               
                if let index = videos.firstIndex(where: { vid in
                    return vid.id == videoCurrent.id
                }) {
                    currentIndex = index
                }
                
            })
            
        }
        
    }
}
