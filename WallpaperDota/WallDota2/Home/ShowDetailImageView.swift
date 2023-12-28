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
    @State var imageURL: String = ""
    let gradient: LinearGradient = LinearGradient(
        colors: [Color.blue.opacity(0.2), Color.clear],
        startPoint: .top, endPoint: .bottom
    )
    @State var isShowOnlyImage: Bool = false
    @State var showAlert: Bool = false
    @State var toastIsVisible: Bool = false
    @State private var isShowPreviewImage = false
    
    @State var imageDetail: UIImage?
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    if imageURL.isEmpty {
                        ProgressView()
                    } else {
                        
                        WebImage(url: URL(string: imageURL))
                            .resizable()
                            .placeholder(content: {
                                ProgressView()
                            })
                            .onSuccess(perform: { image, data, type in
                                imageDetail = image
                            })
                            .scaledToFill()
                            .ignoresSafeArea()
                            .frame(width: UIScreen.main.bounds.width)
                            .edgesIgnoringSafeArea(.all)
                    }
                }
                .onAppear(perform: {
                    Task
                    {
                        let firebaseData = FireStoreDatabase.shared
                        if let url = await firebaseData.getURL(path: model.imageUrl) {
                            model.imageUrlFull = url.absoluteString
                            imageURL = url.absoluteString
                        }
                    }
                })
                gradient.edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isShowOnlyImage.toggle()
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
            
//            WrapperImageModifierView(model: $model, dismissModal: {
//                isShowPreviewImage.toggle()
//            })
//            .navigationBarBackButtonHidden()
        }
        
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
