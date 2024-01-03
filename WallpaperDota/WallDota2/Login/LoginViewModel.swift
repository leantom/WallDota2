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
    var user:User? // user from authenticantion
    var userLogin:NewUser? // user from firestore
    
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
                LoginViewModel.shared.user = result.user
                AppSetting.setLogined(value: true)
                
                await createUser(user: result.user, provider: "google")
                
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
    
    func createUser(user: User, provider: String) async {
        let now = Date().timeIntervalSince1970
        let suffix = "\(now)".suffix(6)
        var username = "anonymous\(suffix)"
        if let email = user.email {
            let components = email.components(separatedBy: "@")
            if let first = components.first {
                username = first
            }
        }
        
        let newUser = NewUser(username: username, email: user.email ?? "\(username)@walldota2.com", providers: provider, created_at: now, last_login_at: now, userid: user.uid)
        
        LoginViewModel.shared.userLogin = newUser
        await UserViewModel.shared.createUser(user: newUser)
    }
    
    func addDevice() async {
        let db = Firestore.firestore()
        // Get the device token from Firebase Authentication or other methods
        let deviceToken = AppSetting.shared.fcmToken

        // Get the current user's UID
        guard let userID = Auth.auth().currentUser?.uid else { return }

        // Save the device token under the user's UID
        do {
                try await db.collection("devices").document(userID).setData(["token": deviceToken])
        } catch let err{
            print(err.localizedDescription)
        }

    }
    // MARK: -- checkExistUser
    func checkExistUser(userName: String) async -> Bool{
        let db = Firestore.firestore()
        let documentRef = db.collection("users").whereField("username", isEqualTo: userName)
        do {
            let snapshot = try await documentRef.getDocuments()
            if snapshot.documents.count > 0 {
                return false
            }
            return true
        } catch let err{
            print(err.localizedDescription)
            return false
        }
    }
    
    //MARK: -- Update username
    func updateUserName(userName: String) async -> Bool {
        let db = Firestore.firestore()
        
        // check username exist yet
        let isValid = await checkExistUser(userName: userName)
        
        if isValid {
            let collectionRef = db.collection("users").whereField("userid", isEqualTo: user?.uid ?? "")
            
            do {
                let snapshot = try await collectionRef.getDocuments()
                let query = snapshot.documents.first
                
                try await query?.reference.updateData(["username": userName])
                LoginViewModel.shared.userLogin =  await getUserDetail()
                return true
            } catch let err{
                print(err.localizedDescription)
                return false
            }
            
        }
        
        
        
        return isValid
        
    }
    //MARK: -- getUserDetail
   
    func getUserDetail() async -> NewUser? {
        let db = Firestore.firestore()
        let collectionRef = db.collection("users").whereField("userid", isEqualTo: user?.uid ?? "")
        do {
            
            let results = try await collectionRef.getDocuments()
            if let result = results.documents.first {
                let user = try result.data(as: NewUser.self)
                //MARK: update last login time
                LoginViewModel.shared.userLogin = user
                return user

            }
        } catch let err{
            print(err.localizedDescription)
            return nil
        }
        
        return nil
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
            
            let newUser = NewUser(username: username, email: "\(username)@walldota2.com", providers: "anonymous", created_at: now, last_login_at: now, userid: result.user.uid)
            LoginViewModel.shared.userLogin = newUser
            await UserViewModel.shared.createUser(user: newUser)
        } catch let err{
            print(err.localizedDescription)
        }
        
    }
    
    func deleteUser() async {
        do {
            AppSetting.setLogined(value: false)
            guard let currentUser = user else { return  }
            
            let db = Firestore.firestore()
            let collectionRef = db.collection("users").whereField("userid", isEqualTo: user?.uid ?? "")
            let results = try await collectionRef.getDocuments()
            
            for item in results.documents {
                try await item.reference.delete()
            }
            
            try await currentUser.delete()
        } catch let err{
            print(err.localizedDescription)
        }
        
    }
    
    
}
