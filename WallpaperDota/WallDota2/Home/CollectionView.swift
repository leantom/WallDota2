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
    
    let columns = [GridItem(.flexible(minimum: 120, maximum: 180)), GridItem(.flexible(minimum: 120, maximum: 180)), GridItem(.flexible(minimum: 120, maximum: 180))]
    
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
