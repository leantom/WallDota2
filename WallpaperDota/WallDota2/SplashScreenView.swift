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
        colors: [Color.blue.opacity(0.2), Color.clear],
        startPoint: .top, endPoint: .bottom
    )
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                
                ZStack {
                    gradient.edgesIgnoringSafeArea(.all)
                    TabView(selection: $currentIndex) {
                        
                        ForEach(Array(images.enumerated()), id: \.offset) { index, imageWrapper in
                            // Your code
                            VStack {
                                imageWrapper
                                    .resizable()
                                    .scaledToFill()
                                    .opacity(0.9)
                                    .frame(width: UIScreen.main.bounds.width)
                                    .clipped()
                            }
                            .frame(width: UIScreen.main.bounds.width)
                            .edgesIgnoringSafeArea(.all)
                            .tag(index)
                        }
                        
                    }.tabViewStyle(.page)
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
                    if reachedEnd {
                        VStack(alignment:.trailing) {
                            Spacer()
                            HStack {
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
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Color(red: 0.254, green: 0.279, blue: 0.326).opacity(0.5))
                                    .mask(Circle())
                                }.frame(width: 48, height: 48)
                                    
                            }
                            .padding()
                            Spacer()
                        }
                    }
                    
                    if isLastTab == true {
                        LoginView()
                            .frame(width: UIScreen.main.bounds.width)
                    }
                }
                .ignoresSafeArea()
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
