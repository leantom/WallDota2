//
//  FirebaseRealtime.swift
//  WallDota2
//
//  Created by QuangHo on 29/12/2023.
//

import Foundation
import Firebase

class FirebaseRealtime: NSObject {

    func observeRealtimeDatabase(path: String, eventType: DataEventType, with completion: @escaping (DataSnapshot?) -> Void) {
        // Get a reference to the database
        let database = Database.database().reference()

        // Attach an observer to the specified path with the given event type
        database.child(path).observe(eventType, with: completion)
        
    }
    
    func observeComment(postID: String) {
        observeRealtimeDatabase(path: postID, eventType: .value) { snapshot in
            // Handle data changes within the completion closure
            if let value = snapshot?.value as? [String: Any] {
                // Access data as a dictionary
                print("Value:", value)
                // Perform actions based on the data
            } else {
                print("No data found at path:", snapshot?.key)
            }
        }

    }

}
