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
    var isLoggedIn: Bool = false
    
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
}
