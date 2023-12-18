//
//  ShowDetailImageView.swift
//  WallDota2
//
//  Created by QuangHo on 15/12/2023.
//

import SwiftUI

struct ShowDetailImageView: View {
    let dismissModal: () -> Void
    @Binding var model: ImageModel
    @State var imageURL: String = ""
    let gradient: LinearGradient = LinearGradient(
        colors: [Color.black.opacity(0.2), Color.clear],
        startPoint: .top, endPoint: .bottom
    )
    var body: some View {
        ZStack {
            VStack {
                if imageURL.isEmpty {
                    ProgressView()
                } else {
                    AsyncImage(url: URL(string: imageURL) ) { image in
                        image.image?
                            .resizable()
                            .scaledToFit()
                            .ignoresSafeArea()
                    }
                    .frame(width: UIScreen.main.bounds.width)
                    .edgesIgnoringSafeArea(.all)
                }
            }
            .onAppear(perform: {
                Task
                {
                    let firebaseData = FireStoreDatabase()
                    if let url = await firebaseData.getURL(path: model.imageUrl) {
                        imageURL = url.absoluteString
                    }
                }
            })
            gradient.edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismissModal()
                    }, label: {
                        Image(systemName: "x.circle")
                            .foregroundColor(.white.opacity(0.8))
                            .font(.title)
                    })
                    .padding()
                    
                }
                Spacer()
            }
        }.background(.black.opacity(0.5))
        
    }
}
struct WrapperShowDetailImageView: View {
    @State var url: String = "https://firebasestorage.googleapis.com/v0/b/dotadressup.appspot.com/o/images%2FTemplar%20Assassin%2FTemplar%20Assassin11291?alt=media&token=2221a6b5-5876-458c-8cae-ca923a7465eb"
    @State var model: ImageModel = ImageModel()
    var body: some View {
        ShowDetailImageView(dismissModal: {
            
        }, model: $model)
    }
}

#Preview {
    WrapperShowDetailImageView()
}
