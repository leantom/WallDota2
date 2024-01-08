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
    @StateObject var show: ImageModel
    @State var likeCount = 0
    var opacityImage = 0.7
    @State var isLike: Bool = false
    @State var showComment: Bool = false
    @State var thumbnail: URL?
    @State private var image: UIImage?
    var actionDownload: (() -> Void)
    var actionDownloadProgressBar: ((Double) -> Void)
    var actionComment: ((ImageModel) -> Void)
    
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
                    VStack(spacing: 10) {
                        VStack {
                            Button(action: {
                                Task {
                                    await saveImage()
                                }
                                
                            }, label: {
                                Image(systemName: "arrow.down.square")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                
                            }).opacity(opacityImage)
                                
                        }
                        // MARK: --
                        VStack (spacing: 5) {
                            VStack(spacing: 3){
                                Button(action: {
                                    Task {
                                        await FireStoreDatabase.likeImage(image: show)
                                        show.likeCount += 1
                                        self.likeCount += 1
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
                                
                                Text("\(self.likeCount)").font(.caption).foregroundStyle(.white)
                                
                            }
                            // MARK: Comment View
                            VStack(spacing: 3){
                                Button(action: {
                                    Task {
                                        
                                    }
                                    showComment.toggle()
                                    actionComment(show)
                                }, label: {
                                    Image("icons8-comment-50")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 24, height: 24)
                                        .clipped()
                                }).opacity(opacityImage)
                                    .fullScreenCover(isPresented: $showComment) {
                                        withAnimation {
                                            CommentsView(imageModel: show)
                                        }
                                    }
                                
                                Text("\(self.show.commentCount)").font(.caption).foregroundStyle(.white)
                                
                            }
                        }
                        
                       
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(width: 45, height: 150)
                    .background(.black.opacity(0.3))
                    .cornerRadius(10)
                    .padding()
                    
                    Spacer()
                }
            }
            
        }
        .clipped()
        .cornerRadius(10)
        .onAppear(perform: {
            Task {
                self.likeCount = show.likeCount
                let firebaseData = FireStoreDatabase.shared
                if let thumbnail = await firebaseData.getURL(path: show.thumbnail) {
                    self.show.thumbnailFull = thumbnail.absoluteString
                    self.thumbnail = thumbnail
                }
            }
        })
    }
    
    func saveImage() async {
       let isValidDownLoad = await FireStoreDatabase.shared.createItemDownload(item: ItemDownload(imageid: show.id, created_at: Date().timeIntervalSince1970, userid: LoginViewModel.shared.userLogin?.userid ?? ""))
        if isValidDownLoad {
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
    
    
    
}
struct WrapperShowItemView: View {
    @State var items = ImageModel()
    var body: some View {
        ShowItemView(show: items, actionDownload: {}, actionDownloadProgressBar: {progress in}, actionComment: {model in }).frame(width: 180, height: 250)
    }
}
#Preview {
    WrapperShowItemView()
}

