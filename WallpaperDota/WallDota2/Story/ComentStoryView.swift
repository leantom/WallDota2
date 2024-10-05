//
//  ComentStoryView.swift
//  WallDota2
//
//  Created by QuangHo on 29/9/24.
//

import Foundation
import SwiftUI
import FirebaseAuth
import Combine

struct ComentStoryView: View {

    var viewModel = StoryViewModel()
    var storyId: String
    @State private var keyboardHeight: CGFloat = 0
     var cancellables: Set<AnyCancellable> = []
    
    @State private var comments: [CommentModel] = []
    @State private var newCommentText: String = ""
    @State var isSubmitComment: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            
            if UIDevice.current.userInterfaceIdiom != .pad {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .frame(width: 35, height: 35)
                            .foregroundColor(.white)
                            .background(Color(red: 0.104, green: 0.082, blue: 0.243))
                            .clipShape(Circle())
                            .shadow(color: .gray, radius: 5, x: 2, y: 2)
                    }
                    
                    Spacer()
                    HStack {
                        Text("Comments")
                            .font(.headline)
                            .padding(.leading,(UIScreen.main.bounds.width - 150 ) / 2)
                        Spacer()
                    }
                }
            } else {
                Text("Comments")
                    .font(.headline)
                    .padding(.top)
            }
            
            
            
            
            if comments.count == 0 {
                EmptyViewScreen()
            } else {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        ForEach(comments, id: \.id) { comment in
                            CommentRowView(comment: comment,
                                           viewmodel: viewModel,
                                           storyId: storyId)
                                .id(comment.id)
                            Divider()
                        }
                    }
                    .onChange(of: comments.count) { _ in
                        if let lastComment = comments.last {
                            withAnimation {
                                proxy.scrollTo(lastComment.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
           
            Spacer()
            
            HStack {
                
                TextField("Come on, say something cool!...", text: $newCommentText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxHeight: 100)
                
                if isSubmitComment {
                    LoadingView()
                        .frame(width: 60, height: 30)
                } else {
                    Button(action: {
                        isSubmitComment.toggle()
                        addComment()
                        isSubmitComment.toggle()
                    }) {
                        Text("Post")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(newCommentText.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(newCommentText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal)
        .padding(.bottom, keyboardHeight)
        .onAppear {
            loadComments()
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    
   
    
    func loadComments() {
        // Load existing comments from your data source
        Task {
            comments = await viewModel.getCommentsForStory(by: storyId)
        }
    }
    
    func addComment() {
        guard !newCommentText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        let newComment = CommentModel(
            id: UUID().uuidString,
            author: LoginViewModel.shared.userLogin?.username ?? "Anonymous",
            userId: LoginViewModel.shared.userLogin?.userid ?? "Anonymous",
            content: newCommentText.trimmingCharacters(in: .whitespacesAndNewlines),
            date: Date(), likeCount: 0
        )
        
        // Save the comment to Firestore
        Task {
            await viewModel.commentStory(by: storyId, comment: newComment)
            
            withAnimation {
                comments.append(newComment)
            }
            newCommentText = ""
        }
    }
    var avatar: some View {
        VStack(alignment: .leading) {
            HStack {
                AsyncImage(url: URL(string: "https://picsum.photos/100")) { image in
                    image
                        .resizable()
                        .frame(width: 35, height: 35, alignment: .center)
                        .clipShape(Circle())
                        .overlay {
                            Circle().stroke(.blue, lineWidth: 2)
                        }
                } placeholder: {
                    ProgressView()
                }
                .aspectRatio(3 / 2, contentMode: .fill)
                .shadow(radius: 4)
                .padding(.trailing, 18)
            }
            .padding()
        }
    }
}

struct CommentRowView: View {
    let comment: CommentModel
    @State var content: LocalizedStringKey = ""
    @State var isLike: Bool = false
    @State var likes: Int = 0
    var viewmodel: StoryViewModel
    var storyId: String
    
    // Animation state for scaling
    @State private var scaleEffect: CGFloat = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                avatar
                VStack(alignment: .leading) {
                    Text(comment.author)
                        .font(.system(size: 12, weight: .regular))
                    Text(comment.formattedDate)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                Spacer()
                // Optional: Action button
                Button(action: {
                    // Handle action (e.g., report, delete)
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            
            Text(content)
                .font(.system(size: 16, weight: .light))
                .lineSpacing(10)
            
            HStack {
                // Likes and replies
                Image(systemName: isLike ? "hand.thumbsup.fill" : "hand.thumbsup")
                    .foregroundColor(isLike ? .blue : .gray) // Change color based on like state
                    .scaleEffect(scaleEffect) // Apply scale effect
                    .animation(.easeInOut(duration: 0.3), value: scaleEffect) // Smooth animation for scaling
                
                Text("\(likes)") // Replace with actual like count
            }
            .padding(.top, 5)
            .onTapGesture {
                withAnimation {
                    isLike.toggle()
                    scaleEffect = 1.4 // Increase size on tap
                    
                    // Revert the size back to normal after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scaleEffect = 1.0
                    }
                    
                    // Uncomment when async task for liking is added
                    Task {
                        let isSuccess = await viewmodel.likeComment(by: storyId, commentID: comment.id)
                        if isSuccess {
                            likes += 1
                        }
                    }
                }
            }
        }
        .padding(.vertical)
        .onAppear {
            content = LocalizedStringKey(comment.content)
            likes = comment.likeCount ?? 0
        }
    }
    
    var avatar: some View {
        AsyncImage(url: URL(string: "https://picsum.photos/100")) { image in
            image
                .resizable()
                .frame(width: 35, height: 35)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
        } placeholder: {
            ProgressView()
        }
    }
}

struct WrapperCommentStoryView: View {
    @State var id : String = "fAUNmpX6dGjvtixMtQZB"
    var body: some View {
        ComentStoryView(storyId: id)
    }
}

#Preview {
    WrapperCommentStoryView()
}
