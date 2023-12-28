//
//  ContentView.swift
//  WallDota2
//
//  Created by QuangHo on 12/12/2023.
//
import SwiftUI
import Firebase
import FirebaseAuth



struct ContentView: View {
    @StateObject var notificationManager = NotificationManager()
    
    @State private var images = [Image]()
    init() {
       
    }
    
    var body: some View {
        
        if AppSetting.checkisFirstLogined() {
            SplashScreenView(currentIndex: 0)
        } else if AppSetting.checkLogined() && Auth.auth().currentUser != nil {
            TabbarCustomView().onAppear {
                
            }
        } else {
            LoginView()
        }
        
    }

    private func loadImages() {
        // Replace with your actual image loading logic
        images.append(Image("image1"))
        images.append(Image("image2"))
        images.append(Image("image3"))
        images.append(Image("image4"))
        print("abc")
    }
}

#Preview {
    ContentView()
}
