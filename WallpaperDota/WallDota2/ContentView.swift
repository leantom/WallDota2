//
//  ContentView.swift
//  WallDota2
//
//  Created by QuangHo on 12/12/2023.
//
import SwiftUI
import Firebase
import FirebaseAuth
import AlertToast
import Network

struct ContentView: View {
    

    let monitor = NWPathMonitor()
    
    @StateObject var notificationManager = NotificationManager()
    @State var ismissingInternet = false
    @State private var images = [Image]()
    init() {
       
    }
    
    var body: some View {
        NavigationStack {
            if AppSetting.checkisFirstLogined() {
                SplashScreenView(currentIndex: 0)
            } else if AppSetting.checkLogined() && Auth.auth().currentUser != nil {
                TabbarCustomView().onAppear {
                }
            } else {
                LoginView()
            }
        }.toast(isPresenting: $ismissingInternet){
            //AlertToast(displayMode: .banner(.slide), type: .regular, title: "No internet connection")
            AlertToast(displayMode: .hud, type: .regular, title: "No internet connection")
        }
        .onAppear(perform: {
            let queue = DispatchQueue(label: "NetworkMonitor")
            monitor.start(queue: queue)
            monitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    ismissingInternet = false
                    print("Internet connection is available.")
                    // Perform actions when internet is available
                } else {
                    ismissingInternet = true
                    print("Internet connection is not available.")
                    // Perform actions when internet is not available
                }
            }
        })
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
