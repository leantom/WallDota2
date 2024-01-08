//
//  StoryModel.swift
//  WallDota2
//
//  Created by QuangHo on 03/01/2024.
//

import Foundation
import Firebase
import FirebaseAuth

class StoryModel: Codable, Identifiable, ObservableObject {
    let heroid: String
    let id: String
    let content: StoryModel.Content
    var thumbnail: String
    var image: String
    @Published var isLoadedThumbnail: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case heroid
        case id
        case content
        case thumbnail
        case image
    }
    
    required init(from decoder: Decoder) throws {
        // Extract and assign values to each property
        // Use try decoder.decode(_:) to decode individual properties
        let container = try decoder.container(keyedBy: CodingKeys.self)
        heroid = try container.decode(String.self, forKey: .heroid)
        id = try container.decode(String.self, forKey: .id)
        content = try container.decode(StoryModel.Content.self, forKey: .content)
        thumbnail = try container.decode(String.self, forKey: .thumbnail)
        image = try container.decode(String.self, forKey: .image)
        
    }
    
    init(heroid: String, id: String, content: StoryModel.Content) {
        self.heroid = heroid
        self.id = id
        self.content = content
        thumbnail = ""
        image = ""
    }
     
    init() {
        heroid = "Vengeful Spirit"
        id = UUID().uuidString
        content = Content(title: "Adventures in Perilous Lands", story: "Vengeful Spirit courageously ventures into dangerous lands, where the forces of darkness hold sway. Intense battles and revelations of ancient secrets unfold, adding new chapters to her epic tale of revenge.")
        thumbnail = "https://firebasestorage.googleapis.com/v0/b/dotadressup.appspot.com/o/thumbnail%2FLuna%2FLuna65175?alt=media&token=b13e322f-02c1-4160-b3c0-ef5e2ae3cf3c"
        image = ""
    }
    
}

extension StoryModel {
    class Content: Codable, ObservableObject {
        let title: String
        let story: String
        init(title: String, story: String) {
            self.title = title
            self.story = story
        }
    }
}

class StoryViewModel {
    let firebaseDB = FireStoreDatabase.shared
    static let shared = StoryViewModel()
    
    func getStoryByHeroID(by heroID: String, language: String) async -> [StoryModel] {
        let db = Firestore.firestore()
        let collectionRef = db.collection("stories\(language)").whereField("heroid", isEqualTo: heroID)
        
        do {
            let documentsnap = try await collectionRef.getDocuments()
            
            let _items = documentsnap.documents.compactMap { document in
                do {
                    let item =  try document.data(as: StoryModel.self)
                    return item
                    
                } catch {
                    print("Error decoding getStoryByHeroID: \(error.localizedDescription)")
                    return nil
                }
            }
            return _items
        } catch let err{
            print(err.localizedDescription)
            return []
        }
    }
    /**
     /posts
         /postId1
             - userId: "userId1"
             - postContent: "This is the post content."
             - likesCount: 25
             - likedBy: [userId2, userId3, userId4]
         /postId2
             - userId: "userId2"
             - postContent: "Another post here."
             - likesCount: 10
             - likedBy: [userId1, userId3]
     */
    func commentStory(by id: String,
                   newCommentText: String) async {
        let db = Firestore.firestore()
        
        let commentRef = db.collection("posts").document(id).collection("comments")
        do {
            try await commentRef.addDocument(data: [
                "id": UUID().uuidString,
                "author": LoginViewModel.shared.userLogin?.username ?? "Anonymous", // Replace with actual author information
                "userid": LoginViewModel.shared.userLogin?.userid ?? "Anonymous",
                "content": newCommentText,
                "date": Date()
            ])
            print("addComment susscess")
            
        } catch let err{
            print(err.localizedDescription)
            print("addComment fail")
          
        }
    }
    
    
}

