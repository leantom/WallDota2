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
        let collectionRef = db.collection("likes")
        do {
            try await collectionRef.addDocument(data: ["username": user.username,
                                                       "email": user.email,
                                                       "providers": user.providers,
                                                       "created_at": user.created_at,
                                                       "last_login_at": user.last_login_at,
                                                       "userid": user.id])
        } catch let err{
            print(err.localizedDescription)
        }
    }
}

struct NewUser {
    let username: String
    let email: String
    let providers: String
    let created_at: Double
    let last_login_at: Double
    let id: String
}
