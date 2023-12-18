//
//  FireStoreDatabase.swift
//  WallDota2
//
//  Created by QuangHo on 14/12/2023.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore

class FireStoreDatabase {
    var listAllImage : [ImageModel] = []
    var spotlightImages : [ImageModel] = []
    var trendingImages : [ImageModel] = []
    var heroesID : [String] = []
    
    public func fetchDataFromFirestore() async {
        let db = Firestore.firestore()
        let collectionRef = db.collection("heroes")
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

            print("total time download :\(Date().timeIntervalSince1970 - date)")
            self.listAllImage = _items
            self.getTrendingImages()
            self.getSpotlightImages()
            self.getHeroesID()
        } catch {
            print("Error getting documents: \(error.localizedDescription)")
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
