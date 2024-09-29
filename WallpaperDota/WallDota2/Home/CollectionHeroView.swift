//
//  CollectionView.swift
//  WallDota2
//
//  Created by QuangHo on 18/12/2023.
//

import SwiftUI
import SDWebImageSwiftUI
import GoogleMobileAds

struct CollectionHeroView: View {
    @State private var toastIsVisible = false
    @State private var isLoading = true
    @State var progressBarValue: Double = 0
    
    @Binding var heroesID:[String]
    @Binding var _firestoreDB:FireStoreDatabase
    @State var listCollectionModel:[ImageModel] = []
    
    let gradient: LinearGradient = LinearGradient(
        colors: [randomColor().opacity(0.4), randomColor().opacity(0.1)],
        startPoint: .bottom, endPoint: .top
    )
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    @State private  var isShowAds: Bool = false
    var action:((String) -> Void)
    var body: some View {
        GeometryReader { geometry in
            let adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(geometry.size.width)
            VStack {
                
                HStack {
                    Text("Collections")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                        .padding()
                    Spacer()
                }
                ScrollView {
                    if isLoading {
                        ProgressView().padding()
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            // Loop through the items and create ItemCell views
                            ForEach(listCollectionModel, id: \.heroID) {item in
                                CollectionCellHeroView(item: item)
                                    .onTapGesture {
                                        print(item.heroID)
                                        self.action(item.heroID)
                                    }
                                
                            }
                        }
                        .padding()
                    }
                    
                }
                .onAppear(perform: {
                    Task {
                        if $_firestoreDB.listCollectionImages.count == 0 {
                            await FireStoreDatabase.shared.fetchDataCollectionFromFirestore()
                            isLoading = false
                        }
                        self.listCollectionModel = _firestoreDB.listCollectionImages
                        isLoading = false
                    }
                    if isShowAds == false{
                        GoogleMobileAdsConsentManager.shared.gatherConsent { consentError in
                          if let consentError {
                            // Consent gathering failed.
                            print("Error: \(consentError.localizedDescription)")
                              self.isShowAds = false
                          }
                          GoogleMobileAdsConsentManager.shared.startGoogleMobileAdsSDK()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.isShowAds = true
                            }
                        }

                        // This sample attempts to load ads using consent obtained in the previous session.
                        GoogleMobileAdsConsentManager.shared.startGoogleMobileAdsSDK()
                    }
                    adSizeGlobal = adSize
                    
                })
                .refreshable {
                    await _firestoreDB.fetchDataCollectionFromFirestore()
                    self.listCollectionModel = _firestoreDB.listCollectionImages
                    isLoading = false
                }
                
                if isShowAds {
                    BannerView(adSize)
                      .frame(height: 50)
                }
            }
        }
        
    }
    
    
    
}

struct CollectionCellHeroView: View {
    @StateObject var item: ImageModel
    let gradient: LinearGradient = LinearGradient(
        colors: [Color.black.opacity(0.5), Color.black.opacity(0.2)],
        startPoint: .leading, endPoint: .trailing
    )
    @State var isLoadedImage = false
    @State var isLike = false
    var body: some View {
        HStack {
            ZStack {
                VStack {
                    if item.isLoadedThumbnail {
                        WebImage(url: URL(string: item.thumbnailFull))
                            .resizable()
                            .placeholder {
                                ProgressView()
                            }
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()
                        .cornerRadius(10)
                        
                    } else {
                        ProgressView()
                    }
                    
                    VStack (alignment: .leading){
                        Text(item.heroID)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                        .padding([.leading, .trailing], 10)
                        HStack {
                            Image(systemName:"heart.fill")
                                .foregroundColor( isLike ? .red : .gray)
                                .padding([.leading, .bottom], 10)
                                .onTapGesture {
                                    withAnimation {
                                        isLike.toggle()
                                    }
                                    Task {
                                        await FireStoreDatabase.likeCollectionImage(image: item)
                                    }
                                }
                            Text("\(item.likeCount)")
                                .font(.caption)
                                .foregroundStyle(.black.opacity(0.8))
                                .padding([.trailing, .bottom], 10)
                            Spacer()
                        }
                        .padding(.top, 5)
                    }
                    
                }
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 5)
            }
            
        }
        
        .onAppear {
            Task {
                
                let url = await FireStoreDatabase.shared.getURL(path: item.thumbnail)
                item.isLoadedThumbnail = true
                item.thumbnailFull = url?.absoluteString ?? ""
                
            }
        }
        
    }
}

struct WrapperCollectionHeroView:View {
    @State var heroids = ["Crystal maiden",
                          "Lina", "Templar Assassin"]
    @State var firestoreDB = FireStoreDatabase()
    
    var body: some View {
        CollectionView(heroesID: $heroids, _firestoreDB: $firestoreDB, action: { heroID in
            
        })
    }
}

#Preview {
    WrapperCollectionHeroView()
}
