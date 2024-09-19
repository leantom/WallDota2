//
//  SpotlightViewV2.swift
//  WallDota2
//
//  Created by QuangHo on 2/5/24.
//

import SwiftUI
import SDWebImageSwiftUI
import GoogleMobileAds

extension [ImageModel] {
    func zIndex(_ item: ImageModel) -> CGFloat {
        if let index = firstIndex(where: {$0.id == item.id}) {
            return CGFloat(count) - CGFloat(index)
        }
        return .zero
    }
    var isLoadedAllThumbnail: Bool {
        if self.filter({ image in
            image.thumbnailFull.isEmpty == false
        }).count == self.count {
            return true
        }
        
        return false
    }
}

@available(iOS 16.0, *)
struct SpotlightViewV2: View {
    @State var showIndicator: Bool = false
    @State var isLoadedImages: Bool = false
    @State var itemsSpotlight: [StoryModel] = []
    var actionShowDetailSpotlight:((StoryModel, [StoryModel]) -> Void)
    var actionShowMoreSpotlight:(([ImageModel]) -> Void)
    @State private var currentIndex: Int = 0
    var size: CGSize {
            return GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(width).size
        }
    var body: some View {
        VStack {
            HStack {
                Text("Stories")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                Spacer()
            }
            .padding()
            
            GeometryReader { geometry in
                
                if #available(iOS 17.0, *) {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 22
                        ) {
                            
                            ForEach(itemsSpotlight) { item in
                                
                                CardView(item: item)
                                    .scrollTransition(axis: .horizontal) {
                                        content, phase in
                                        content.rotationEffect(.degrees(phase.value * 2.5))
                                            .offset(y: phase.isIdentity ? 0 : 8)
                                    }
                                    
                                    .onTapGesture {
                                        self.actionShowDetailSpotlight(item, itemsSpotlight)
                                    }
                            }
                        }
                    }
                    .contentMargins(.horizontal, 20)
                    .scrollTargetBehavior(.paging)
                    .scrollIndicators(.hidden)
                    .onAppear(perform: {
                        loadImaged()
                    })
                    
                } else {
                    ProgressView()
                }
                
                
            }
            .frame(height: 300)
        }
        .onAppear(perform: {
            self.itemsSpotlight = StoryViewModel.shared.topStory
        })
    }
    
    func updateScrollPosition(newValue: CGFloat, geometry: GeometryProxy, scrollProxy: ScrollViewProxy) {
           let itemWidth: CGFloat = 315.0 // Assuming each item has a width of 200 + 15 spacing
           let newIndex = Int((newValue + geometry.size.width / 2) / itemWidth)
           let clampedIndex = min(max(newIndex, 0), itemsSpotlight.count - 1)
           
           if clampedIndex != currentIndex {
               currentIndex = clampedIndex
               withAnimation {
                   scrollProxy.scrollTo(currentIndex, anchor: .center)
               }
           }
       }
    
    func loadImaged() {
        Task {
            let firebaseData = FireStoreDatabase.shared
            
//            if itemsSpotlight.isLoadedAllThumbnail == false {
//                for item in itemsSpotlight {
//                    if item.imageUrlFull.isEmpty,
//                       let thumbnail = await firebaseData.getURL(path: item.thumbnail) {
//                        item.thumbnailFull = thumbnail.absoluteString
//                        item.isLoadedThumbnail.toggle()
//                    } else {
//                        print("not loaded")
//                    }
//                }
//                isLoadedImages = itemsSpotlight.isLoadedAllThumbnail
//            }
            
        }
    }

    
}

