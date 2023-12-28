//
//  CommentView.swift
//  WallDota2
//
//  Created by QuangHo on 23/12/2023.
//

import SwiftUI
import FirebaseFirestore // Assuming Firebase integration

struct Comment: Identifiable, Codable {
    let id: String
    let author: String
    let content: String
    let date: Date
}

struct CommentsView: View {
    @State var comments: [Comment] = []
    @State var newCommentText = ""
    @Environment(\.dismiss) var dismiss
   
    let imageModel: ImageModel // Assuming a reference to a specific post
    let gradient: LinearGradient = LinearGradient(
        colors: [Color.accentColor.opacity(0.4), Color.clear],
        startPoint: .top, endPoint: .bottom
    )
    @State var isShowAlertEmpty = false
    var body: some View {
        ZStack {
            gradient
            VStack {
                HStack {
                    Spacer()
                    Text("Comments")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .font(.title3)
                            .foregroundColor(.black.opacity(0.6    ))
                    }
                    .padding()
                    
                }.background(.white)
                
                if comments.count > 0 {
                    Spacer()
                    List {
                        ForEach(comments, id: \.id) { comment in
                            CommentView(comment: comment)
                        }
                    }
                    .listStyle(.automatic)
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                } else {
                    VStack {
                        Spacer()
                        Text("No comments").font(.caption)
                        Spacer()
                        
                    }.onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
               

                HStack {
                    TextField("Add a comment...", text: $newCommentText).font(.caption)
                    Button {
                        if newCommentText.trimmingCharacters(in: .whitespaces).count == 0 {
                            isShowAlertEmpty.toggle()
                            return
                        }
              	          Task {
                            let isSuccess = await FireStoreDatabase.addComment(imageModel: imageModel, newCommentText: newCommentText)
                            if isSuccess {
                                newCommentText = ""
                            }
                        }
                        
                    } label: {
                        Text("Post").font(.title3)
                    }.alert(isPresented: $isShowAlertEmpty) {
                        Alert(
                            title: Text("Warning"),
                            message: Text("You cannot leave it empty!")
                        )
                    }
                }
                .padding()
            }
            .transition(.move(edge: .bottom))
            .onAppear {
                fetchComments()
            }
        }
        
    }

    func fetchComments() {
        
        FireStoreDatabase.fetchComments(postId: imageModel.id) { comments in
            self.comments = comments
            print(comments.compactMap({$0.content}))
        }
    }

}

struct CommentView: View {
    let comment: Comment

    var body: some View {
        HStack {
            HStack {
                HStack (spacing: 15) {
                    AsyncImage(
                      url: URL(
                          string: "https://picsum.photos/100")) { image in
                        image
                            .resizable()
                            .frame(width: 30,
                                    height: 30,
                                    alignment: .center)
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
            }
            
            VStack(alignment: .leading) {
                HStack(spacing: 10) {
                    Text(comment.author)
                        .font(.headline)
                    
                    Text(comment.date, format: .dateTime)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(comment.content)
                    .font(.caption)
            }
            
            
            
        }
        
    }
}
