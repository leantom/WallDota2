//
//  TabbarCustomView.swift
//  WallDota2
//
//  Created by QuangHo on 14/12/2023.
//

import SwiftUI

struct TabbarCustomView: View {
    @State var selection: Int = 1
    @State var fireStoreDB = FireStoreDatabase.shared
    @State var items: [ImageModel] = []
    @State var itemsSpotlight: [ImageModel] = []
    @State var imagesByID: [ImageModel] = []
    @State var heroesID: [String] = []
    
    @State var titleTabs: [String] = ["Home", "Collections", "Quickly", "Saved"]
    
    @State private var isShowDetailVC = false
    @State private var isShowDetailCollection = false
    @State private var isShowDetailImage = false
    
    @State var modelSelected: ImageModel = ImageModel()
    @State var isDownloadImage = ""
    
    @State private var toastIsVisible = false
    @State private var isLoading = false
    @State var progressBarValue: Double = 0
    @State var title: String = "Home"
    @State private var isMenuOpen = false
    @State private var isShowMoreSpotlight = false
    @State private var isShowDetailSpotlight = false
    @State var gradient: LinearGradient = LinearGradient(
        colors: [Color.blue.opacity(0.9), Color.clear],
        startPoint: .top, endPoint: .bottom
    )
    
    private var homeView: HomeView {
        HomeView(items: $items,
                 itemsSpotlight: $itemsSpotlight,
                 actionTapDetail: { model in
            withAnimation(.easeInOut) {
                if isMenuOpen {return}
                modelSelected = model
                isShowDetailVC = true
            }
        }, actionDownload: { progress in
            isLoading = true
            progressBarValue = progress
        }, actionDownloadFinished: {
            isLoading = false
            toastIsVisible = true
        }, actionShowDetailSpotlight:  { model in
            self.modelSelected = model
            self.isShowDetailSpotlight.toggle()
        }, actionShowMoreSpotlight: { list in
            self.isShowMoreSpotlight.toggle()
        })
    }
    
    var body: some View {
        ZStack {
            
            NavigationStack {
                TopView(toastIsVisible: $toastIsVisible,
                        isLoading: $isLoading,
                        progressBarValue: $progressBarValue,
                        title: $title, actionOpenMenu: {
                    withAnimation(.easeInOut) {
                        isMenuOpen.toggle()
                    }
                    
                })
                .frame(height: 50)
                .clipped()
                
                TabView(selection: $selection) {
                    homeView.onAppear(perform: {
                        Task {
                            if fireStoreDB.listAllImage.count > 0 {
                                return
                            }
                            await fireStoreDB.fetchDataFromFirestore()
                            self.items = fireStoreDB.listAllImage
                            self.itemsSpotlight = fireStoreDB.spotlightImages
                            self.heroesID = fireStoreDB.heroesID
                        }
                    }).font(.system(size: 30, weight: .bold, design: .rounded))
                        .tabItem {
                            Image(systemName: "house.fill")
                        }
                        .tag(1)
                    
                    
                    
                    CollectionHeroView(heroesID: $heroesID,
                                       _firestoreDB: $fireStoreDB,
                                       action: { heroID in
                        self.imagesByID = fireStoreDB.getImages(by: heroID)
                        self.isShowDetailCollection.toggle()
                    })
                    
                    .tabItem {
                        
                        Image(systemName: "command.circle")
                    }.tag(3)
                    
                    UserProfileView(_firestoreDB: $fireStoreDB)
                        .tabItem {
                            
                            Image(systemName: "person.crop.square")
                        }.tag(4)
                        
                }
                
                .onChange(of: selection) { newSelection in
                    // Handle selection change (user indirectly interacts with an item)
                    title = titleTabs[newSelection - 1]
                    print("Selected item: \(newSelection)")
                }
                .navigationDestination(isPresented: $isShowDetailVC) {
                    
                    ShowDetailImageView(dismissModal: {
                        isShowDetailVC = false
                    }, model: $modelSelected)
                    .navigationBarBackButtonHidden()
                }.navigationDestination(isPresented: $isShowDetailCollection) {
                    DetailHeroView(items: $imagesByID, actionBack: {
                        self.isShowDetailCollection.toggle()
                    })
                    .navigationBarBackButtonHidden()
                }.navigationDestination(isPresented: $isShowMoreSpotlight) {
                    SpotlightView(listImage: $itemsSpotlight, actionBack: {
                        isShowMoreSpotlight.toggle()
                    })
                    .navigationBarBackButtonHidden()
                    
                }.navigationDestination(isPresented: $isShowDetailSpotlight) {
                    ShowDetailImageView(dismissModal: {
                        isShowDetailSpotlight = false
                    }, model: $modelSelected)
                    .navigationBarBackButtonHidden()
                }
                .onAppear() {
                    
                    UITabBar.appearance().backgroundColor = .white
                }
                
            }
            .background(gradient.ignoresSafeArea())
            if isShowDetailVC == false &&
                isShowDetailCollection == false &&
                isShowMoreSpotlight == false &&
                isShowDetailSpotlight == false {
                SideMenu(isSidebarVisible: $isMenuOpen, actionChooseProfileUser: {
                    
                }, actionChooseCollection: {
                    
                })
            }
        }
        
        
    }
}


struct CustomTabItem: View {
    @State var item: TabBarItem
    @State var isSeletedButton: Bool = false
    
    var body: some View {
        HStack {
            Button(action: {
                isSeletedButton.toggle()
            }, label: {
                if isSeletedButton {
                    item.iconSelected.foregroundStyle(.white).font(.title2)
                } else {
                    item.icon.foregroundStyle(.white).font(.title2)
                }
            }).buttonStyle(.bordered)
        }
        .onAppear(perform: {
            self.isSeletedButton = item.isSelected
        })
        .frame(height: 30)
        .clipped()
    }
    
    @State private var isSelected: Bool = false
}
class TabBarItem: Identifiable, ObservableObject {
    let id = UUID().uuidString
    var title: String = "Home"
    let icon: Image
    var iconSelected: Image = Image(systemName: "heart.slash")
    
    @State var isSelected: Bool
    
    init() {
        title = "Home"
        icon = Image(systemName: "heart.slash")
        self.isSelected = false
        
    }
    init(icon: String, iconSelected: String) {
        self.icon = Image(systemName: icon)
        self.iconSelected = Image(systemName: iconSelected)
        self.isSelected = false
    }
    
    func setStatus(isOn: Bool) {
        self.isSelected = isOn
        self.objectWillChange.send()
    }
    
    
}

struct WrapperTabbarCustomView: View {
    
    var body: some View {
        TabbarCustomView()
    }
}

#Preview {
    WrapperTabbarCustomView()
}
