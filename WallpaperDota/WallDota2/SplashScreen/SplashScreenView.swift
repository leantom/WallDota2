//
//  SplashScreenView.swift
//  WallDota2
//
//  Created by QuangHo on 12/12/2023.
//

import SwiftUI

struct SplashScreenView: View {
    @StateObject var notificationManager = NotificationManager()
    
    @State private var images = [Image]()
    @State  var currentIndex = 0
    @State private var reachedEnd = false
    @State private var scrollOffset: CGFloat = 0.0
    
    @State private var isLastTab = false
    let gradient: LinearGradient = LinearGradient(
        colors: [Color.black.opacity(0.6), Color.clear],
        startPoint: .bottom, endPoint: .top
    )
    var listText = ["Tired of your phone looking like everyone else's?", "Are you a Dota 2 fan?", "Looking for a way to impress your friends?", "Are you a Dota 2 fan who also loves art?"]
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                   
                    Image("image1").resizable()
                        .scaledToFill()
                        .opacity(0.1)
                        .ignoresSafeArea()
                        .frame(width: UIScreen.main.bounds.width)
                    
                    
                    TabView(selection: $currentIndex) {
                        
                        ForEach(Array(images.enumerated()), id: \.offset) { index, imageWrapper in
                            // Your code
                            ZStack {
                                imageWrapper
                                    .resizable()
                                    .scaledToFill()
                                    .opacity(0.9)
                                    .ignoresSafeArea()
                                    .frame(width: UIScreen.main.bounds.width)
                                    .clipped()
                                VStack {
                                    Spacer()
                                    gradient.frame(width: UIScreen.main.bounds.width, height: 400)
                                }
                                
                                VStack {
                                    Spacer()
                                    Text(listText[index])
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.bottom, 150)
                            }
                            .backgroundStyle(.blue)
                            .edgesIgnoringSafeArea(.all)
                            .tag(index)
                        }
                        
                    }
                    
                    .edgesIgnoringSafeArea(.all)
                    .tabViewStyle(.page)
                        .onChange(of: currentIndex) { newIndex in
                            print(newIndex)
                            if newIndex == images.count - 1 && !reachedEnd {
                                reachedEnd = true
                                // Handle reaching the end
                                AppSetting.setFirstLogined(value: false)
                            } else {
                                reachedEnd = false
                            }
                        }
                    
                    VStack(alignment:.trailing) {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut) {
                                
                                isLastTab.toggle()
                                Task {
                                    await notificationManager.request()
                                }
                                
                            }
                            
                        }) {
                            HStack {
                                Image(systemName: "arrow.forward")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color(red: 0.254, green: 0.279, blue: 0.326).opacity(0.5))
                            .mask(Circle())
                        }.frame(width: 48, height: 48)
                    }
                    .opacity(reachedEnd ? 1 : 0)
                    .animation(.easeInOut, value: reachedEnd)
                    .padding(.bottom, 70)
                    
                    if isLastTab == true {
                        LoginView()
                            .frame(width: UIScreen.main.bounds.width)
                    }
                }
                .edgesIgnoringSafeArea(.all)
            }
            .onAppear {
                loadImages()
            }
            
        }.navigationBarBackButtonHidden()
        
        
    }
    
    private func loadImages() {
        // Replace with your actual image loading logic
        images.removeAll()
        images.append(Image("image1"))
        images.append(Image("image3"))
        
        images.append(Image("image2"))
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
