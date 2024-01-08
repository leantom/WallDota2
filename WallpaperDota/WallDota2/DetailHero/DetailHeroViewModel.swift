//
//  DetailHeroViewModel.swift
//  WallDota2
//
//  Created by QuangHo on 08/01/2024.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import Firebase

class DetailHeroViewModel {
    var heroesImages : [ImageModel] = []
    var id: String
    
    init(id: String) {
        self.id = id
    }
    
    public func fetchDataFromFirestore(id: String) async {
        let db = Firestore.firestore()
        let collectionRef = db.collection("heroes")
        let date = Date().timeIntervalSince1970
        
        let heroes = await FireStoreDatabase.shared.fetchDataHeroFromFirestore(id: id)
        heroesImages = heroes ?? []
    }
    
}
