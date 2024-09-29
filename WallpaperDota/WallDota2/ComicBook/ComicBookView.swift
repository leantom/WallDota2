import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct ComicBookView: View {
    @StateObject private var viewModel = ComicViewModel()
    @State private var currentIndex = 0
    @State private var isShowUIElements: Bool = true
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var chapter: ChapterModel?
    @State private var isShowAds: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            // Calculate button size based on screen dimensions
            let buttonSize = min(geometry.size.width, geometry.size.height) * 0.07
            
            VStack {
                if isShowUIElements {
                    HStack {
                        // Back Button
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Chapter Title
                        Text("Chapter \(chapter?.chapterNumber ?? 0)")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
//                        // More Options Button
//                        Button(action: {
//                            print("More options tapped")
//                        }) {
//                            Image(systemName: "ellipsis")
//                                .font(.system(size: 20, weight: .bold))
//                                .foregroundColor(.gray)
//                        }
                    }
                    .padding()
                }
                if UIDevice.current.userInterfaceIdiom != .pad {
                    Text("*Read the story on an iPad for the best experience.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                }
                
                
                
                Spacer()
                
                if let chapter = self.chapter {
                    if chapter.typeChapter == "cbr" {
                        // Existing behavior for "cbr" chapters
                        ZStack {
                            WebImage(url: URL(string: chapter.pages[currentIndex]))
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width)
                                .id(currentIndex)
                                .transition(.opacity)
                                .onTapGesture {
                                    withAnimation {
                                        isShowUIElements.toggle()
                                    }
                                }
                            
                            if isShowUIElements {
                                HStack {
                                    // Left Navigation Button
                                    Button(action: {
                                        if currentIndex > 0 {
                                            withAnimation {
                                                currentIndex -= 1
                                            }
                                        }
                                    }) {
                                        Image(systemName: "arrow.left")
                                            .font(.system(size: buttonSize * 0.4, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(width: buttonSize, height: buttonSize)
                                            .background(Color.gray.opacity(0.3))
                                            .clipShape(Circle())
                                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                                    }
                                    .disabled(currentIndex == 0)
                                    
                                    Spacer()
                                    
                                    // Right Navigation Button
                                    Button(action: {
                                        if currentIndex < chapter.pages.count - 1 {
                                            withAnimation {
                                                currentIndex += 1
                                            }
                                        }
                                    }) {
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: buttonSize * 0.4, weight: .bold))
                                            .foregroundColor(.white)
                                            .frame(width: buttonSize, height: buttonSize)
                                            .background(Color.gray.opacity(0.3))
                                            .clipShape(Circle())
                                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                                    }
                                    .disabled(currentIndex >= chapter.pages.count - 1)
                                }
                                .padding()
                            }
                        }
                        .animation(.easeInOut(duration: 0.5), value: currentIndex)
                    } else if chapter.typeChapter == "normal" {
                        // New behavior for "normal" chapters
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(chapter.pages.indices, id: \.self) { index in
                                    WebImage(url: URL(string: chapter.pages[index]))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width)
                                }
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                isShowUIElements.toggle()
                            }
                        }
                    } else {
                        Text("Unknown chapter type")
                    }
                } else {
                    Text("Loading...")
                }
                
                Spacer()
                
                if isShowAds {
                    BannerView(adSizeGlobal)
                        .frame(height: 50)
                }
            }
        }
        .onChange(of: currentIndex) { newIndex in
            // Prefetch images for "cbr" chapters
            if let chapter = self.chapter, chapter.typeChapter == "cbr" {
                let prefetchCount = 3
                let startIndex = newIndex + 1
                let endIndex = min(newIndex + prefetchCount, chapter.pages.count - 1)
                
                if startIndex <= endIndex {
                    let urlsToPrefetch = chapter.pages[startIndex...endIndex].compactMap { URL(string: $0) }
                    SDWebImagePrefetcher.shared.prefetchURLs(urlsToPrefetch)
                }
            }
        }
        .onAppear {
            Task {
                if let chapter = self.chapter {
                    if chapter.typeChapter == "cbr" {
                        // Prefetch first few images for "cbr" chapters
                        let prefetchCount = 3
                        let endIndex = min(prefetchCount - 1, chapter.pages.count - 1)
                        let urlsToPrefetch = chapter.pages[0...endIndex].compactMap { URL(string: $0) }
                        SDWebImagePrefetcher.shared.prefetchURLs(urlsToPrefetch)
                    } else if chapter.typeChapter == "normal" {
                        // Prefetch all images for "normal" chapters
                        let urlsToPrefetch = chapter.pages.compactMap { URL(string: $0) }
                        SDWebImagePrefetcher.shared.prefetchURLs(urlsToPrefetch)
                    }
                }
                
                if isShowAds == false {
                    GoogleMobileAdsConsentManager.shared.gatherConsent { consentError in
                        if let consentError {
                            print("Error: \(consentError.localizedDescription)")
                            self.isShowAds = false
                        }
                        GoogleMobileAdsConsentManager.shared.startGoogleMobileAdsSDK()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.isShowAds = true
                        }
                    }
                    GoogleMobileAdsConsentManager.shared.startGoogleMobileAdsSDK()
                }
            }
        }
    }
}

struct WrapperBookView:View {
    @State var chapter: ChapterModel? = ChapterModel(id: "123", chapterNumber: 1, title: "Comic book", pages: ["https://firebasestorage.googleapis.com:443/v0/b/dotadressup.appspot.com/o/comics%2FTHE%20KING%20HOLDS%20COURT%20INA%20NEW%20JOURNEY%2Fchapters%2F1%2F3EE04B55-1A6E-4BA2-BFCA-4029AF4200D7.jpg?alt=media&token=d6b2b59b-9bb7-41c9-be82-0e4871c7db2d"], releaseDate: Timestamp(date: Date()), typeChapter: "normal")
    var body: some View {
        ComicBookView(chapter: $chapter)
    }
}

#Preview(body: {
    WrapperBookView()
})

