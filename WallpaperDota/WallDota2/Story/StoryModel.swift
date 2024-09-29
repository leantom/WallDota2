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
    var likeCount: Int?
    var created_at: Double?
    let author: String
    var documentId: String?
    let publicationDate: Date
    var relatedArticles: [String]
    var chapterNumber: Int? // Thêm biến chapterNumber
    @Published var isLoadedThumbnail: Bool = false

    enum CodingKeys: String, CodingKey {
        case heroid
        case id
        case content
        case thumbnail
        case image
        case likeCount
        case created_at
        case author
        case publicationDate
        case relatedArticles
        case chapterNumber
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        heroid = try container.decode(String.self, forKey: .heroid)
        id = try container.decode(String.self, forKey: .id)
        content = try container.decode(StoryModel.Content.self, forKey: .content)
        thumbnail = try container.decode(String.self, forKey: .thumbnail)
        image = try container.decode(String.self, forKey: .image)
        likeCount = try? container.decode(Int.self, forKey: .likeCount)
        created_at = try? container.decode(Double.self, forKey: .created_at)
        author = try container.decode(String.self, forKey: .author)
        publicationDate = try container.decode(Date.self, forKey: .publicationDate)
        relatedArticles = try container.decode([String].self, forKey: .relatedArticles)
        chapterNumber = try? container.decode(Int.self, forKey: .chapterNumber) // Giải mã chapterNumber

        if created_at == nil {
            created_at = Date().timeIntervalSince1970
        }
    }

    init(
        heroid: String,
        id: String,
        content: StoryModel.Content,
        author: String,
        publicationDate: Date,
        relatedArticles: [String],
        chapterNumber: Int?, // Thêm chapterNumber vào init
        likeCount: Int = 0
    ) {
        self.heroid = heroid
        self.id = id
        self.content = content
        self.thumbnail = ""
        self.image = ""
        self.likeCount = likeCount
        self.created_at = Date().timeIntervalSince1970
        self.author = author
        self.publicationDate = publicationDate
        self.relatedArticles = relatedArticles
        self.chapterNumber = chapterNumber
    }

    init() {
        self.heroid = "Vengeful Spirit"
        self.id = UUID().uuidString
        self.content = Content(
            title_en: "Adventures in Perilous Lands",
            story_en: "Vengeful Spirit courageously ventures into dangerous lands...",
            title_vi: "Những cuộc phiêu lưu trong vùng đất nguy hiểm",
            story_vi: "Vengeful Spirit can đảm tiến vào những vùng đất nguy hiểm..."
        )
        self.thumbnail = "thumbnail/VengefulSpirit/VengefulSpiritImage"
        self.image = ""
        self.likeCount = 0
        self.created_at = Date().timeIntervalSince1970
        self.author = "Default Author"
        self.publicationDate = Date()
        self.relatedArticles = []
        self.chapterNumber = nil // Hoặc gán giá trị mặc định nếu cần
    }

    func getURLThumbnail() async -> URL? {
        return await FireStoreDatabase.shared.getURL(path: self.thumbnail)
    }

    func getURLImage() async -> URL? {
        return await FireStoreDatabase.shared.getURL(path: self.image)
    }
}

extension StoryModel {
    class Content: Codable, ObservableObject {
        let title_en: String?
        let story_en: String?
        let title_vi: String?
        let story_vi: String?
        
        enum CodingKeys: String, CodingKey {
            case title_en
            case story_en
            case title_vi
            case story_vi
        }
        
        init(
            title_en: String? = nil,
            story_en: String? = nil,
            title_vi: String? = nil,
            story_vi: String? = nil
        ) {
            self.title_en = title_en
            self.story_en = story_en
            self.title_vi = title_vi
            self.story_vi = story_vi
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            title_en = try? container.decode(String.self, forKey: .title_en)
            story_en = try? container.decode(String.self, forKey: .story_en)
            title_vi = try? container.decode(String.self, forKey: .title_vi)
            story_vi = try? container.decode(String.self, forKey: .story_vi)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(title_en, forKey: .title_en)
            try container.encodeIfPresent(story_en, forKey: .story_en)
            try container.encodeIfPresent(title_vi, forKey: .title_vi)
            try container.encodeIfPresent(story_vi, forKey: .story_vi)
        }
        
        // Thêm thuộc tính tính toán titleDescription
        var titleDescription: String? {
            let preferredLanguage = getCurrentLanguage()
            if preferredLanguage.hasPrefix("vi") {
                return title_vi ?? title_en
            } else {
                return title_en ?? title_vi
            }
        }
        
