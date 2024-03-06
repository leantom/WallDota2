//
//  ShowDetailImageView.swift
//  WallDota2
//
//  Created by QuangHo on 15/12/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct ShowDetailImageView: View {
    let dismissModal: () -> Void
    
    @Binding var model: ImageModel
    @Binding var models: [ImageModel] // list hinh
    
    @State var imageURL: String = ""
    let gradient: LinearGradient = LinearGradient(
        colors: [Color.blue.opacity(0.2), Color.clear],
        startPoint: .top, endPoint: .bottom
    )
    @State var isShowOnlyImage: Bool = false
    @State var showAlert: Bool = false
    @State var toastIsVisible: Bool = false
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
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollViewReader { proxy in
                    ScrollView(.vertical) {
                        LazyVGrid(columns: columns, spacing: 0) {
                            ForEach(models, id: \.id) { model in
                                if self.imageURL.isEmpty == false {
                                    if let index = models.firstIndex(where: { image in
                                        return image.id == model.id
                                    }) {
                                        WebImage(url: URL(string: model.imageUrlFull))
                                            .resizable()
                                            .placeholder(content: {
                                                ProgressView()
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
                                                    let firebaseData = FireStoreDatabase.shared
                                                    if model.imageUrlFull.isEmpty, let url = await firebaseData.getURL(path: model.imageUrl) {
                                                        model.imageUrlFull = url.absoluteString
                                                        imageURL = url.absoluteString
                                                        model.isLoadedImageOriginal.toggle()
                                                        print(imageURL)
                                                    }
                                                    
                                                }
                                            }
                                            .id(index)
                                    }
                                    
                                } else {
                                    ProgressView()
                                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                                        .onAppear {
                                            Task
                                            {
                                                let firebaseData = FireStoreDatabase.shared
                                                if model.imageUrlFull.isEmpty, let url = await firebaseData.getURL(path: model.imageUrl) {
                                                    model.imageUrlFull = url.absoluteString
                                                    imageURL = url.absoluteString
                                                    model.isLoadedImageOriginal.toggle()
                                                    print(imageURL)
                                                }
                                            }
                                        }
                                }
                                
                                
                            }
                            
                        }
                    }
                    .ignoresSafeArea()
                    .introspect(.scrollView, on: .iOS(.v15, .v16, .v17)) { sv in
                        sv.isPagingEnabled = true
                    }
                    .onChange(of: currentIndex) { targetIndex in
                        withAnimation {
                            // Use the proxy to scroll to the desired index with animation
                            proxy.scrollTo(targetIndex, anchor: .top)
                        }
                           
                    }
                }
                .onAppear {
                    // Example: Scroll to the 50th item when the view appears
                    Task
                    {
                        let firebaseData = FireStoreDatabase.shared
                        if model.imageUrlFull.isEmpty, let url = await firebaseData.getURL(path: model.imageUrl) {
                            model.imageUrlFull = url.absoluteString
                            imageURL = url.absoluteString
                            model.isLoadedImageOriginal.toggle()
                            print(imageURL)
                        } else {
                            imageURL = model.imageUrlFull
                        }
                        
                        if let index = models.firstIndex(where: { image in
                            return image.id == model.id
                        }) {
                            currentIndex = index
                        }
                    }
                }

                VStack {
                    HStack {
                        
                        Button(action: {
                            withAnimation {
                                dismissModal()
                            }
                            
                        }, label: {
                            Image(systemName: "arrow.backward")
                                .foregroundColor(.white)
                                .font(.title2)
                        })
                        .frame(width: 40, height: 40)
                        .background(Color("kC6C2D8").opacity(isShowOnlyImage ? 0.4 : 0.8))
                        .cornerRadius(10)
                        Spacer()
                        if isShowOnlyImage == false {
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
                    }.padding()
                        .frame(width: UIScreen.main.bounds.width)
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
                    }
                }
                VStack {
                    ToastView(message: "Thank you for reporting this issue to us, we will handle it immediately!", isVisible: $toastIsVisible)
                        .clipped()
                        .cornerRadius(5)
                    Spacer()
                }
                
            }.background(.black.opacity(0.5))
            
        }
        .navigationDestination(isPresented:$isShowPreviewImage) {
            PhotoEdittor(inputImage: imageDetail,
                         actionBack: {
                isShowPreviewImage.toggle()
            })
        .navigationBarBackButtonHidden()
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
    @State var url: String = "https://firebasestorage.googleapis.com/v0/b/dotadressup.appspot.com/o/images%2FPhantom%20assassin%2FPhantom%20assassin58931?alt=media&token=33fc2537-481e-42bd-9bd7-4266442c5faa"
    @State var model: ImageModel = ImageModel()
    @State var models: [ImageModel] = [ImageModel(),ImageModel(),ImageModel(),ImageModel()]
    
    var body: some View {
        ShowDetailImageView(dismissModal: {
            
        }, model: $model, models: $models)
    }
}

#Preview {
    WrapperShowDetailImageView()
}
