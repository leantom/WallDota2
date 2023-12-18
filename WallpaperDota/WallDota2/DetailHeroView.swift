//
//  DetailHeroView.swift
//  WallDota2
//
//  Created by QuangHo on 18/12/2023.
//

import SwiftUI

struct DetailHeroView: View {
    
    @Binding var items: [ImageModel]
    let columns = [GridItem(.flexible(minimum: 50, maximum: 160)), GridItem(.flexible(minimum: 50, maximum: 160))]
    @State var heroName: String = ""
    var actionBack:(()-> Void)
    @State var isShowDetail: Bool = false
    @State var modelSelected: ImageModel = ImageModel()
    
    var body: some View {
        
        NavigationStack {
            VStack {
                HStack {
                    Button {
                        self.actionBack()
                    } label: {
                        Image(systemName: "arrow.backward")
                            .foregroundColor(.black)
                            .font(.title2)
                            .padding()
                    }
                    Spacer()
                }
                

                ScrollView(.vertical) {
                    
                    LazyVStack {
                        HStack {
                            Text(heroName)
                                .font(.title)
                                .fontWeight(.bold)
                                .padding()
                            Spacer()
                            
                        }
                        LazyVGrid(columns: columns, content: {
                            ForEach(items) { show in
                                ShowItemView(show: show, actionDownload: {
                                    
                                  
                                }, actionDownloadProgressBar: { progress in
                                   
                                    
                                }).onTapGesture {
                                    modelSelected = show
                                    isShowDetail.toggle()
                                    
                                }
                            }
                        })
                    }
                }.onAppear(perform: {
                    self.heroName = items.first?.heroID ?? ""
                })
            }
        }
        .navigationDestination(isPresented:$isShowDetail) {
            ShowDetailImageView(dismissModal: {
                isShowDetail = false
            }, model: $modelSelected)
            .navigationBarBackButtonHidden()
            
        }
        
    }
}
struct WrapperDetailHeroView: View {
    @State var items: [ImageModel] = [ImageModel(), ImageModel()]
    var body: some View {
        DetailHeroView(items: $items, actionBack: {})
    }
}
#Preview {
    WrapperDetailHeroView()
}
