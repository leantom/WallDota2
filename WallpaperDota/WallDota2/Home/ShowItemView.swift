//
//  ShowItemView.swift
//  WallDota2
//
//  Created by QuangHo on 20/12/2023.
//

import Foundation
import SDWebImageSwiftUI
import SwiftUI
import Photos

struct ShowItemView: View {
    let gradient: LinearGradient = LinearGradient(
        colors: [Color.black.opacity(0.8), Color.clear],
        startPoint: .bottom, endPoint: .top
    ) // Your desired gradient
    var show: ImageModel
    var opacityImage = 0.7
    @State var isLike: Bool = false
    @State var thumbnail: URL?
    @State private var image: UIImage?
    var actionDownload: (() -> Void)
    var actionDownloadProgressBar: ((Double) -> Void)
    
    var body: some View {
        ZStack {
            WebImage(url: thumbnail)
                .onSuccess { image, data, cacheType in
                    // Success
                    // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
                }
                .resizable() // Resizable like SwiftUI.Image, you must use this modifier or the view will use the image bitmap size
                .indicator(.activity) // Activity Indicator
                .transition(.fade(duration: 0.5)) // Fade Transition with duration
                .aspectRatio(contentMode: .fit)
                .clipped()
            gradient
            VStack {
                Spacer()
                HStack {
                    
                    VStack(spacing: 20) {
                        Button(action: {
                            saveImage()
                        }, label: {
                            Image(systemName: "arrow.down.square")
                                .foregroundColor(.white)
                                .font(.title2)
                            
                        }).opacity(opacityImage)
                        
                        Button(action: {
                            Task {
                                await FireStoreDatabase.likeImage(image: show)
                            }
                            if FireStoreDatabase.shared.checkUserLikedExistID(id: show.id) == false {
                                FireStoreDatabase.shared.listImageLiked.append(show)
                            }
                            self.isLike.toggle()
                        }, label: {
                            Image(systemName:"heart.fill")
                                .foregroundColor(isLike ? .red : .white)
                                .font(.title2)
                        }).opacity(opacityImage)
                    }
                    .padding()
                    .background(.black.opacity(0.3))
                    .cornerRadius(10)
                    Spacer()
                }
            }
            
        }
        .clipped()
        .cornerRadius(10)
        .onAppear(perform: {
            Task {
                let firebaseData = FireStoreDatabase.shared
                if let thumbnail = await firebaseData.getURL(path: show.thumbnail) {
                    self.show.thumbnailFull = thumbnail.absoluteString
                    self.thumbnail = thumbnail
                }
            }
            
        })
    }
    
    func saveImage() {
        
        FireStoreDatabase().getImageOriginal(path: show.imageUrl) { data, err, progress  in
            if let data = data,
               let image = UIImage(data: data) {
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                    if status == .authorized {
                        PHPhotoLibrary.shared().performChanges {
                            PHAssetCreationRequest.creationRequestForAsset(from: image)
                        } completionHandler: { success, error in
                            if success {
                                print("Image saved to Photos successfully!")
                                self.actionDownload()
                            } else {
                                print("Error saving image to Photos: \(String(describing: error))")
                            }
                        }
                    } else {
                        print("Photos access permission needed!")
                    }
                }
            }
            actionDownloadProgressBar(progress)
            print("Progress value: \(progress)")
        }
    }
    
    
    
}
