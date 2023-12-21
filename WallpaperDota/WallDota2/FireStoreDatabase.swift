//
//  FireStoreDatabase.swift
//  WallDota2
//
//  Created by QuangHo on 14/12/2023.
//

import Foundation
import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import Firebase

class FireStoreDatabase {
    var listAllImage : [ImageModel] = []
    var spotlightImages : [ImageModel] = []
    var trendingImages : [ImageModel] = []
    var listCollectionImages : [ImageModel] = []
    var listImageLiked : [ImageModel] = []
    
    var heroesID : [String] = []
    
    static let shared = FireStoreDatabase()
    
    public func fetchDataFromFirestore() async {
        let db = Firestore.firestore()
        let collectionRef = db.collection("heroes")
        let date = Date().timeIntervalSince1970
        do {
            let snapshot = try await collectionRef.getDocuments()
            let _items = snapshot.documents.compactMap { document in
                do {
                    let item =  try document.data(as: ImageModel.self)
                    item.id = document.documentID
                    return item
                    
                } catch {
                    print("Error decoding item: \(error.localizedDescription)")
                    return nil
                }
            }

            print("total time fetchDataFromFirestore :\(Date().timeIntervalSince1970 - date)")
            self.listAllImage = _items
            self.getTrendingImages()
            self.getSpotlightImages()
            self.getHeroesID()
            await fetchDataCollectionFromFirestore()
            await getImagesLiked()
        } catch {
            print("Error getting documents: \(error.localizedDescription)")
        }
    }
    
    public func fetchDataCollectionFromFirestore() async {
        let db = Firestore.firestore()
        let collectionRef = db.collection("collections")
        let date = Date().timeIntervalSince1970
        do {
            let snapshot = try await collectionRef.getDocuments()
            let _items = snapshot.documents.compactMap { document in
                do {
                    let item =  try document.data(as: ImageModel.self)
                    return item
                    
                } catch {
                    print("Error decoding item: \(error.localizedDescription)")
                    return nil
                }
            }

            print("total time fetchDataCollectionFromFirestore :\(Date().timeIntervalSince1970 - date)")
            self.listCollectionImages = _items
            await self.getImageURLForListCollection()
            
        } catch {
            print("Error getting documents: \(error.localizedDescription)")
        }
    }
    
    static public func likeImage(image: ImageModel) async {
        let db = Firestore.firestore()
        let collectionRef = db.collection("likes")
        do {
            try await collectionRef.addDocument(data: ["documentid": image.id,
                                                       "userid": LoginViewModel.shared.user?.uid ?? ""])
        } catch let err{
            print(err.localizedDescription)
        }
    }
    
    static public func createUser(image: ImageModel) async {
        let db = Firestore.firestore()
        let collectionRef = db.collection("users")
        do {
            try await collectionRef.addDocument(data: ["username": image.id,
                                                       "userid": LoginViewModel.shared.user?.uid ?? ""])
        } catch let err{
            print(err.localizedDescription)
        }
    }
    
    
    func getImagesLiked() async {
        let db = Firestore.firestore()
        let collectionRef = db.collection("likes").whereField("userid", isEqualTo: LoginViewModel.shared.user?.uid ?? "")
        let date = Date().timeIntervalSince1970
        do {
            let snapshot = try await collectionRef.getDocuments()
            let _items = snapshot.documents.compactMap { document in
                do {
                    let item =  try document.data(as: ImageLikeModel.self)
                    item.id = document.documentID
                    return item
                    
                } catch {
                    print("Error decoding item: \(error.localizedDescription)")
                    return nil
                }
            }

            print("total time download :\(Date().timeIntervalSince1970 - date)")
            
            for item in _items {
                if let model = await self.getDocument(by: item.documentid) {
                    model.id = item.documentid
                    self.listImageLiked.append(model)
                }
            }
            
        } catch {
            print("Error getting documents: \(error.localizedDescription)")
        }
    }
    
    func checkUserLikedExistID(id: String) -> Bool {
        let docs = listImageLiked.filter { item in
            return item.id == id
        }
        return docs.count > 0
    }
    
    
    func getDocument(by id: String) async -> ImageModel? {
        let db = Firestore.firestore()
        let documentReference = db.collection("heroes").document(id)
        do {
            let documentsnap = try await documentReference.getDocument()
            do {
                let item =  try documentsnap.data(as: ImageModel.self)
                return item
            } catch {
                print("Error decoding item: \(error.localizedDescription)")
                return nil
            }
        }catch let err{
            print(err.localizedDescription)
            return nil
        }
    }
    
    private func getHeroesID() {
        let heroesIDs = self.listAllImage.compactMap({ image in
            return image.heroID
        })
        
        let uniqueValues = Set(heroesIDs)

        // Convert back to an array if needed
        let uniqueArray = Array(uniqueValues)
        self.heroesID = uniqueArray
        print(self.heroesID.count)
    }
    
    
    func getImagesInListCollections(id: String) -> String {
        let items = self.listCollectionImages.filter { image in
            return image.heroID == id
        }
        return items.first?.thumbnailFull ?? ""
    }
    
    
    func getImageURLForListCollection() async {
        for item in listCollectionImages {
            if item.thumbnailFull.isEmpty {
                let url = await getURL(path: item.thumbnail)
                item.thumbnailFull = url?.absoluteString ?? ""
            }
           
        }
    }
    
    
    private func getSpotlightImages() {
        self.spotlightImages = self.listAllImage.filter { image in
            return image.heroID == "Spotlight"
        }
        print(self.spotlightImages.count)
    }
    
    func getImages(by id: String) -> [ImageModel] {
        let items = self.listAllImage.filter { image in
            return image.heroID == id
        }
        return items
    }
    
    
    private func getTrendingImages() {
        if self.listAllImage.count > 4 {
            self.trendingImages = self.listAllImage.suffix(4)
        }
    }
    
    func getImageByID(id: String) -> ImageModel? {
        let items = self.listAllImage.filter { image in
            return image.heroID == id
        }
        return items.first
    }
  
    
    func getImageURL(id: String) async -> URL? {
        if let model = getImageByID(id: id) {
            let url = await getURL(path: model.thumbnail)
            model.thumbnailFull = url?.absoluteString ?? ""
            return url
        }
        return nil
    }
    
    
    func getURL(path: String) async -> URL? {
        let storage = Storage.storage()
        let storageRef = storage.reference().child(path)
        do {
            let url = try await storageRef.downloadURL()
            return url
        } catch {
            return nil
        }
    }
    
    func getImageOriginal(path: String, completion: @escaping (Data?, Error?, Double) -> Void) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child(path)
        var progress: Double = 0.0
        let now = Date().timeIntervalSince1970
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
            progress += 0.05
            completion(nil, nil, progress)
        })
        timer.fire()
        do {
            
            let url = storageRef.getData(maxSize: 10000000) { data, error in
                if let error = error {
                    print("Error downloading image: \(error)")
                    completion(nil, error, 0)
                    return
                }
                print("Total time downloaded image:\(Date().timeIntervalSince1970 - now)")
                if let data = data {
                    // Use the downloaded image data (e.g., display in an Image view)
                    print("Image downloaded successfully!")
                    completion(data, nil, 1.0)
                    timer.invalidate()
                    
                }
            }
            
        } catch  let err{
            print(err.localizedDescription)
            completion(nil, err, 0)
        }
    }
    
    
}
