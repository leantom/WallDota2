//
//  ShowDetailImageView.swift
//  WallDota2
//
//  Created by QuangHo on 15/12/2023.
//

import SwiftUI
import SDWebImageSwiftUI
import Photos

struct ShowDetailImageView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State var model = ImageModel()
    @State var models = [ImageModel]() // list hinh
    
    @State var imageURL: String = ""
    let gradient: LinearGradient = LinearGradient(
        colors: [Color.blue.opacity(0.2), Color.clear],
        startPoint: .top, endPoint: .bottom
    )
    @State var isShowOnlyImage: Bool = false
    @State var showAlert: Bool = false
    @State var toastIsVisible: Bool = false
    @State var toastIsDownloadSuccess: Bool = false
    @State private var isShowPreviewImage = false
    @State private var ratioImage = 0.0
    
    @State var imageDetail: UIImage?
    @State var currentIndex = 0
    @State var isUserSwiping = false
    @State var currentOffset: CGFloat = 0
    @State  var imageData: Data?
    let columns = [
        GridItem(.fixed(UIScreen.main.bounds.height)),
    ]
    @Binding var path: NavigationPath
    var body: some View {
        
        ZStack {
            WebImage(url: URL(string: imageURL))
                .resizable()
                .placeholder(content: {
                    LoadingView()
                })
                .onSuccess(perform: { image, data, type in
                    ratioImage = image.size.width/image.size.height
                    imageDetail = image
                    imageData = data
                })
                .aspectRatio(contentMode: ratioImage >= 1 ? .fit : .fill)
                .ignoresSafeArea()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .edgesIgnoringSafeArea(.all)
                .transition(.opacity) // Use opacity transition for fade-in effect
                .animation(.easeInOut, value: imageData)
                
                .onAppear {
                    Task
                    {
                        
                        if let model = AppSetting.shared.imageDetail {
                            self.model = model
                        }
                        
                        let firebaseData = FireStoreDatabase.shared
                        if model.imageUrlFull.isEmpty, let url = await firebaseData.getURL(path: model.imageUrl) {
                            model.imageUrlFull = url.absoluteString
                            imageURL = url.absoluteString
                            model.isLoadedImageOriginal.toggle()
                            print(imageURL)
                        } else {
                            imageURL = model.imageUrlFull
                        }
                        
                        await InterstitialViewModel.shared.loadAd()
                    }
                }
            
            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            path.removeLast()
                        }
                        
                    }, label: {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                            .font(.title2)
                    })
                    .frame(width: 40, height: 40)
                    .background(Color("kC6C2D8").opacity(isShowOnlyImage ? 0.4 : 0.8))
                    .cornerRadius(10)
                    Spacer()
                    if isShowOnlyImage == false {
                        HStack {
                            Spacer()
                            HStack {
                                Button(action: {
                                    Task {
                                        await saveImage()
                                    }
                                    
                                }, label: {
                                    Image(systemName: "arrow.down.square")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                    
                                })
                                
                                Button(action: {
                                    // Report this image
                                    showAlert.toggle()
                                }, label: {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.white)
                                        .font(.title2)
                                })
                                .alert(isPresented: $showAlert) {
                                    Alert(
                                        title: Text("Warning"),
                                        message: Text("Do you really want to report this photo?"),
                                        primaryButton: .default(
                                            Text("OK"),
                                            action: {
                                                model.isReport = true
                                                toastIsVisible.toggle()
                                                Task {
                                                    await FireStoreDatabase.reportImage(image: model)
                                                }
                                                
                                            }
                                        ),
                                        secondaryButton: .destructive(
                                            Text("Cancel"),
                                            action: {
                                                
                                            }
                                        )
                                    )
                                }
                                .frame(width: 40, height: 40)
                                .cornerRadius(10)
                            }
                            .padding([.leading, .trailing], 10)
                            .background(.black.opacity(0.3))
                            .cornerRadius(10)
                            
                            
                            
                        }
                        
                    }
                }.padding()
                .frame(width: UIScreen.main.bounds.width)
                .padding(.top, 10)
                
                Spacer()
                
                if isShowOnlyImage == false {
                    HStack {
                        Button(action: {
                            // MARK: Show preview
                            isShowPreviewImage.toggle()
                        }, label: {
                            Text("Preview")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                        }).padding()
                            .frame(width: UIScreen.main.bounds.width - 48, height: 48)
                            .background(Color("kC6C2D8").opacity(0.5))
                            .cornerRadius(10)
                    }
                    .padding()
                    .padding(.bottom, 20)
                }
            }
            .padding()
            VStack {
                ToastView(message: "Thank you for reporting this issue to us, we will handle it immediately!", isVisible: $toastIsVisible)
                    .clipped()
                    .cornerRadius(5)
                Spacer()
            }
            
            if toastIsDownloadSuccess {
                ToastView(message: "Image saved to Photos successfully!", isVisible: $toastIsDownloadSuccess)
                    .clipped()
                    .cornerRadius(5)
                Spacer()
            }
            
        }.background(.black.opacity(0.5))
        
    }
    
    func saveImage() async {
        if let image = imageDetail {
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                if status == .authorized {
                    PHPhotoLibrary.shared().performChanges {
                        PHAssetCreationRequest.creationRequestForAsset(from: image)
                    } completionHandler: { success, error in
                        if success {
                            print("Image saved to Photos successfully!")
                            
                            DispatchQueue.main.async {
                                InterstitialViewModel.shared.showAd()
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                toastIsDownloadSuccess.toggle()
                            }
                            
                        } else {
                            print("Error saving image to Photos: \(String(describing: error))")
                        }
                    }
                } else {
                    print("Photos access permission needed!")
                }
            }
        }
    }
    
    func getImageURL() {
        Task
        {
            if currentIndex > models.count || currentIndex < 0 {return}
            let firebaseData = FireStoreDatabase.shared
            if let url = await firebaseData.getURL(path: models[currentIndex].imageUrl) {
                model.imageUrlFull = url.absoluteString
                imageURL = url.absoluteString
            }
        }
    }
    
}
struct WrapperShowDetailImageView: View {
    @State var url: String = "https://firebasestorage.googleapis.com:443/v0/b/dotadressup.appspot.com/o/images%2FQOP%2FQOP54007?alt=media&token=2532aef3-1e88-4ded-bc37-14defbc1fd27"
    @State var model: ImageModel = ImageModel()
    @State var models: [ImageModel] = [ImageModel(),ImageModel(),ImageModel(),ImageModel()]
    
    var body: some View {
        @State var path =  NavigationPath()
        ShowDetailImageView(model: model, models: models, path: $path)
    }
}

#Preview {
    WrapperShowDetailImageView()
}
