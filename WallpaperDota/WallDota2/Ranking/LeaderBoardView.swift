//
//  LeaderBoardView.swift
//  WallDota2
//
//  Created by QuangHo on 25/12/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct LeaderBoardView: View {
    
    @State var listImage: [ImageModel] = []
    @State var listImageTop3: [ImageModel] = []
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    // MARK: -- show top 3
                    ForEach(listImageTop3, id: \.id) { item in
                        LeaderBoardItemHeaderView(imageModel: item)
                    }
                }
                Spacer()
                VStack {
                    // MARK: -- show list 7
                    ForEach(listImage, id: \.id) { item in
                        LeaderBoardItemView(imageModel: item)
                    }
                }
            }
            .padding(.top, 30)
            .onAppear(perform: {
                self.listImage = Array(FireStoreDatabase.shared.listPositionRanking[3..<10])
                self.listImageTop3 = Array(FireStoreDatabase.shared.listPositionRanking.prefix(upTo: 3))
            })
        }
        .refreshable {
            Task {
                await FireStoreDatabase.shared.fetchDataFromFirestore()
                self.listImage = Array(FireStoreDatabase.shared.listPositionRanking[3..<10])
                self.listImageTop3 = Array(FireStoreDatabase.shared.listPositionRanking.prefix(upTo: 3))
            }
            
        }
    }
}

struct LeaderBoardItemHeaderView: View {
    @StateObject var imageModel: ImageModel
    @State var isLoading = true
    
    var body: some View {
        VStack(spacing: 20){
            ZStack {
                
                if imageModel.isLoadedThumbnail {
                    WebImage(url: URL(string: imageModel.thumbnailFull))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height:  80 * 1.56)
                        .cornerRadius(10)
                } else {
                    ProgressView()
                }
                
                VStack {
                    HStack {
                        Spacer()
                        Text("\(imageModel.positionRankings)")
                            .frame(width: 30, height: 30)
                            .background(randomColor()).clipShape(Circle())
                            .offset(x: 10,y: -10)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
            }
            
            VStack(spacing: 15) {
                Text("\(imageModel.heroID)").font(.caption)
                    .multilineTextAlignment(.leading)
                    
                Text("\(imageModel.likeCount) likes").font(.caption)
            }
            
        }
        .onAppear(perform: {
            Task {
                let url = await FireStoreDatabase.shared.getURL(path: imageModel.thumbnail)
                imageModel.thumbnailFull = url?.absoluteString ?? ""
                imageModel.isLoadedThumbnail = true
            }
        })
       
        .frame(width: UIScreen.main.bounds.width / 3 - 24, height: 80 * 1.56 + 50)
    }
}


struct LeaderBoardItemView: View {
    @State var imageModel: ImageModel
    @State var isLoading = true
    var body: some View {
        HStack(spacing: 20) {
            if isLoading {
                ProgressView()
            } else {
                WebImage(url: URL(string: imageModel.thumbnailFull))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height:  80 * 1.56)
                    .cornerRadius(10)
                
            }
            
            
            VStack(spacing: 15) {
                Text(imageModel.heroID).font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fontWeight(.bold)
                
                Text("\(imageModel.likeCount) likes").font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                Spacer()
                Text("\(imageModel.positionRankings)").font(.caption)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding()
                    .background(randomColor()).clipShape(Circle())
            }
        }.padding()
            .onAppear(perform: {
                Task {
                    
                    let url = await FireStoreDatabase.shared.getURL(path: imageModel.thumbnail)
                    imageModel.thumbnailFull = url?.absoluteString ?? ""
                    isLoading = false
                }
            })
            
    }
}

struct WrapperLeaderBoardView:View {
    @State var item = ImageModel()
    var body: some View {
        LeaderBoardItemView(imageModel: item)
    }
}
#Preview(body: {
    WrapperLeaderBoardView()
})
