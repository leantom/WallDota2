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
import Algorithms

class FireStoreDatabase {
    var listAllImage : [ImageModel] = []
    var spotlightImages : [ImageModel] = []
    var trendingImages : [ImageModel] = []
    var listCollectionImages : [ImageModel] = []
    var listImageLiked : [ImageModel] = []
    var listPositionRanking : [ImageModel] = []
    
    
    var heroesID : [String] = []
    
    static let shared = FireStoreDatabase()
    
    public func fetchDataFromFirestore() async {
        let db = Firestore.firestore()
        let collectionRef = db.collection("heroes")
        let date = Date().timeIntervalSince1970
        
        await self.getSpotlightImages()
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
            self.listAllImage = _items.sorted(by: { item1, item2 in
                return item1.likeCount > item2.likeCount
            })
            
            self.getTrendingImages()
            self.getHeroesID()
            self.getListPositionRanking()
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

            self.listCollectionImages = _items
            print("total time fetchDataCollectionFromFirestore :\(Date().timeIntervalSince1970 - date)")
        } catch {
            print("Error getting documents: \(error.localizedDescription)")
        }
    }
    
    public func fetchDataHeroFromFirestore(id: String) async -> [ImageModel]? {
        let db = Firestore.firestore()
        let collectionRef = db.collection("heroes")
        do {
            let imagesCollection = collectionRef.whereField("heroID", isEqualTo: id)
            let snapshot = try await imagesCollection.getDocuments()
            let _items = snapshot.documents.compactMap { document in
                do {
                    let item =  try document.data(as: ImageModel.self)
                    return item
                    
                } catch {
                    print("Error decoding item: \(error.localizedDescription)")
                    return nil
                }
            }
            return _items
        } catch let err{
            print(err.localizedDescription)
            return nil
        }
        
    }
    
    
    
    static public func likeImage(image: ImageModel) async {
        let db = Firestore.firestore()
        let collectionRef = db.collection("likes")
        
        do {
            
            let collectionDocumentRef = db.collection("heroes").document(image.id)
            try await collectionDocumentRef.updateData(["likeCount": image.likeCount + 1])
            
        } catch let err{
            print(err.localizedDescription)
        }
        
        
        do {
            
            try await collectionRef.addDocument(data: ["documentid": image.id,
                                                       "userid": LoginViewModel.shared.user?.uid ?? ""])
        } catch let err{
            print(err.localizedDescription)
        }
        
    }
    
    
    static public func reportImage(image: ImageModel) async {
        let db = Firestore.firestore()
        let collectionRef = db.collection("report")
        do {
            try await collectionRef.addDocument(data: ["documentid": image.id,
                                                       "userid": LoginViewModel.shared.user?.uid ?? ""])
        } catch let err{
            print(err.localizedDescription)
        }
    }
    
    static public func addComment(imageModel: ImageModel,
                                  newCommentText: String) async -> Bool{
        let db = Firestore.firestore()
        
        do {
            
            let collectionDocumentRef = db.collection("heroes").document(imageModel.id)
            try await collectionDocumentRef.updateData(["commentCount": imageModel.commentCount + 1])
            
        } catch let err{
            print(err.localizedDescription)
        }
        
        let commentRef = db.collection("posts").document(imageModel.id).collection("comments")
        do {
            try await commentRef.addDocument(data: [
                "id": UUID().uuidString,
                "author": LoginViewModel.shared.userLogin?.username ?? "Anonymous", // Replace with actual author information
                "userid": LoginViewModel.shared.userLogin?.userid ?? "Anonymous",
                "content": newCommentText,
                "date": Date()
            ])
            print("addComment susscess")
            return true
        } catch let err{
            print(err.localizedDescription)
            print("addComment fail")
            return false
        }
    }
    
    static public func fetchComments(postId: String,
                       completation: @escaping([Comment]) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("posts").document(postId).collection("comments")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching comments:", error)
                } else {
                    
                    do {
                        if let comments = try snapshot?.documents.compactMap({ doc in
                            try doc.data(as: Comment.self)
                        }) {
                            completation(comments)
                        }
                    } catch let err{
                        completation([])
                        print(err.localizedDescription)
                    }
                }
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
                    print("Error decoding getImagesLiked: \(error.localizedDescription)")
                    return nil
                }
            }

            print("total time getImagesLiked :\(Date().timeIntervalSince1970 - date)")
            let __items = _items.uniqued(on: \.documentid)
            for item in __items {
                if let model = await self.getDocument(by: item.documentid) {
                    model.id = item.documentid
                    self.listImageLiked.append(model)
                }
            }
            print(listImageLiked.compactMap({$0.id}))
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
                print("Error decoding getDocument: \(error.localizedDescription)")
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
    
    
    private func getSpotlightImages() async {
        let db = Firestore.firestore()
        let collectionRef = db.collection("spotlights")
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

            print("total time getSpotlightImages :\(Date().timeIntervalSince1970 - date)")
            self.spotlightImages = _items.sorted(by: { item1, item2 in
                return item1.likeCount > item2.likeCount
            })
            
            
        } catch {
            print("Error getting documents: \(error.localizedDescription)")
        }
        
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
    
    private func getListPositionRanking() {
        if self.listAllImage.count > 10 {
            let listTop10 = Array(FireStoreDatabase.shared.listAllImage[0..<10])
            var i = 1
            for item in listTop10 {
                item.positionRankings = i
                i += 1
            }
            listPositionRanking = listTop10
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
    
    
    func createItemDownload(item: ItemDownload) async -> Bool {
        let isValidDownload = await checkNumberDownloadUser()
        if isValidDownload {
            let db = Firestore.firestore()
            let collectionRef = db.collection("downloads")
            do {
                try await collectionRef.addDocument(data: ["imageid": item.imageid,
                                                           "created_at": item.created_at,
                                                           "userid": item.userid])
            } catch let err{
                print(err.localizedDescription)
            }
        }
        return isValidDownload
    }
    
    func checkNumberDownloadUser() async -> Bool {
        let timestampToday = Date()
        let calendar = Calendar.current
        let startTime = calendar.startOfDay(for: timestampToday)
        guard let endTime = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: timestampToday) else {return false}
        
        let db = Firestore.firestore()
        let collectionRef = db.collection("downloads")
            .whereField("userid", isEqualTo: LoginViewModel.shared.userLogin?.userid ?? "")
            .whereField("created_at", isGreaterThanOrEqualTo: startTime.timeIntervalSince1970)
            .whereField("created_at", isLessThanOrEqualTo: endTime.timeIntervalSince1970)
            
        do {
            let documents = try await collectionRef.getDocuments()
            if documents.count > 5 {
                return false
            }
            return true
        } catch let err{
            print(err.localizedDescription)
            return false
            
        }
        
        
    }
    
}
