//
//  LoginViewModel.swift
//  WallDota2
//
//  Created by QuangHo on 19/12/2023.
//

import Foundation
import SwiftUI
import FirebaseAuth
import GoogleSignInSwift
import GoogleSignIn
import Firebase

class LoginViewModel: NSObject, ObservableObject {
    static let shared = LoginViewModel()

    var isLoggedIn: Bool = false
    var user:User?
    
    
    func signInWithGoogle() async -> Bool {
       
        guard let clientID = FirebaseApp.app()?.options.clientID else { return false}
                
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
                
        GIDSignIn.sharedInstance.configuration = config
        
        
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return false
        }
        
        guard let presentingVC = await windowScene.keyWindow?.rootViewController else {
            return false
        }
        do {
            let user = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC)
            
            let credential = GoogleAuthProvider.credential(withIDToken: user.user.idToken?.tokenString ?? "", accessToken: user.user.accessToken.tokenString)
            
            do {
                let result = try await Auth.auth().signIn(with: credential)
                self.user = result.user
                AppSetting.setLogined(value: true)
                
                let now = Date().timeIntervalSince1970
                let suffix = "\(now)".suffix(6)
                var username = "anonymous\(suffix)"
                if let email = result.user.email {
                    let components = email.components(separatedBy: "@")
                    if let first = components.first {
                        username = first
                    }
                }
                
                let newUser = NewUser(username: username, email: result.user.email ?? "\(username)@walldota2.com", providers: "google", created_at: now, last_login_at: now, id: result.user.uid)
                await UserViewModel.shared.createUser(user: newUser)
                
                if result.credential != nil {
                    return true
                }
            } catch let err {
                print(err.localizedDescription)
                return false
            }
        } catch let err {
            print(err.localizedDescription)
            return false
        }
        
        return false
        
        
    }
    
    func signinWithAnynomous() async {
        do {
            let result = try await Auth.auth().signInAnonymously()
            self.user = result.user
            print(user?.uid ?? "")
            AppSetting.setLogined(value: true)
            
            let now = Date().timeIntervalSince1970
            let suffix = "\(now)".suffix(6)
            let username = "anonymous\(suffix)"
            
            let newUser = NewUser(username: username, email: "\(username)@walldota2.com", providers: "anonymous", created_at: now, last_login_at: now, id: result.user.uid)
            await UserViewModel.shared.createUser(user: newUser)
        } catch let err{
            print(err.localizedDescription)
        }
        
    }
    
}
