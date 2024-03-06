//
//  FirstSectionHomeView.swift
//  WallDota2
//
//  Created by QuangHo on 14/12/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct FirstSectionHomeView: View {
    @State var items:[ImageModel]
    @State var itemsHasThumbnail:[ImageModel] = []
    @State var isGetDoneAPI: Bool = false
    @State var thumbnail: URL?
    var actionShowDetailSpotlight:((ImageModel) -> Void)
    var actionShowMoreSpotlight:(([ImageModel]) -> Void)
    var maximumNumberLoadURL = 4
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Spotlight")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                Spacer()
            }
            .padding()
            VStack {
                if isGetDoneAPI {
                    
                    AnimatedImage(url: URL(string: items.first?.thumbnailFull ?? ""))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 280)
                        .cornerRadius(10)
                        .clipped()
                        .onTapGesture {
                            withAnimation {
                                if let first = items.first {
                                    self.actionShowDetailSpotlight(first)
                                }
                                
                            }
                        }
                    
                } else {
                    ProgressView().frame(height: 280)
                }
                
            }
            .frame(height: 210)
            .padding()
            
            LazyHStack(spacing: 18, content: {
                ForEach(1...3, id: \.self) { count in
                    if count < 3 && items.count > 3 {
                        VStack {
                            if isGetDoneAPI {
                                AsyncImage(url: URL(string: items[count].thumbnailFull
                                                   )) { image in
                                    image.image?
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 102, height: 92)
                                        .cornerRadius(10)
                                }.clipped()
                            } else {
                                ProgressView()
                                    .frame(width: 102, height: 92)
                            }
                        }
                        .onTapGesture {
                            self.actionShowDetailSpotlight(items[count])
                        }
                        
                    } else {
                        VStack {
                            Text("+4")
                                .foregroundStyle(.white)
                                .font(.title)
                                .fontWeight(.bold)
                                .frame(width: 102, height: 92)
                                .background(.red.opacity(0.3))
                                .cornerRadius(10)
                        }
                        .onTapGesture {
                            self.actionShowMoreSpotlight(items)
                        }
                    }
                    
                }
            })
            .frame(height: 92)
            .padding()
        }
        .onAppear(perform: {
            Task
            {
                if isGetDoneAPI {return}
                let date = Date().timeIntervalSince1970
                let firebaseData = FireStoreDatabase.shared
                var i = 0
                for item in items {
                    if i > 2 {
                        isGetDoneAPI = true
                    }
                    if URL(string:item.thumbnailFull) == nil,
                       let thumbnail = await firebaseData.getURL(path: item.thumbnail) {
                        item.thumbnailFull = thumbnail.absoluteString
                    }
                    i += 1
                    print(item.thumbnail + " thumbnail")
                }
                print("total time spotlight :\(Date().timeIntervalSince1970 - date)")
                
            }
        })
    }
    
}

struct WrappedFirstSectionHomeView: View {
    @State var items = [ImageModel(), ImageModel(),ImageModel(), ImageModel()]
    var body: some View {
        FirstSectionHomeView(items: items, actionShowDetailSpotlight: { model in
        }, actionShowMoreSpotlight: { list in
            
        })
    }
}

#Preview {
    WrappedFirstSectionHomeView()
}
