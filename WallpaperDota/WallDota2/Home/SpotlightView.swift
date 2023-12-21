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
    let columns = [GridItem(.flexible(minimum: 50, maximum: UIScreen.main.bounds.width * 0.85))]
    
    var body: some View {
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
                }

            }
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    // Loop through the items and create ItemCell views
                    ForEach(listImage, id: \.id) {item in
                        
                        WebImage(url: URL(string: item.thumbnailFull))
                            .resizable()
                            .placeholder(content: {
                                ProgressView()
                            })
                            .aspectRatio(contentMode: .fit)
                            .frame(width: UIScreen.main.bounds.width - 40)
                            .cornerRadius(10)
                    }
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
