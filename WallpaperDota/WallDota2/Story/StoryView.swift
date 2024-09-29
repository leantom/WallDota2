import SwiftUI
import SDWebImageSwiftUI

struct StoryView: View {
    @Environment(\.dismiss) var dismiss
    @State var model: StoryModel
    @State var isGetDoneAPI: Bool = false
    @State private var alphaButtonClose: CGFloat = 0.5
    
    @State var isVietnameseLanguage: Bool = false
    @State var listStoryModel: [StoryModel] = []
    
    var actionChooseStory: (StoryModel) -> ()
    @State var contentStory: LocalizedStringKey = ""
    @State var isLike: Bool = false
    
    
    var body: some View {
        ZStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack {
                        VStack {
                            // image
                            ZStack {
                                if isGetDoneAPI {
                                    AnimatedImage(url: URL(string: model.thumbnail))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .scaledToFill()
                                        .frame(height: 250)
                                        .clipped()
                                        .clipShape(
                                            .rect(
                                                topLeadingRadius: 20,
                                                bottomLeadingRadius: 0,
                                                bottomTrailingRadius: 0,
                                                topTrailingRadius: 20
                                            )
                                        )
                                } else {
                                    ProgressView()
                                }
                                
                                VStack {
                                    Spacer()
                                    HStack {
                                        avatar
                                        Spacer()
                                    }
                                }
                            }
                        }
                        VStack(spacing: 10) {
                            HStack {
                                Text(isVietnameseLanguage ? "Câu chuyện dưới đây hoàn toàn là hư cấu..." : "The story below is purely fictional...")
                                    .fontWeight(.light)
                                    .font(.caption)
                                    .padding(.leading, 15)
                                
                                Spacer()
                                
                                LanguageSwitchView (isVietnamese: $isVietnameseLanguage)
                                    .onChange(of: isVietnameseLanguage) { newValue in
                                        contentStory = LocalizedStringKey(model.content.storyContent)
                                    }
                            }
                            
                            HStack {
                                Text(model.content.titleDescription ?? "")
                                    .fontWeight(.bold)
                                    .font(.title2)
                                    .padding(.leading, 15)
                                Spacer()
                            }
                            
                            VStack {
                                Text(contentStory)
                                    .font(.system(size: 13, weight: .regular, design: .default))
                                    .lineSpacing(10)
                                    .padding()
                            }

                        }
                        
                        BannerView(adSizeGlobal)
                          .frame(height: 50)
                        
                        // Get related articles
                        StoryListView(stories: $listStoryModel, actionChoose: { item in
                            self.model = item
                            contentStory = LocalizedStringKey(item.content.storyContent)
                            withAnimation {
                                scrollProxy.scrollTo("top", anchor: .top)
                            }
                        })
                    }
                    .id("top") // Assign an ID to the top of the ScrollView content
                }
                .onAppear {
                    Task {
                        let firebaseData = FireStoreDatabase.shared
                        let url = await firebaseData.getURL(path: model.thumbnail)
                        if let _url = url, !_url.absoluteString.isEmpty {
                            model.thumbnail = _url.absoluteString
                        }
                        isGetDoneAPI = true
                    }
                    contentStory =  LocalizedStringKey(model.content.storyContent)
                    isVietnameseLanguage = getCurrentLanguage() == "vi"
                }
            }
            
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .foregroundColor(.black.opacity(alphaButtonClose))
                            .font(.title)
                    }
                    Spacer()
                }
                Spacer()
            }.padding()
            
            VStack {
                Spacer()
                HStack(spacing: 10) {
                    Spacer()
                    Button(action: {
                        print("Round Action")
                    }) {
                        Image(systemName: "heart")
                            .frame(width: 35, height: 35)
                            .foregroundColor(isLike ? .red : .white) // Change color to red when liked
                            .background(Color(red: 0.104, green: 0.082, blue: 0.243))
                            .clipShape(Circle())
                            .shadow(color: .gray, radius: 5, x: 2, y: 2)
                            .onTapGesture {
                                withAnimation {
                                    isLike.toggle() // Toggle the like state
                                    Task {
                                        let viewModel = StoryViewModel()
                                        
                                        let isSuccess =  await viewModel.likeStory(by: model.id)
                                        
                                        if isSuccess {
                                            // Handle success, e.g., increase like count locally if needed
                                            print("Successfully liked story")
                                        } else {
                                            // Handle failure, revert the like state if needed
                                            isLike.toggle() // Revert like state on failure
                                            print("Failed to like story")
                                        }
                                    }
                                }
                            }
                    }
                    Button(action: {
                        print("Round Action")
                    }) {
                        Image(systemName: "ellipsis")
                            .frame(width: 35, height: 35)
                            .foregroundColor(Color.white)
                            .background(Color(red: 0.104, green: 0.082, blue: 0.243))
                            .clipShape(Circle())
                            .shadow(color: .gray, radius: 5, x: 2, y: 2)
                    }.padding(.trailing, 15)
                }
            }
        }
        .onAppear(perform: {
            let viewModel = StoryViewModel()
            Task {
                
                listStoryModel = await viewModel.gettoriesByHeroID(by:model.heroid)

            }
        })
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
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(model.author)
                        .foregroundColor(.white)
                        .bold()
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
        }
    }
}

struct WrappedStoryView: View {
    @State var model = StoryModel()
    @State var islanguage: Bool = true
    var body: some View {
        StoryView(model: model, actionChooseStory: { item in
            print(item.heroid)
        })
    }
}

#Preview {
    WrappedStoryView()
}
