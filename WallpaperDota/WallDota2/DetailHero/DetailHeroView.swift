//
//  DetailHeroView.swift
//  WallDota2
//
//  Created by QuangHo on 18/12/2023.
//

import SwiftUI
import SDWebImageSwiftUI
import NavigationTransitions

struct DetailHeroView: View {
    
    @Binding var items: [ImageModel]
    let columns = [GridItem(.flexible(minimum: 120, maximum: 180)), GridItem(.flexible(minimum: 120, maximum: 180)), GridItem(.flexible(minimum: 120, maximum: 180))]
    @State var heroName: String = ""
    var actionBack:(()-> Void)
    @State var isShowDetail: Bool = false
    @State var isShowPreviewImage: Bool = false
    @State var isStoryHero: Bool = false
    
    @State var modelSelected: ImageModel = ImageModel()
    @State var listStoryModel: [StoryModel] = []
    @State var storyModel: StoryModel = StoryModel()
    
    @State var viewModel: DetailHeroViewModel?
    
    @State  var progressBarValue: Double = 20
    @State  var isLoading: Bool = false
    @State  var toastIsVisible: Bool = false
    @State  var isChangeLanguage: Bool = false
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                VStack(spacing: 15) {
                    ZStack {
                        VStack {
                            if toastIsVisible {
                                ToastView(message: "Image saved to Photos successfully!", isVisible: $toastIsVisible)
                                    .clipped()
                                    .cornerRadius(5)
                            }
                            if isLoading {
                                VStack {
                                    ProgressBarView(progress: progressBarValue)
                                        .frame(height: 1)
                                        
                                }
                            }
                            Spacer()
                        }
                        .frame(height: 50)
                        HStack {
                            Button {
                                self.actionBack()
                            } label: {
                                Image(systemName: "arrow.backward")
                                    .foregroundColor(.black)
                                    .font(.title2)
                                    .padding()
                            }
                            Spacer()
                            Toggle(isOn: $isChangeLanguage, label: {
                                Text(isChangeLanguage ? "EN" : "VN")
                                    .font(.caption)
                            }).frame(width:80)
                                .padding(.trailing, 10)
                                .onChange(of: isChangeLanguage) { newValue in
                                    print("Toggle is now", newValue ? "on" : "off")
                                    
                                    let language = isChangeLanguage ? "en" : "vn"
                                    Task {
                                        let items = await StoryViewModel.shared.getStoryByHeroID(by: heroName, language: language)
                                        listStoryModel = items
                                        print(listStoryModel.count)
                                    }
                                    
                                  }
                        }
                    }
                    if listStoryModel.count > 0{
                        HStack {
                            Text(heroName + "'s story")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.leading, 10)
                            Spacer()
                        }
                    }
                    
                    
                    ScrollView(.vertical) {
                        if listStoryModel.count > 0 {
                            listStoryView.padding(.leading, 10)
                        }
                        
                        HStack {
                            Text("Themes")
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.leading, 10)
                            Spacer()
                        }
                        LazyVStack {
                            
                            LazyVGrid(columns: columns, spacing: 5, content: {
                                ForEach(items) { show in
                                    ShowItemView(show: show,
                                                 actionDownload: {
                                        isLoading = false
                                        toastIsVisible = true
                                    }, actionDownloadProgressBar: { progress in
                                        self.isLoading = true
                                        self.progressBarValue = progress
                                    }, actionComment: { model in
                                        
                                    }).onTapGesture {
                                        modelSelected = show
                                        isShowDetail.toggle()
                                        
                                    }
                                }
                            })
                        }.clipped()
                    }.onAppear(perform: {
                        self.heroName = items.first?.heroID ?? ""
                    }).frame(width: UIScreen.main.bounds.width * 0.98)
                        .refreshable {
                            Task {
                                guard let viewModel = self.viewModel else{return}
                                await viewModel.fetchDataFromFirestore(id: self.heroName)
                                items = viewModel.heroesImages
                            }
                        }
                        
                }
            }
            .onAppear(perform: {
                viewModel = DetailHeroViewModel(id: heroName)
                if listStoryModel.count > 0 {return}
                listStoryModel.removeAll()
                Task {
                    let items = await StoryViewModel.shared.getStoryByHeroID(by: heroName, language: "vn")
                    listStoryModel.append(contentsOf: items)
                    print(listStoryModel.count)
                }
            })
        }
        .navigationTransition(
            .fade(.in).combined(with: .slide)
        )
        .navigationDestination(isPresented:$isShowDetail) {
            ShowDetailImageView(dismissModal: {
                isShowDetail = false
            }, model: $modelSelected, 
                                models: $items)
            .navigationBarBackButtonHidden()
        }
        .navigationDestination(isPresented:$isStoryHero) {
            StoryView(dismissModal: {
                isStoryHero = false
            }, model: $storyModel, isVietnameseLanguage: $isChangeLanguage)
            .navigationBarBackButtonHidden()
        }
    }
    
    
    
    var listStoryView : some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: [GridItem(.fixed(150))], spacing: 10, content: {
                ForEach(listStoryModel) { model in
                    ListStoryView(model: model)
                    .onTapGesture {
                        storyModel = model
                        isStoryHero.toggle()
                    }
                    
                }
            })
            .frame(height: 200)
        }
    }
    
}

struct ListStoryView: View {
    @StateObject var model: StoryModel
    
    var body: some View {
        VStack(spacing: 10) {
            if model.isLoadedThumbnail {
                AnimatedImage(url: URL(string: model.thumbnail))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 150)
                    .cornerRadius(10)
                    .clipped()
            } else {
                ProgressView()
            }
            Text(model.content.title)
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(.black)
                .frame(width: 150)
                .cornerRadius(8)
                .padding(.leading, 10)
            
        }
        .background(model.isLoadedThumbnail ? Color.clear : randomColor().opacity(0.7))
        .onAppear(perform: {
            Task {
                let firebaseData = FireStoreDatabase.shared
                let url = await firebaseData.getURL(path: model.thumbnail)
                if let _url = url,  _url.absoluteString.isEmpty == false {
                    model.thumbnail = url?.absoluteString ?? ""
                }
                model.isLoadedThumbnail = true
                
            }
        })
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
    }
}

struct WrapperDetailHeroView: View {
    @State var items: [ImageModel] = [ImageModel(), ImageModel()]
    var body: some View {
        DetailHeroView(items: $items, actionBack: {})
    }
}
#Preview {
    WrapperDetailHeroView()
}
