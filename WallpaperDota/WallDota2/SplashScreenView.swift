//
//  SplashScreenView.swift
//  WallDota2
//
//  Created by QuangHo on 12/12/2023.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var images = [Image]()
    @State  var currentIndex = 0
    @State private var reachedEnd = false
    @State private var scrollOffset: CGFloat = 0.0
    
    @State private var isLastTab = false
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    TabView(selection: $currentIndex) {
                        
                        ForEach(Array(images.enumerated()), id: \.offset) { index, imageWrapper in
                            // Your code
                            VStack {
                                Text("text")
                            }
                            .tag(index)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .overlay(
                                imageWrapper
                                    .clipped()
                                    .scaledToFill()
                                    .opacity(0.9)
                                    .ignoresSafeArea()
                            )
                        }
                        
                    }.tabViewStyle(.page)
                        .ignoresSafeArea()
                        .onChange(of: currentIndex) { newIndex in
                            print(newIndex)
                            if newIndex == images.count - 1 && !reachedEnd {
                                reachedEnd = true
                                // Handle reaching the end
                                
                            } else {
                                reachedEnd = false
                            }
                        }
                    if reachedEnd {
                        VStack(alignment:.trailing) {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        isLastTab.toggle()
                                    }
                                    
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.forward")
                                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Color(red: 0.254, green: 0.279, blue: 0.326))
                                    .mask(Circle())
                                }.frame(width: 60, height: 60)
                                    
                            }
                            .padding(.trailing)
                        }
                    }
                    
                    if isLastTab == true {
                        LoginView()
                    }
                }
                .ignoresSafeArea(.all, edges: .top)
            }
            .onAppear {
                loadImages()
            }
            
        }
        
        
    }
    
    private func loadImages() {
        // Replace with your actual image loading logic
        images.removeAll()
        images.append(Image("image1"))
        images.append(Image("image3"))
        images.append(Image("image2"))
        
        images.append(Image("image3"))
        images.append(Image("image4"))
    }
}

struct NavigationDestination: View {
    let destination: AnyView
    
    init(@ViewBuilder destination: () -> AnyView) {
        self.destination = destination()
    }
    
    var body: some View {
        EmptyView()
    }
}

#Preview {
    SplashScreenView()
}
