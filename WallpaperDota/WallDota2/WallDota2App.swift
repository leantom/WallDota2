//
//  WallDota2App.swift
//  WallDota2
//
//  Created by QuangHo on 12/12/2023.
//

import SwiftUI
import Firebase
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        // check for user permission first
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in
            NSLog("PUSH NOTIFICATION PERMISSION GRANTED: \(granted)")
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        
        Task {
            
            LoginViewModel.shared.user = Auth.auth().currentUser
            let _ = await LoginViewModel.shared.getUserDetail()
        }
        
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcm = Messaging.messaging().fcmToken {
            print("fcm", fcm)
            AppSetting.shared.fcmToken = fcm
            Task {
                await LoginViewModel.shared.addDevice()
            }
        }
    }

}

@main
struct WallDota2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(PECtl.shared)
                .environmentObject(DataColor.shared)
        }
    }
}
