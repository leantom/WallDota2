//
//  StoryListView.swift
//  WallDota2
//
//  Created by QuangHo on 19/9/24.
//

import SwiftUI

struct StoryListView: View {
    @Binding var stories: [StoryModel]
    
    var actionChoose:(StoryModel)->()

    var body: some View {
        VStack {
            
            ForEach(stories, id: \.id) { story in
                StoryCardView(story: story)
                    .onTapGesture {
                        withAnimation {
                            self.actionChoose(story)
                        }
                    }
            }
        }
    }
}

struct StoryCardView: View {
    let story: StoryModel
    @State var thumbnail: String = ""
    @State var isLike: Bool = false
    @State var likeCount: Int = 0 // New State to track likeCount
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Author Image
                AsyncImage(url: URL(string: "https://picsum.photos/100")) { image in
                    image.resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } placeholder: {
                    ProgressView()
                        .frame(width: 40, height: 40)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(story.author)
                        .font(.subheadline)
                        .bold()
                    Text(story.heroid)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text(story.content.titleDescription ?? "")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(story.content.storyDescription ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                }
                Spacer()
                AsyncImage(
                    url: URL(string: thumbnail)) { image in
                    image
                        .resizable()
                        .frame(width: 60, height: 60, alignment: .center)
                        .overlay {
                            Rectangle().stroke(.gray.opacity(0.2), lineWidth: 2)
                        }
                } placeholder: {
                    ProgressView()
                }
                .aspectRatio(3 / 2, contentMode: .fill)
                .shadow(radius: 4)
            }
            
            HStack {
                Text(story.publicationDate.timeIntervalSince1970.formatTimestamp())
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                HStack(spacing: 5) {
                    
                   
                    Image(systemName: isLike ? "heart.fill" : "heart")
                        .foregroundColor(isLike ? .red : .gray)
                        .onTapGesture {
                            withAnimation {
                                isLike.toggle()
                                Task {
                                    let viewModel = StoryViewModel()
                                    let isSuccess = await viewModel.likeStory(by: story.id)
                                    if isSuccess == false {
                                        isLike.toggle() // Undo the like if failed
                                    } else {
                                        likeCount += isLike ? 1 : -1 // Increment/Decrement the likeCount
                                    }
                                }
                            }
                        }
                    Text("\(likeCount)")
                        .font(.caption)
                }
                .foregroundColor(.gray)
                
//                HStack(spacing: 5) {
//                    Image(systemName: "message")
//                    Text("\(story.likeCount ?? 0)")
//                        .font(.caption)
//                }
//                .foregroundColor(.gray)
            }
            Divider()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
        .onAppear {
            Task {
                thumbnail = story.thumbnail
                likeCount = story.likeCount ?? 0 // Set the initial like count
                let firebaseData = FireStoreDatabase.shared
                let url = await firebaseData.getURL(path: story.thumbnail)
                if let _url = url, !_url.absoluteString.isEmpty {
                    story.thumbnail = url?.absoluteString ?? ""
                    thumbnail = story.thumbnail
                }
            }
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
    }
}

struct WrapperStoryList: View {
    @State var list : [StoryModel] = [StoryModel(), StoryModel(), StoryModel()]
    var body: some View {
        StoryListView(stories: $list, actionChoose: {
            item in
            
        })
    }
}

#Preview {
    WrapperStoryList()
}
