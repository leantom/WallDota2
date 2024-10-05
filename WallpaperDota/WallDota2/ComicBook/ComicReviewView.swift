import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage

// Comic Review View
struct ComicReviewView: View {
    var comic: ComicModel
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ComicViewModel()
    @State var isLoading: Bool = false
    @State var isShowChapterView: Bool = false
    @State var chapterSelected: ChapterModel?
    @State var isLike: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Calculate device dimensions and image height
                    let deviceHeight = UIScreen.main.bounds.height
                    let imageHeight = deviceHeight * 0.3 // 60% of device width
                    let imageDescriptionHeight = deviceHeight * 0.5 // 60% of device width
                    
                    // Cover Image
                    AsyncImage(url: URL(string: comic.coverImageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        
                    } placeholder: {
                        Color.gray
                    }
                    .frame(height: imageHeight)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .clipped()
                    
                    // Comic Title and Author
                    VStack(alignment: .leading, spacing: 5) {
                        Text(comic.title)
                            .font(.system(size: 15, weight: .bold))
                        
                        Text("By \(comic.author)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // Comic Info (Rating, Chapters, Language)
                    HStack(spacing: 30) {
                        InfoView(label: "\(String(format: "%.1f", comic.rating))", description: "Rating")
                        InfoView(label: "\(comic.totalChapters)", description: "Chapters")
                        InfoView(label: "\(comic.language)", description: "Language")
                        
                        LikeView(actionLike: {
                            Task {
                                //    await viewModel.followComic(comic: comic)
                            }
                        })
                        .frame(height: 50)
                        .clipped()
                    }
                    .padding(.horizontal)
                    
                    // Comic Description
                    Text(comic.description)
                        .font(.system(size: 13, weight: .medium))
                        .lineSpacing(10)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .frame(maxHeight:imageDescriptionHeight)
                    
                }
                .padding(.vertical)
            }
            .padding(.bottom, 50)
            
            VStack {
                Spacer()
                HStack {
                    Button(action: {
                        // Read now action
                        if let chapter = viewModel.chapters.first {
                            chapterSelected = chapter
                            isShowChapterView.toggle()
                        }
                    }) {
                        Text("First Chapter")
                            .font(.system(size: 15, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    if comic.totalReviews > 0 {
                        Button(action: {
                            // Read now action
                        }) {
                            Text("Last Chapter")
                                .font(.system(size: 15, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .trailing,
                                        endPoint: .leading
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                    }
                }
            }
        }.onAppear() {
            Task {
                if let comicId = comic.id {
                    await viewModel.fetchChapters(comicId: comicId)
                    
                    await viewModel.updateViewCount(comicId: comicId)
                    
                }
            }
        }
        .navigationTitle("Comic Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    print("More options tapped")
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationDestination(isPresented: $isShowChapterView) {
            ComicBookView(chapter: $chapterSelected)
                .navigationBarBackButtonHidden()
        }
    }
}

// Helper View for Info
struct InfoView: View {
    var label: String
    var description: String
    
    var body: some View {
        VStack {
            Text(label)
                .font(.system(size: 13, weight: .bold))
            Text(description)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.gray)
        }
    }
}

// Preview with sample data
struct ComicReviewView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleComic = ComicModel(
            title: "Kaguya-sama: Love is war. Kaguya-sama: Love is war",
            description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse molestie est nec gravida dictum.Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse molestie est nec gravida dictum.Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse molestie est nec gravida dictum.Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse molestie est nec gravida dictum.Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse molestie est nec gravida dictum.Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse molestie est nec gravida dictum.Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse molestie est nec gravida dictum.",
            genre: ["Romance", "Comedy"],
            author: "Aka Akasaka",
            coverImageUrl: "https://firebasestorage.googleapis.com:443/v0/b/dotadressup.appspot.com/o/comic_covers%2FF1D9B853-CF25-48BC-9A54-2D9BB16CAE36.jpg?alt=media&token=f840e033-b30b-4f25-a819-652bfc923f62",
            language: "English",
            totalChapters: 265,
            rating: 4.5,
            totalReviews: 1200,
            viewCount: 1200000
        )
        
        ComicReviewView(comic: sampleComic)
    }
}
