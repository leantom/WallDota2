//
//  ContentView.swift
//  WallDota2
//
//  Created by QuangHo on 12/12/2023.
//
import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

struct ContentView: View {
    @State private var images = [Image]()
    init() {
        FirebaseApp.configure()
        print("Done")
    }
    var body: some View {
        TabbarCustomView()
        //SplashScreenView(currentIndex: 0)
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
