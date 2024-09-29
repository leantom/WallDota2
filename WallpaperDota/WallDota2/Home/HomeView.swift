//
//  HomeView.swift
//  WallDota2
//
//  Created by QuangHo on 13/12/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Photos

struct HomeView: View {
    
    @Binding var isMenuOpen: Bool
    @Binding var items: [ImageModel]
    @Binding var itemsSpotlight: [StoryModel]
    var actionTapDetail: ((ImageModel) -> Void)
    @State var itemSelected: ImageModel?
    
    var actionDownload: ((Double) -> Void) // dang down
    var actionDownloadFinished: (() -> Void) // down xong
    
    var actionShowDetailSpotlight: ((StoryModel, [StoryModel]) -> Void)
    var actionShowMoreSpotlight: (([ImageModel]) -> Void)
    
    let columns = [GridItem(.flexible(minimum: 50, maximum: 180)),
                   GridItem(.flexible(minimum: 50, maximum: 180)),
                   GridItem(.flexible(minimum: 50, maximum: 180))]
    @State var gradient: LinearGradient = LinearGradient(
        colors: [Color.white.opacity(0.9), Color.clear],
        startPoint: .top, endPoint: .bottom
    )
    @State var isShowPopupComment = false
    @State var trendingManga:[ComicModel] = []
    @State private var path: [ComicModel] = []
    var actionChooseShowComic: (ComicModel) -> Void
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                LazyVStack {
                    if itemsSpotlight.count == 0 {
                        ProgressView()
                    } else {
                        
                        SpotlightViewV2(actionShowDetailSpotlight: { item,  items in
                            self.actionShowDetailSpotlight(item, items)
                        }, actionShowMoreSpotlight: { items in
                            self.actionShowMoreSpotlight(items)
                        })
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Trending comic")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TrendingMangaView(trendingManga: trendingManga, actionChoose: {comic in
                        actionChooseShowComic(comic)
                    })
                }
                .padding(.top)
                
                LazyVStack {
                    HStack {
                        Text("Trending themes")
                            .font(.headline)
                            .padding(.horizontal)
                        Spacer()
                    }
                    LazyVGrid(columns: columns, spacing: 5) {
                            ForEach(items.indices, id: \.self) { index in
                                ShowItemView(show: items[index], actionDownload: {
                                    self.actionDownloadFinished()
                                }, actionDownloadProgressBar: { progress in
                                    self.actionDownload(progress)
                                }, actionComment: { model in
                                    withAnimation {
                                        itemSelected = model
                                        isShowPopupComment.toggle()
                                    }
                                }).onTapGesture {
                                    self.actionTapDetail(items[index])
                                }
                            }
                        }
                }
            }
            .frame(width: UIScreen.main.bounds.width * 0.98)
            .disabled(isMenuOpen)
        }
        .onAppear {
            Task {
                trendingManga = await ComicViewModel().fetchMostViewComics()
                
            }
        }
        
    }
}

