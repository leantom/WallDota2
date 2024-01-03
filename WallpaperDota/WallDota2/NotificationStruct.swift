//
//  NotificationStruct.swift
//  
//
//  Created by QuangHo on 29/12/2023.
//

import Foundation

struct Notification: Identifiable, Codable {
    // Fields for notification details
    let id: String
    let postID: String
    let commenterID: String
    let commenterName: String
    let commentText: String
    let timestamp: Double
    let isRead: Bool
    
    // Computed property for formatted time
    var formattedTime: String {
        let timestamp = 1669651200.0  // Example timestamp
        let date = Date(timeIntervalSince1970: timestamp)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
