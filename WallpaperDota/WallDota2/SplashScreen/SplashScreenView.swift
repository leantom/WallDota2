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
    
    var listTextTitle = ["Comic", "Story", "Art Gallery", "Lore"]
    
    @Binding var path: NavigationPath
    
    var body: some View {
        ZStack {
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
                                    HStack {
                                        VStack (alignment: .leading){
                                            Spacer()
                                            VStack (spacing: 25){
                                                Text(listTextTitle[index])
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .font(.system(size: 24, weight: .bold))
                                                    .fontWeight(.bold)
                                                    .foregroundStyle(.white)
                                                    .multilineTextAlignment(.leading)
                                                Text(listText[index])
                                                    .font(.system(.caption))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .fontWeight(.bold)
                                                    .foregroundStyle(.white)
                                                    .multilineTextAlignment(.leading)
                                                
                                            }
                                            .padding()
                                            .cornerRadius(10)
                                            
                                        }
                                        
                                        ZStack {
                                            // Background circle with stroke (progress indicator)
                                            Circle()
                                                .stroke(lineWidth: 4)
                                                .foregroundColor(Color.gray.opacity(0.5)) // Outer circle color
                                                .frame(width: 60, height: 60)
                                            
                                            // Arrow inside the button
                                            Image(systemName: "chevron.right.circle.fill")
                                                .font(.system(size: 40, weight: .bold))
                                                .foregroundColor(.white)
                                            
                                            // Circular progress indicator (Optional)
                                            Circle()
                                                .trim(from: 0, to: CGFloat(index) * 0.25 + 0.25) // Adjust the 'to' value for progress
                                                .stroke(
                                                    LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.5), Color.white]),
                                                                   startPoint: .trailing,
                                                                   endPoint: .leading),
                                                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                                                )
                                                .frame(width: 60, height: 60)
                                                .rotationEffect(.degrees(-90)) // Rotate the progress
                                        }
                                        .padding()
                                        .onTapGesture {
                                            // Handle button tap
                                            withAnimation(.easeInOut) {
                                                
                                                path.append("login")
                                                Task {
                                                    await notificationManager.request()
                                                }
                                                
                                            }
                                            print("Button tapped")
                                        }
                                        
                                    }
                                    .frame(height: 150)
                                    .padding(.bottom, 150)
                                }
                                
                                
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

                    
                }
                .edgesIgnoringSafeArea(.all)
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

struct WrapperSplashScreen: View {
    @State var path = NavigationPath()
    var body: some View {
        SplashScreenView(path: $path)
    }
}

#Preview {
    WrapperSplashScreen()
}
