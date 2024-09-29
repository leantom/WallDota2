import SwiftUI

struct ComicRowView: View {
    var comic: ComicModel
    @EnvironmentObject var viewModel: ComicViewModel
    let imageHeight = UIScreen.main.bounds.height * 0.12
    
    
    var body: some View {
        HStack {
            // Comic Cover Image
            AsyncImage(url: URL(string: comic.coverImageUrl)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: imageHeight - 20, height: imageHeight)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 5) {
                // Comic Title
                Text(comic.title)
                    .font(.system(size: 13, weight: .bold))
                
                Text("Chapter \(comic.totalChapters)")
                    .font(.system(size: 11, weight: .bold))
                
                // Total Chapters
                Text("Views: \(comic.viewCount)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(.vertical, 10)
    }
}

struct TrendingMangaView: View {
    var trendingManga: [ComicModel]
    let imageHeight = UIScreen.main.bounds.height * 0.2
    let imageWidth = UIScreen.main.bounds.height * 0.3
    var actionChoose: (ComicModel) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(trendingManga) { manga in
                    VStack {
                        AsyncImage(url: URL(string: manga.coverImageUrl)) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                            
                        }
                        .frame(width: imageHeight * 0.88, height: imageHeight)
                        .cornerRadius(8)
                        
                        Text(manga.title)
                            .font(.system(size: 12, weight: .bold))
                            .lineLimit(2)
                            .frame(width: 100)
                    }
                    .onTapGesture {
                        withAnimation {
                            actionChoose(manga)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ComicListView: View {
    @State var comics: [ComicModel] = []
    @State var selectedTab: Int = 0
    @State var trendingManga: [ComicModel] = []
    
    var actionChooseShowComic: (ComicModel) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Trending Manga Section
                VStack(alignment: .leading) {
                    Text("Trending Comic")
                        .font(.headline)
                        .padding(.horizontal)
                   
                    TrendingMangaView(trendingManga: trendingManga, actionChoose: { comic in
                        actionChooseShowComic(comic)
                    })
                }
                .padding(.top)
                
                // Tabs (All, Popular, New)
                Text("All comic")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 10)

                // Manga List
                VStack {
                    ForEach(comics) { comic in
                        NavigationLink(destination: ComicReviewView(comic: comic).navigationBarBackButtonHidden()) {
                            ComicRowView(comic: comic)
                        }
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    Task {
                        comics = await ComicViewModel().fetchComics()
                        trendingManga = comics.filter { $0.rating > 4.2 }
                    }
                }
            }
        }
    }
}

// Sample data for preview
let sampleComics = [
    ComicModel(title: "Solo Leveling", description: "", genre: ["Action", "Fantasy"], author: "Chu-Gong", coverImageUrl: "https://example.com/solo.jpg", language: "English", totalChapters: 110, rating: 4.9, totalReviews: 1200, viewCount: 1200000),
    ComicModel(title: "Komi-san wa, Komyushou desu", description: "", genre: ["Romance", "Comedy"], author: "Tomohito Oda", coverImageUrl: "https://example.com/komi.jpg", language: "English", totalChapters: 67, rating: 4.8, totalReviews: 900, viewCount: 956000),
    ComicModel(title: "Kanojo, Okarishimasu", description: "", genre: ["Romance", "Comedy"], author: "Reiji Miyajima", coverImageUrl: "https://example.com/kanojo.jpg", language: "English", totalChapters: 206, rating: 4.5, totalReviews: 600, viewCount: 540000),
    ComicModel(title: "Some Comic", description: "", genre: ["Action", "Adventure"], author: "Author Name", coverImageUrl: "https://example.com/comic.jpg", language: "English", totalChapters: 120, rating: 4.1, totalReviews: 400, viewCount: 12000) // Below 4.3 rating
]

#Preview {
    ComicListView(comics: sampleComics, actionChooseShowComic: {
        _ in
    })
}
    
