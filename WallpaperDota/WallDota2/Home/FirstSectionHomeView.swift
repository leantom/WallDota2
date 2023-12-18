//
//  FirstSectionHomeView.swift
//  WallDota2
//
//  Created by QuangHo on 14/12/2023.
//

import SwiftUI

struct FirstSectionHomeView: View {
    @State var items:[ImageModel]
    @State var itemsHasThumbnail:[ImageModel] = []
    @State var isGetDoneAPI: Bool = false
    @State var thumbnail: URL?
    
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
                    AsyncImage(url: URL(string: items.first?.thumbnailFull ?? "")) { image in
                        image.image?
                            .resizable()
                            .scaledToFit()
                            .frame(height: 280)
                    }.cornerRadius(10)
                    .clipped()
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
                                        .frame(width: 102, height: 92)
                                        .cornerRadius(10)
                                    
                                    
                                }.clipped()
                            } else {
                                ProgressView()
                                    .frame(width: 102, height: 92)
                            }
                        }
                        
                        
                    } else {
                        Text("+4")
                            .foregroundStyle(.white)
                            .font(.title)
                            .fontWeight(.bold)
                            .frame(width: 102, height: 92)
                            .background(.red.opacity(0.3))
                            .cornerRadius(10)
                    }
                    
                }
            })
            .frame(height: 92)
            .padding()
        }
        .onAppear(perform: {
            Task
            {
                let firebaseData = FireStoreDatabase()
                var i = 0
                for  item in items {
                    Task {
                        if let thumbnail = await firebaseData.getURL(path: item.thumbnail) {
                            item.thumbnailFull = thumbnail.absoluteString
                            
                            i += 1
                        }
                        print(item.thumbnail + " thumbnail")
                        if i == items.count {
                            isGetDoneAPI = true
                            print("isGetDoneAPI = true")
                        }
                    }
                }
                
            }
           
        })
    }
   
}

struct WrappedFirstSectionHomeView: View {
    @State var items = [ImageModel(), ImageModel(),ImageModel(), ImageModel()]
    var body: some View {
        FirstSectionHomeView(items: items)
    }
}

#Preview {
    WrappedFirstSectionHomeView()
}
