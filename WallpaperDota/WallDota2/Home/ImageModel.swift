//
//  ImageModel.swift
//  WallDota2
//
//  Created by QuangHo on 14/12/2023.
//

import Foundation

class ImageModel: Codable, Identifiable {
    var id: String
    
    var heroID: String
    var imageName: String
    var imageUrl: String
    var thumbnail: String
    var imageUrlFull: String = ""
    var thumbnailFull: String = ""
    
    enum CodingKeys: String, CodingKey {
        case heroID
        case imageName
        case imageUrl
        case thumbnail
    }
    
    required init(from decoder: Decoder) throws {
        // Extract and assign values to each property
        // Use try decoder.decode(_:) to decode individual properties
        let container = try decoder.container(keyedBy: CodingKeys.self)
        heroID = try container.decode(String.self, forKey: .heroID)
        imageName = try container.decode(String.self, forKey: .imageName)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        thumbnail = try container.decode(String.self, forKey: .thumbnail)
        
        id = UUID().uuidString
        // Decode other properties similarly
    }
    
    init(){
        id = UUID().uuidString
        heroID = "invoker"
        imageName = "invo"
        imageUrl = ""
        thumbnail = "https://firebasestorage.googleapis.com/v0/b/dotadressup.appspot.com/o/thumbnail%2Finvoker%2Finvoker26236?alt=media&token=9ae6ab2e-4d24-4c40-9543-64d4a1a6fe87"
    }

}
