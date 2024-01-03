//
//  UserViewModel.swift
//  WallDota2
//
//  Created by QuangHo on 20/12/2023.
//

import Foundation
import Firebase
import FirebaseAuth

class UserViewModel {
    static let shared = UserViewModel()
    
    let firebaseDB = FireStoreDatabase.shared
    func createUser(user: NewUser) async {
        let db = Firestore.firestore()
        let collectionRef = db.collection("users")
        do {
            let isExist = await UserViewModel.shared.checkUserExist(userID: user.userid)
            if isExist == false {
                try await collectionRef.addDocument(data: ["username": user.username,
                                                           "email": user.email,
                                                           "providers": user.providers,
                                                           "created_at": user.created_at,
                                                           "last_login_at": user.last_login_at,
                                                           "userid": user.userid])
            }
        } catch let err{
            print(err.localizedDescription)
        }
    }
    
    func checkUserExist(userID: String) async -> Bool{
        let db = Firestore.firestore()
        let collectionRef = db.collection("users").whereField("userid", isEqualTo: userID)
        do {
            let documents = try await collectionRef.getDocuments()
            return documents.count > 0
        } catch let err {
            print(err.localizedDescription)
            return false
        }
    }
    
    
   
    
}

struct NewUser: Codable {
    let username: String
    let email: String
    let providers: String
    let created_at: Double
    let last_login_at: Double
    let userid: String
}

struct ItemDownload: Codable {
    let imageid: String
    let created_at: Double
    let userid: String
}
