//
//  CollectionView.swift
//  WallDota2
//
//  Created by QuangHo on 18/12/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct CollectionHeroView: View {
    @State private var toastIsVisible = false
    @State private var isLoading = true
    @State var progressBarValue: Double = 0
    
    @Binding var heroesID:[String]
    @Binding var _firestoreDB:FireStoreDatabase
    @State var listCollectionModel:[ImageModel] = []
    
    let gradient: LinearGradient = LinearGradient(
        colors: [randomColor().opacity(0.4), randomColor().opacity(0.1)],
        startPoint: .bottom, endPoint: .top
    )
    
    let columns = [GridItem(.fixed(120)), GridItem(.fixed(120)), GridItem(.flexible(minimum: 50, maximum: 160))]
    
    var action:((String) -> Void)
    var body: some View {
        VStack {
            
            HStack {
                Text("Collections")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                    .padding()
                Spacer()
            }
            ScrollView {
                if isLoading {
                    ProgressView().padding()
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                      // Loop through the items and create ItemCell views
                        ForEach(listCollectionModel, id: \.heroID) {item in
                            CollectionCellHeroView(item: item)
                                .onTapGesture {
                                    print(item.heroID)
                                    self.action(item.heroID)
                                }
                        }
                    }
                    .padding()
                }
               
            }
            
            .onAppear(perform: {
                Task {
                    if $_firestoreDB.listCollectionImages.count == 0 {
                        await FireStoreDatabase.shared.fetchDataCollectionFromFirestore()
                        isLoading = false
                    }
                    self.listCollectionModel = _firestoreDB.listCollectionImages
                    isLoading = false
                }
                
            })
            .refreshable {
                await _firestoreDB.fetchDataCollectionFromFirestore()
                self.listCollectionModel = _firestoreDB.listCollectionImages
                isLoading = false
            }
        }
    }
    
    
    
}

struct CollectionCellHeroView: View {
    @StateObject var item: ImageModel
    let gradient: LinearGradient = LinearGradient(
        colors: [Color.black.opacity(0.5), Color.black.opacity(0.2)],
        startPoint: .leading, endPoint: .trailing
    )
    @State var isLoadedImage = false
    var body: some View {
        HStack {
            ZStack {
                VStack {
                    if item.isLoadedThumbnail {
                        WebImage(url: URL(string: item.thumbnailFull))
                            .resizable()
                            .placeholder {
                                ProgressView()
                            }
                            .frame(minHeight: 60)
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(10)
                    } else {
                        ProgressView()
                    }
                    
                    Text(item.heroID)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                }.background(randomColor().opacity(0.8))
            }
            .clipped()
            
        }
            .cornerRadius(10)
            .clipped()
            .onAppear {
                Task {
                    
                    let url = await FireStoreDatabase.shared.getURL(path: item.thumbnail)
                    item.isLoadedThumbnail = true
                    item.thumbnailFull = url?.absoluteString ?? ""
                    
                }
            }
        
    }
}

struct WrapperCollectionHeroView:View {
    @State var heroids = ["Crystal maiden",
    "Lina", "Templar Assassin"]
    @State var firestoreDB = FireStoreDatabase()
    
    var body: some View {
        CollectionView(heroesID: $heroids, _firestoreDB: $firestoreDB, action: { heroID in
            
        })
    }
}

#Preview {
    WrapperCollectionHeroView()
}
