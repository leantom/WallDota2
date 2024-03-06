//
//  NotificationView.swift
//  WallDota2
//
//  Created by QuangHo on 29/12/2023.
//

import SwiftUI

import SwiftUI

struct NotificationsView: View {
    // Fetch notifications from Firestore or a local data source
    
    @State var notifications: [Notification] = []
    
    var body: some View {
        List {
            ForEach(notifications, id: \.id) { notification in
                NotificationRow(notification: notification)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Notifications")
    }
}

struct NotificationRow: View {
    
    let notification: Notification
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(notification.commenterName)
                    .font(.headline)
                Text(notification.commentText)
                    .font(.subheadline)
                Text(notification.commentText)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()

            // Mark as read button or other actions
            if !notification.isRead {
                Image(systemName: "circle.fill")
                    .foregroundColor(.blue)
                    .onTapGesture {
                        // Mark notification as read in Firestore or local storage
                    }
            }
        }
    }
}

#Preview {
    NotificationsView()
}
