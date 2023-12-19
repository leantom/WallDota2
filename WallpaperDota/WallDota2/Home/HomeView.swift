//
//  HomeView.swift
//  WallDota2
//
//  Created by QuangHo on 13/12/2023.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Photos

struct HomeView: View {
    
    @Binding var items: [ImageModel]
    @Binding var itemsSpotlight: [ImageModel]
    var actionTapDetail: ((ImageModel) -> Void)
    var actionDownload: ((Double) -> Void) // dang down
    var actionDownloadFinished: (() -> Void) // down xong
    
    @State var isNavigate: Bool = false
    let columns = [GridItem(.flexible(minimum: 50, maximum: 160)), GridItem(.flexible(minimum: 50, maximum: 160))]
    
    var body: some View {
        VStack {
            
            ScrollView(.vertical) {
                LazyVStack {
                    if itemsSpotlight.count == 0 {
                        ProgressView()
                    } else {
                        FirstSectionHomeView(items: itemsSpotlight)
                    }
                }
                
                LazyVStack {
                    HStack {
                        Text("Trending")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                        Spacer()
                    }
                    LazyVGrid(columns: columns, content: {
                        ForEach(items) { show in
                            ShowItemView(show: show, actionDownload: {
                                
                                self.actionDownloadFinished()
                            }, actionDownloadProgressBar: { progress in
                                self.actionDownload(progress)
                                
                            }).onTapGesture {
                                self.actionTapDetail(show)
                            }
                        }
                    })
                }
            }
        }
        
    }
}
import SDWebImageSwiftUI

struct ShowItemView: View {
    let gradient: LinearGradient = LinearGradient(
        colors: [Color.black.opacity(0.2), Color.clear],
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
                .scaledToFill()
                .frame(width: 160, height: 280, alignment: .center)
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
                            self.isLike.toggle()
                        }, label: {
                            Image(systemName:"heart")
                                .foregroundColor(isLike ? .red : .white)
                                .font(.title2)
                        }).opacity(opacityImage)
                    }
                    .padding()
                    .background(.green.opacity(0.3))
                    .cornerRadius(10)
                    Spacer()
                }
            }
            
        }
        .background(Color.gray.opacity(0.2))
        .frame(width: 160, height: 280)
        .clipped()
        .cornerRadius(10)
        .onAppear(perform: {
            Task {
                let firebaseData = FireStoreDatabase()
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

struct WrapperHomeView: View {
    @State var items: [ImageModel] = []
    @State var itemsSpotlight: [ImageModel] = []
    @State private var toastIsVisible = false
    @State private var isLoading = false
    @State var progressBarValue: Double = 0
    
    var body: some View {
        HomeView(items: $items,
                 itemsSpotlight: $itemsSpotlight,
                 actionTapDetail: {_ in },
                 actionDownload: { progress in
            isLoading = true
            progressBarValue = progress
        }, actionDownloadFinished: {
            isLoading = false
        })
    }
}

#Preview {
    WrapperHomeView()
}
