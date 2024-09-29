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
    
    
    var body: some View {
        VStack {
            Text("Comments")
                .font(.headline)
                .padding(.top)
            
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
            
            Spacer()
            
            HStack {
                
                TextField("Add a comment...", text: $newCommentText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxHeight: 100)
                
                Button(action: {
                    addComment()
                    
                }) {
                    Text("Post")
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(newCommentText.trimmingCharacters(in: .whitespaces).isEmpty)
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
    @State  var isLike: Bool = false
    @State var likes: Int = 0
    var viewmodel: StoryViewModel
    var storyId: String
    
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
                    .foregroundColor(.gray)
                
                Text("\(likes)") // Replace with actual like count
            }
            .padding(.top, 5)
            .onTapGesture {
                withAnimation {
                    isLike.toggle()
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