        var storyDescription: String? {
            let preferredLanguage = getCurrentLanguage()
            let storyText: String?
            
            if preferredLanguage.hasPrefix("vi") {
                storyText = story_vi ?? story_en
            } else {
                storyText = story_en ?? story_vi
            }
            
            guard let text = storyText else {
                return nil
            }
            
            let words = text.components(separatedBy: .whitespacesAndNewlines)
            let first10Words = words.prefix(10)
            return first10Words.joined(separator: " ")
        }
        
        var storyContent: String {
            let preferredLanguage = getCurrentLanguage()
            var storyText: String = ""
            
            if preferredLanguage.hasPrefix("vi") {
                storyText = story_vi ?? ""
            } else {
                storyText = story_en ?? ""
            }
            
            return storyText
        }
        
    }
}


class StoryViewModel {
    let firebaseDB = FireStoreDatabase.shared
    static let shared = StoryViewModel()
    var topStory:[StoryModel] = []
    func getStoryByHeroID(by heroID: String) async -> [StoryModel] {
        let db = Firestore.firestore()
        let collectionRef = db.collection("stories").whereField("heroid", isEqualTo: heroID)
        let date = Date().timeIntervalSince1970
        print("total time fetchDataFromFirestore :\(Date().timeIntervalSince1970 - date)")
        do {
            let documentsnap = try await collectionRef.getDocuments()
            
            let _items = documentsnap.documents.compactMap { document in
                do {
                    let item =  try document.data(as: StoryModel.self)
                    item.documentId = document.documentID
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
    
    func getTop5StoriesByHeroID(language: String) async -> [StoryModel] {
        let db = Firestore.firestore()
        let collectionRef = db.collection("stories")
            .order(by: "likeCount", descending: true) // Order by likeCount in descending order
            .limit(to: 10)
        let date = Date().timeIntervalSince1970
        do {
            let documentsnap = try await collectionRef.getDocuments()
            
            var _items = documentsnap.documents.compactMap { document in
                do {
                    let item =  try document.data(as: StoryModel.self)
                    item.documentId = document.documentID
                    return item
                    
                } catch {
                    print("Error decoding getTop5StoriesByHeroID: \(error.localizedDescription)")
                    return nil
                }
            }
            _items.sort { item1, item2 in
                if let chap1 = item1.likeCount,
                   let chap2 = item2.likeCount {
                    return chap1 > chap2
                }
                return true
            }
            topStory.append(contentsOf: _items)
            print("total time  getTop5StoriesByHeroID :\(Date().timeIntervalSince1970 - date)")
            return _items
        } catch let err {
            print(err.localizedDescription)
            return []
        }
    }
    
}

extension StoryViewModel {
    func likeComment(by storyID: String, commentID: String) async -> Bool {
        let db = Firestore.firestore()
        let commentRef = db.collection("stories").document(storyID).collection("comments").document(commentID)
        let likesRef = commentRef.collection("likes")
        let userId = LoginViewModel.shared.userLogin?.userid ?? "Anonymous"

        do {
            // Check if the user has already liked the comment
            let likeDoc = likesRef.document(userId)
            let docSnapshot = try await likeDoc.getDocument()
            if docSnapshot.exists {
                print("User has already liked this comment.")
                return false
            }

            // Add a like document for the user
            try await likeDoc.setData([
                "likedAt": Timestamp(date: Date())
            ])

            // Increment the like count atomically
            try await commentRef.updateData([
                "likeCount": FieldValue.increment(Int64(1))
            ])

            print("Comment liked successfully.")
            return true
        } catch {
            print("Failed to like comment: \(error.localizedDescription)")
            return false
        }
    }
}

extension StoryViewModel {
    func didUserLikeComment(by storyID: String, commentID: String) async -> Bool {
        let db = Firestore.firestore()
        let commentRef = db.collection("stories").document(storyID).collection("comments").document(commentID)
        let likesRef = commentRef.collection("likes")
        let userId = LoginViewModel.shared.userLogin?.userid ?? "Anonymous"

        do {
            // Check if the user has liked the comment
            let likeDoc = likesRef.document(userId)
            let docSnapshot = try await likeDoc.getDocument()

            if docSnapshot.exists {
                print("User has liked this comment.")
                return true
            } else {
                print("User has not liked this comment.")
                return false
            }
        } catch {
            print("Error checking if user liked comment: \(error.localizedDescription)")
            return false
        }
    }
}
