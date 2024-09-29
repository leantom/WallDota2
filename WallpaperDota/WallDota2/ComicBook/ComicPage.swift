//
//  ComicPage.swift
//  WallDota2
//
//  Created by QuangHo on 26/9/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct ChapterModel: Codable, Identifiable {
     var id: String?
    var chapterNumber: Int
    var title: String
    var pages: [String]
    var releaseDate: Timestamp
    var typeChapter: String

    enum CodingKeys: String, CodingKey {
        case chapterNumber = "chapter_number"
        case title
        case pages
        case releaseDate = "release_date"
        case typeChapter = "type_chapter"
    }
}

class ComicViewModel: ObservableObject {
    @Published var chapters: [ChapterModel] = [
        
    ]
    
    func fetchChapters(comicId: String) async {
       
        do {
            let db = Firestore.firestore()
            let chaptersRef = db.collection("Comics").document(comicId).collection("chapters")
            let snapshot = try await chaptersRef.order(by: "chapter_number").getDocuments()
            
            var fetchedChapters: [ChapterModel] = []
            for document in snapshot.documents {
                if var chapter = try? document.data(as: ChapterModel.self) {
                    chapter.id = document.documentID
                    fetchedChapters.append(chapter)
                } else {
                    print("Failed to decode chapter document: \(document.documentID)")
                }
            }
            DispatchQueue.main.async {
                self.chapters = fetchedChapters
            }
            
        } catch {
            print("Error fetching chapters: \(error)")
        }
    }
    
    // Function to update the viewCount of a comic
    func updateViewCount(comicId: String) async {
        let db = Firestore.firestore()
        let comicRef = db.collection("Comics").document(comicId)
        do {
            // Use FieldValue.increment to atomically increment the viewCount
            try await comicRef.updateData([
                "view_count": FieldValue.increment(Int64(1))
            ])
            print("View count updated successfully for comic ID: \(comicId)")
        } catch {
            print("Error updating view count: \(error)")
        }
    }
    
    func fetchComics() async -> [ComicModel]{
        do {
            let db = Firestore.firestore()
            let comicsRef = db.collection("Comics")
            let snapshot = try await comicsRef.order(by: "rating", descending: true).getDocuments()
            
            var comics: [ComicModel] = []
            
            for document in snapshot.documents {
                do {
                    // Try to decode the document into ComicModel
                    var comic = try document.data(as: ComicModel.self)
                    comic.id = document.documentID
                    comics.append(comic)
                } catch let decodingError {
                    // Log document ID and the decoding error for easier debugging
                    print("Failed to decode comic document \(document.documentID): \(decodingError)")
                    print("Data: \(document.data())") // Log the actual data for inspection
                }
            }
            return comics
        } catch {
            print("Error fetching comics: \(error)")
        }
        return []
    }
    
    func fetchMostViewComics() async -> [ComicModel]{
        do {
            let db = Firestore.firestore()
            let comicsRef = db.collection("Comics")
            let snapshot = try await comicsRef.order(by: "view_count", descending: true).limit(to: 5).getDocuments()
            
            var comics: [ComicModel] = []
            
            for document in snapshot.documents {
                do {
                    // Try to decode the document into ComicModel
                    var comic = try document.data(as: ComicModel.self)
                    comic.id = document.documentID
                    comics.append(comic)
                } catch let decodingError {
                    // Log document ID and the decoding error for easier debugging
                    print("Failed to decode comic document \(document.documentID): \(decodingError)")
                    print("Data: \(document.data())") // Log the actual data for inspection
                }
            }
            return comics
        } catch {
            print("Error fetching comics: \(error)")
        }
        return []
    }
    
    func followComic(comic: ComicModel) async {
        guard let user = Auth.auth().currentUser else {
            print("No user is logged in")
            return
        }

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        let followingRef = userRef.collection("following")
        print("userid :\(user.uid)")
        let data: [String: Any] = [
            "following_comic_id": comic.id ?? "",
            "follow_date": Timestamp(date: Date())
        ]
        
        do {
            let newDocRef = followingRef.document() // Create a new document with an auto-generated ID
            try await newDocRef.setData(data)
            print("Successfully followed comic \(comic.title)")
        } catch {
            print("Error adding following document: \(error)")
        }
    }
}

struct ComicModel: Codable, Identifiable, Hashable {
    var id: String?
    var title: String
    var description: String
    var genre: [String]
    var author: String
    var coverImageUrl: String
    var language: String
    var totalChapters: Int
    var rating: Double
    var totalReviews: Int
    var viewCount: Int
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case genre
        case author
        case coverImageUrl = "cover_image_url"
        case language
        case totalChapters = "total_chapters"
        case rating
        case totalReviews = "total_reviews"
        case viewCount = "view_count"
    }
}
