//
//  CardView.swift
//  WallDota2
//
//  Created by QuangHo on 12/9/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct CardView: View {
    @StateObject private var viewModel = CardViewModel()
    let item: StoryModel
    var isIpad: Bool { UIDevice.current.userInterfaceIdiom == .pad }
    
    let imageHeight = UIScreen.main.bounds.height * 0.35
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if viewModel.url == nil {
                ProgressView()
            } else {
                WebImage(url: viewModel.url)
                    .onSuccess { image, data, cacheType in
                        // Success
                    }
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width - 60, height: imageHeight) // Adjust the height here
                    .cornerRadius(20)
                    .clipped()
            }
            
            VStack(alignment: .leading, spacing: 150) {
                VStack(alignment: .leading) {
                    Text(item.heroid.uppercased())
                        .font(.caption)
                        .fontWidth(.condensed)
                        .padding([], 20)
                        .frame(width:60, height: 35)
                        .background(Color.white.opacity(0.7))
                        .cornerRadius(5)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                VStack (alignment: .leading){
                    Text(item.content.titleDescription ?? "")
                        .font(.system(size: 13, weight: .regular))
                        .padding(20)
                        .fontWidth(.condensed)
                        .foregroundColor(.white)
                    
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.gray.opacity(0.8), .gray.opacity(0.3)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                
            }
            .frame(width: UIScreen.main.bounds.width - 60, height: imageHeight)
            .overlay(
                Rectangle()
                    .fill(Color.black.opacity(0.1))
                    .shadow(radius: 20),
                alignment: .topLeading
            )
        }
        .cornerRadius(15)
        .shadow(radius: 5)
        .onAppear {
            if let url = URL(string: item.thumbnail) {
                // Validate URL with URLComponents
                if var components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   components.scheme != nil, components.host != nil {
                    // If valid, assign the URL
                    viewModel.url = url
                } else {
                    // If invalid URL, fetch the thumbnail
                    viewModel.fetchThumbnail(for: item)
                }
            } else {
                viewModel.fetchThumbnail(for: item)
            }
        }
    }
}

class CardViewModel: ObservableObject {
    @Published var url: URL?

    func fetchThumbnail(for item: StoryModel) {
        Task {
            let url_ = await item.getURLThumbnail()
            print(url?.absoluteString as Any)
            await MainActor.run {
                item.thumbnail = url_?.absoluteString ?? ""
                self.url = url_
            }
        }
    }
}
struct WrapperCardView: View {
    @State var model = StoryModel()
    var body: some View {
        CardView(item: model)
    }
}
#Preview {
    WrapperCardView()
}
