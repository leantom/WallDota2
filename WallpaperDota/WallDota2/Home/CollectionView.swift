//
//  CollectionView.swift
//  WallDota2
//
//  Created by QuangHo on 18/12/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct CollectionView: View {
    @State private var toastIsVisible = false
    @State private var isLoading = false
    @State var progressBarValue: Double = 0
    
    @Binding var heroesID:[String]
    @Binding var _firestoreDB:FireStoreDatabase
    @State var listCollectionModel:[ImageModel] = []
    
    let gradient: LinearGradient = LinearGradient(
        colors: [Color.black.opacity(0.5), Color.black.opacity(0.2)],
        startPoint: .leading, endPoint: .trailing
    )
    
    var action:((String) -> Void)
    var body: some View {
        VStack {
            
            HStack {
                Text("Collections")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding()
                Spacer()
            }
            
            List {
                VStack(spacing: 10) {
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
                                }
                                gradient
                                HStack {
                                    Text(item.heroID)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .padding()
                                    Spacer()
                                }
                            }
                            .frame(height: 100)
                            .clipped()
                            
                        }.frame(height: 100)
                            .cornerRadius(10)
                            .clipped()
                            .onTapGesture {
                                print(item.heroID)
                                self.action(item.heroID)
                            }
                            
                    }
                }
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

struct WrapperCollectionView:View {
    @State var heroids = ["Crystal maiden",
    "Lina", "Templar Assassin"]
    @State var firestoreDB = FireStoreDatabase.shared
    
    var body: some View {
        CollectionView(heroesID: $heroids, _firestoreDB: $firestoreDB, action: { heroID in
            
        })
    }
}

#Preview {
    WrapperCollectionView()
}
