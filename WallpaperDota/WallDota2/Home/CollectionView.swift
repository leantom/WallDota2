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
    let gradient: LinearGradient = LinearGradient(
        colors: [Color.black.opacity(0.5), Color.clear],
        startPoint: .trailing, endPoint: .leading
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
                    ForEach(_firestoreDB.listCollectionImages, id: \.heroID) {item in
                        HStack {
                            ZStack {
                                
                                gradient.onTapGesture {
                                    self.action(item.heroID)
                                }
                                HStack {
                                    Text(item.heroID)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .padding()
                                    Spacer()
                                }
                            }
                            
                        }.frame(height: 100)
                            .background(randomColor())
                            .cornerRadius(10)
                            
                    }
                }
            }
        }
        
    }
}

struct WrapperCollectionView:View {
    @State var heroids = ["Crystal maiden",
    "Lina", "Templar Assassin"]
    @State var firestoreDB = FireStoreDatabase()
    
    var body: some View {
        CollectionView(heroesID: $heroids, _firestoreDB: $firestoreDB, action: { heroID in
            
        })
    }
}

#Preview {
    WrapperCollectionView()
}
