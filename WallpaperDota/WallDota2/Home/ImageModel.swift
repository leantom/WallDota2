//
//  ImageModel.swift
//  WallDota2
//
//  Created by QuangHo on 14/12/2023.
//

import Foundation

class ImageLikeModel: Codable, Identifiable {
    var id: String = ""
    var userid: String
    var documentid: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userid
        case documentid
    }
    
    required init(from decoder: Decoder) throws {
        // Extract and assign values to each property
        // Use try decoder.decode(_:) to decode individual properties
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        userid = try container.decode(String.self, forKey: .userid)
        documentid = try container.decode(String.self, forKey: .documentid)
        id = UUID().uuidString
        // Decode other properties similarly
    }
    
}

class ImageModel: Codable, Identifiable, ObservableObject {
    var id: String
    var likeCount: Int = 0
    var heroID: String
    var imageName: String
    var imageUrl: String
    var thumbnail: String
    var priority: String = ""
    var imageUrlFull: String = ""
    var thumbnailFull: String = ""
    var commentCount = 0
    var isReport: Bool = false
    var positionRankings = 0
    @Published var isLoadedThumbnail: Bool = false
    @Published var isLoadedImageOriginal: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case heroID
        case imageName
        case imageUrl
        case thumbnail
        case likeCount
        case commentCount
    }
    
    required init(from decoder: Decoder) throws {
        // Extract and assign values to each property
        // Use try decoder.decode(_:) to decode individual properties
        let container = try decoder.container(keyedBy: CodingKeys.self)
        heroID = try container.decode(String.self, forKey: .heroID)
        imageName = try container.decode(String.self, forKey: .imageName)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        thumbnail = try container.decode(String.self, forKey: .thumbnail)
        likeCount = try container.decode(Int.self, forKey: .likeCount)
        
        commentCount = try container.decode(Int.self, forKey: .commentCount)
        id = UUID().uuidString
        // Decode other properties similarly
    }
    
    init(){
        id = UUID().uuidString
        heroID = "invoker"
        imageName = "invo"
        imageUrl = "https://firebasestorage.googleapis.com/v0/b/dotadressup.appspot.com/o/images%2FPhantom%20assassin%2FPhantom%20assassin58931?alt=media&token=33fc2537-481e-42bd-9bd7-4266442c5faa"
        thumbnail = "https://firebasestorage.googleapis.com/v0/b/dotadressup.appspot.com/o/images%2FPhantom%20assassin%2FPhantom%20assassin58931?alt=media&token=33fc2537-481e-42bd-9bd7-4266442c5faa"
        likeCount = 0
    }

}
