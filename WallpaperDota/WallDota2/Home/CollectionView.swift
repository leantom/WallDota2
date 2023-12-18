//
//  CollectionView.swift
//  WallDota2
//
//  Created by QuangHo on 18/12/2023.
//

import SwiftUI

struct CollectionView: View {
    @State private var toastIsVisible = false
    @State private var isLoading = false
    @State var progressBarValue: Double = 0
    
   @Binding var heroesID:[String]
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
                    ForEach(heroesID, id: \.self) {item in
                        HStack {
                            Text(item)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding()
                            Spacer()
                        }.frame(height: 100)
                            .background(randomColor())
                            .cornerRadius(10)
                            .onTapGesture {
                                self.action(item)
                            }
                    }
                }
            }
        }
        
    }
}

struct WrapperCollectionView:View {
    @State var heroids = ["Crystal maiden",
    "Lina", "Templar Assassin"]
    
    var body: some View {
        CollectionView(heroesID: $heroids, action: { heroID in
            
        })
    }
}

#Preview {
    WrapperCollectionView()
}
