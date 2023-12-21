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
    @State private var isLoading = false
    @State var progressBarValue: Double = 0
    
    @Binding var heroesID:[String]
    @Binding var _firestoreDB:FireStoreDatabase
    @State var listCollectionModel:[ImageModel] = []
    
    let gradient: LinearGradient = LinearGradient(
        colors: [randomColor().opacity(0.4), randomColor().opacity(0.1)],
        startPoint: .bottom, endPoint: .top
    )
    
    let columns = [GridItem(.flexible(minimum: 50, maximum: 160)), GridItem(.flexible(minimum: 50, maximum: 160)), GridItem(.flexible(minimum: 50, maximum: 160))]
    
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
                LazyVGrid(columns: columns, spacing: 16) {
                  // Loop through the items and create ItemCell views
                    ForEach(listCollectionModel, id: \.heroID) {item in
                        HStack {
                            ZStack {
                                VStack {
                                    WebImage(url: URL(string: item.thumbnailFull))
                                        .resizable()
                                        .placeholder {
                                            ProgressView()
                                        }
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(10)
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
                            .onTapGesture {
                                print(item.heroID)
                                self.action(item.heroID)
                            }
                    }
                }
                .padding()
            }
            
            .onAppear(perform: {
                self.listCollectionModel = _firestoreDB.listCollectionImages
            })
            .refreshable {
                await _firestoreDB.fetchDataCollectionFromFirestore()
                self.listCollectionModel = _firestoreDB.listCollectionImages
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
