//
//  SpotlightView.swift
//  WallDota2
//
//  Created by QuangHo on 20/12/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct SpotlightView: View {
    @Binding var listImage: [ImageModel]
    var actionBack:(() -> Void)
    @State var isLoaded = false
    @State var isDownloaded = false
    @State var isLike = false
    @State var isShowDetailVC = false
    let columns = [GridItem(.flexible(minimum: 50, maximum: UIScreen.main.bounds.width * 0.85))]
    @StateObject var jsonModel = JSONViewModel(images: [])
    @State var modelSelected: ImageModel = ImageModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack {
                    ZStack {
                        
                        HStack {
                            Button(action: {
                                self.actionBack()
                            }, label: {
                                Image(systemName: "arrow.backward")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            })
                            .frame(width: 35, height: 35)
                            .background(Color("kC6C2D8"))
                            .cornerRadius(10)
                            .padding()
                            Spacer()
                        }
                        Text("Spotlight")
                            .font(.title3)
                            .fontWeight(.semibold).padding()
                        ToastView(message: "Image saved to Photos successfully!", isVisible: $isDownloaded)
                    }
                }
                
                ScrollView {
                    if jsonModel.compositionalArray.count > 0 {
                        VStack(spacing: 4) {
                            ForEach(jsonModel.compositionalArray.indices, id: \.self) { index in
                                // Basic logic for mixing layouts
                                if index == 0 || index % 6 == 0 {
                                    Layout1(tapViewDetail: { model in
                                        modelSelected = model
                                        isShowDetailVC.toggle()
                                    },
                                            cards: jsonModel.compositionalArray[index])
                                } else if index % 3 == 0 {
                                    Layout3(cards: jsonModel.compositionalArray[index], tapViewDetail: { model in
                                        modelSelected = model
                                        isShowDetailVC.toggle()
                                    })
                                } else {
                                    Layout2(tapViewDetail: { model in
                                        modelSelected = model
                                        isShowDetailVC.toggle()
                                    },cards: jsonModel.compositionalArray[index])
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }.onAppear {
                jsonModel.setCompositionalLayout(images: listImage)
            }
        }
        .navigationDestination(isPresented: $isShowDetailVC) {
            ShowDetailImageView(dismissModal: {
                isShowDetailVC = false
            }, model: $modelSelected,
                                models: $listImage)
            .navigationBarBackButtonHidden()
        }
    }
}

struct SpotlightItemView:View {
    @Binding var item: ImageModel
    @State var isLike: Bool = false
    @State var likeCount: Int = 0
    
    
    var body: some View {
        ZStack {
            WebImage(url: URL(string: item.thumbnailFull))
                .resizable()
                .placeholder(content: {
                    ProgressView()
                })
                .aspectRatio(contentMode: .fit)
                .frame(width: UIScreen.main.bounds.width - 40)
                .cornerRadius(10)
            VStack {
                Spacer()
                HStack {
                    
                    VStack(spacing: 10) {
                        Button(action: {
                            Task {
                                FileManagement.shared.saveImage(url: item.imageUrl, completion: { progress in
                                })
                            }
                            
                            
                        }, label: {
                            Image(systemName: "arrow.down.square")
                                .foregroundColor(.white)
                                .font(.title2)
                            
                        }).opacity(0.7)
                            .frame(maxHeight: .infinity)
                        VStack(spacing: 10){
                            Button(action: {
                                Task {
                                    await FireStoreDatabase.likeImage(image: item)
                                    item.likeCount += 1
                                    self.likeCount += 1
                                }
                                if FireStoreDatabase.shared.checkUserLikedExistID(id: item.id) == false {
                                    FireStoreDatabase.shared.listImageLiked.append(item)
                                }
                                self.isLike.toggle()
                            }, label: {
                                Image(systemName:"heart.fill")
                                    .foregroundColor(isLike ? .red : .white)
                                    .font(.title2)
                            }).opacity(0.7)
                                
                            
                            Text("\(item.likeCount)").font(.caption).foregroundStyle(.white)
                                
                        }.frame(maxHeight: .infinity)
                    }
                    .onAppear(perform: {
                        self.likeCount = item.likeCount
                    })
                    .padding()
                    .background(.black.opacity(0.2))
                    .cornerRadius(10)
                    Spacer()
                }
            }
            
        }
    }
    
}


struct WrapperSpotlightView: View {
    @State var listImage =  [ImageModel(), ImageModel(), ImageModel(), ImageModel()]
    var body: some View {
        SpotlightView(listImage: $listImage, actionBack: {
            
        })
    }
}

#Preview(body: {
    WrapperSpotlightView()
})
