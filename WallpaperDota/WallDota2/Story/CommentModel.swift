//
//  CommentModel.swift
//  WallDota2
//
//  Created by QuangHo on 29/9/24.
//
import Foundation
import FirebaseFirestore

class CommentModel: Codable, Identifiable, ObservableObject {
    var id: String
    let author: String
    let userId: String
    let content: String
    var likeCount: Int? = 0
    let date: Date
    var formattedDate: String {
        
        return date.timeAgoDisplay()
    }
    enum CodingKeys: String, CodingKey {
        case id
        case author
        case userId
        case content
        case date
        case likeCount
    }

    init(id: String, author: String, userId: String, content: String, date: Date, likeCount: Int) {
        self.id = id
        self.author = author
        self.userId = userId
        self.content = content
        self.date = date
        self.likeCount = likeCount
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        author = try container.decode(String.self, forKey: .author)
        userId = try container.decode(String.self, forKey: .userId)
        content = try container.decode(String.self, forKey: .content)
        date = try container.decode(Timestamp.self, forKey: .date).dateValue()
        likeCount = try? container.decode(Int.self, forKey: .likeCount)
        if likeCount == nil {
            likeCount = 0
            
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(author, forKey: .author)
        try container.encode(userId, forKey: .userId)
        try container.encode(content, forKey: .content)
        try container.encode(Timestamp(date: date), forKey: .date)
        try container.encode(likeCount, forKey: .likeCount)
    }
}

extension StoryViewModel {
    func getCommentsForStory(by storyID: String) async -> [CommentModel] {
        let db = Firestore.firestore()
        let commentsRef = db.collection("stories").document(storyID).collection("comments")
        do {
            let querySnapshot = try await commentsRef.getDocuments()
            let comments = querySnapshot.documents.compactMap { document in
                do {
                    let item = try document.data(as: CommentModel.self)
                    item.id = document.documentID
                    return item
                } catch {
                    print("Error decoding getTop5StoriesByHeroID: \(error.localizedDescription)")
                    return nil
                }
                
            }
            
            return comments
        } catch {
            print("Error fetching comments: \(error.localizedDescription)")
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
    func commentStory(by storyID: String, comment: CommentModel) async {
        let db = Firestore.firestore()
        let commentRef = db.collection("stories").document(storyID).collection("comments")
        
        print("Attempting to add a comment to storyID: '\(storyID)'")
        print("Writing to path: stories/\(storyID)/comments")
        
        let author = LoginViewModel.shared.userLogin?.username ?? "Anonymous"
        let userId = LoginViewModel.shared.userLogin?.userid ?? "Anonymous"
        
        let commentData: [String: Any] = [
            "author": author,
            "userId": userId,
            "content": comment.content,
            "date": Timestamp(date: Date())
        ]
        
        print("Comment Data (before adding): \(commentData)")
        
        do {
            // Add the comment and get the reference to the newly added document
            let newCommentRef = try await commentRef.addDocument(data: commentData)
            
            // Get the auto-generated document ID
            let commentID = newCommentRef.documentID
            
            // Update the comment with the generated ID
            try await newCommentRef.updateData([
                "id": commentID
            ])
            
            print("Comment added successfully with ID: \(commentID)")
        } catch let err {
            print("Failed to add comment: \(err.localizedDescription)")
        }
    }
    func likeStory(by storyID: String) async -> Bool {
        let db = Firestore.firestore()
        let storyRef = db.collection("stories").document(storyID)
        let likesRef = storyRef.collection("likes")
        let userId = LoginViewModel.shared.userLogin?.userid ?? "Anonymous"

        do {
            // Check if the user has already liked the story
            let likeDoc = likesRef.document(userId)
            let docSnapshot = try await likeDoc.getDocument()
            if docSnapshot.exists {
                print("User has already liked this story.")
                return false
            }

            // Add a like document for the user
            try await likeDoc.setData([
                "likedAt": Timestamp(date: Date())
            ])

            // Increment the like count atomically
            try await storyRef.updateData([
                "likeCount": FieldValue.increment(Int64(1))
            ])

            print("Story liked successfully.")
            return true
        } catch {
            print("Failed to like story: \(error.localizedDescription)")
            return false
        }
    }
    
}
