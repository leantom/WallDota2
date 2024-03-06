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
    @Binding var itemsSpotlight: [ImageModel]
    var actionTapDetail: ((ImageModel) -> Void)
    @State var itemSelected: ImageModel?
    
    var actionDownload: ((Double) -> Void) // dang down
    var actionDownloadFinished: (() -> Void) // down xong
    
    var actionShowDetailSpotlight: ((ImageModel) -> Void)
    var actionShowMoreSpotlight: (([ImageModel]) -> Void)
    
    let columns = [GridItem(.flexible(minimum: 50, maximum: 180)),
                   GridItem(.flexible(minimum: 50, maximum: 180)),
                   GridItem(.flexible(minimum: 50, maximum: 180))]
    @State var gradient: LinearGradient = LinearGradient(
        colors: [Color.white.opacity(0.9), Color.clear],
        startPoint: .top, endPoint: .bottom
    )
    @State var isShowPopupComment = false
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                LazyVStack {
                    if itemsSpotlight.count == 0 {
                        ProgressView()
                    } else {
                        FirstSectionHomeView(items: itemsSpotlight, actionShowDetailSpotlight: { model in
                            self.actionShowDetailSpotlight(model)
                        }, actionShowMoreSpotlight: { list in
                            self.actionShowMoreSpotlight(list)
                        })
                    }
                }
                
                LazyVStack {
                    HStack {
                        Text("Trending")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                        Spacer()
                    }
                    LazyVGrid(columns: columns, spacing: 5, content: {
                        ForEach(items) { show in
                            ShowItemView(show: show, actionDownload: {
                                
                                self.actionDownloadFinished()
                            }, actionDownloadProgressBar: { progress in
                                self.actionDownload(progress)
                                
                            }, actionComment: { model in
                                withAnimation {
                                    itemSelected = model
                                    isShowPopupComment.toggle()
                                }
                            }).onTapGesture {
                                self.actionTapDetail(show)
                            }
                        }
                    })
                }
            }
            .frame(width: UIScreen.main.bounds.width * 0.98)
            .disabled(isMenuOpen)
        }
        
    }
}

