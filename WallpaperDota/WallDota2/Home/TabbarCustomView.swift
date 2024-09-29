//
//  TabbarCustomView.swift
//  WallDota2
//
//  Created by QuangHo on 14/12/2023.
//

import SwiftUI
import Firebase
import FirebaseAuth
import AlertToast
import Network
import NavigationTransitions

struct TabbarCustomView: View {
    @State var selection: Int = 1
    @State var fireStoreDB = FireStoreDatabase.shared
    @State var items: [ImageModel] = []
    @State var itemsSpotlight: [ImageModel] = []
    @State var imagesByID: [ImageModel] = []
    @State var heroesID: [String] = []
    
    @State var titleTabs: [String] = ["Home", "Collections", "Profile", "LeaderBoard"]
    
    @State private var isShowDetailVC = false
    @State private var isShowDetailCollection = false
    @State private var isShowDetailImage = false
    
    @State var modelSelected: ImageModel = ImageModel()
    @State var listStoryModel: [StoryModel] = []
    
    @State var isDownloadImage = ""
    
    @State private var toastIsVisible = false
    @State private var isLoading = false
    @State var progressBarValue: Double = 0
    @State var title: String = "Home"
    
    @State private var isMenuOpen = false
    @State private var isShowMoreSpotlight = false
    
    @State private var isShowVideoView = false
    @State private var isShowVideoViewFullScreen = false
    @State private var isShowChapterView = false
    
    
    @State private var isLogout = false
    @State var isDeleteAccount: Bool = false
    
    @State private var userLogin: NewUser?
    
    @State var gradient: LinearGradient = LinearGradient(
        colors: [Color.white.opacity(0.9), Color.clear],
        startPoint: .top, endPoint: .bottom
    )
    private let viewAdsModel = InterstitialViewModel.shared
    var sideBarWidth = UIScreen.main.bounds.size.width * 0.65
    @Binding var path: NavigationPath
    
    private var homeView: HomeView {
        HomeView(isMenuOpen: $isMenuOpen, items: $items,
                 itemsSpotlight: $listStoryModel,
                 actionTapDetail: { model in
            withAnimation(.easeInOut) {
                if isMenuOpen {return}
                modelSelected = model
                AppSetting.shared.imageDetail = model
                AppSetting.shared.listImages = items
                path.append(Screen.detailImage.rawValue)
            }
        }, actionDownload: { progress in
            isLoading = true
            progressBarValue = progress
        }, actionDownloadFinished: {
            DispatchQueue.main.async {
                viewAdsModel.showAd()
            }
            isLoading = false
            toastIsVisible = true
        }, actionShowDetailSpotlight:  { model, items in
            AppSetting.shared.storySelected = model
            AppSetting.shared.listStoryModel = items
            path.append(Screen.story.rawValue)
        }, actionShowMoreSpotlight: { list in
            self.isShowMoreSpotlight.toggle()
        }, actionChooseShowComic: { comic in
            AppSetting.shared.comicSelected = comic
            path.append(Screen.comic.rawValue)
        })
    }
    
    var sideMenu: SideMenu {
        SideMenu(isSidebarVisible: $isMenuOpen,
                 actionChooseProfileUser: { _selection in
            if selection == _selection {return}
            selection = 3
        }, actionChooseCollection: { _selection in
            if selection == _selection {return}
            selection = 2
        }, actionChooseHome: { _selection in
            if selection == _selection {return}
            selection = 1
            
        }, actionLogout: { _selection in
            AppSetting.setLogined(value: false)
            Task {
                
                try Auth.auth().signOut()
            }
            
            withAnimation {
                if path.isEmpty {
                    return
                }
                path.removeLast()
            }
            
        }, actionDeleteAccount: {
            AppSetting.setLogined(value: false)
            Task {
                
                try Auth.auth().signOut()
            }
            withAnimation {
                
                if path.isEmpty {
                    return
                }
                path.removeLast()
            }
        }, userLogin: $userLogin)
    }
    
    var videoView = VideoView(dismissModal: {
        
    })
    
    var body: some View {
        ZStack {
            
            if isShowDetailVC == false &&
                isShowDetailCollection == false &&
                isShowMoreSpotlight == false {
                sideMenu
            }
            VStack {
                if self.isShowVideoView == false && isMenuOpen == false {
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
                }
                TabView(selection: $selection) {
                    homeView.onAppear(perform: {
                        Task {
                            if self.listStoryModel.count == 0 {
                                self.listStoryModel =  await StoryViewModel.shared.getTop5StoriesByHeroID(language: "en")
                            }
                            
                            if fireStoreDB.listAllImage.count > 0 {
                                
                                self.items = fireStoreDB.listAllImage
                                self.heroesID = fireStoreDB.heroesID
                                return
                            }
                            
                            await fireStoreDB.fetchDataFromFirestore()
                            
                            self.items = fireStoreDB.listAllImage
                            // MARK: ---
                            self.heroesID = fireStoreDB.heroesID
                        }
                    }).font(.system(size: 30, weight: .bold, design: .rounded))
                        .tabItem {
                            Image(systemName: "house.fill")
                        }
                        .tag(1)
                        .disabled(isMenuOpen)
                    //// ---- Collection view
                    CollectionHeroView(heroesID: $heroesID,
                                       _firestoreDB: $fireStoreDB,
                                       action: { heroID in
                        
                        AppSetting.shared.imagesHero = fireStoreDB.getImages(by: heroID)
                        path.append(Screen.detailHero.rawValue)
                    })
                    .tabItem {
                        
                        Image(systemName: "command.circle")
                    }.tag(2)
                    ComicListView(actionChooseShowComic: { comic in
                        AppSetting.shared.comicSelected = comic
                        path.append(Screen.comic.rawValue)
                        
                    })
                    .tabItem {
                        Image(systemName: "book.fill")
                    }.tag(3)
                    LeaderBoardView()
                        .tabItem {
                            Image(systemName: "chart.bar.doc.horizontal")
                        }.tag(4)
                    
                    
                }
                .onChange(of: selection) { newSelection in
                    // Handle selection change (user indirectly interacts with an item)
                    title = titleTabs[newSelection - 1]
                    
                    self.isShowVideoView = newSelection == 3
                    print("Selected item: \(newSelection)")
                }
                .navigationDestination(isPresented: $isShowMoreSpotlight) {
                    SpotlightView(listImage: $itemsSpotlight, actionBack: {
                        isShowMoreSpotlight.toggle()
                    })
                    .navigationBarBackButtonHidden()
                    
                }
                .alert(isPresented: $isDeleteAccount) {
                    Alert(
                        title: Text("Warning"),
                        message: Text("Do you really want to delete your account"),
                        primaryButton: .default(
                            Text("OK"),
                            action: {
                                Task {
                                    await LoginViewModel.shared.deleteUser()
                                    isLogout.toggle()
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
                .onAppear() {
                    UITabBar.appearance().backgroundColor = .white
                }
                .background(gradient.ignoresSafeArea())
                .cornerRadius(isMenuOpen ? 20 : 0)
                .offset(x: isMenuOpen ? sideBarWidth : 0)
                .scaleEffect(isMenuOpen ? 0.5 : 1)
                .animation(.smooth, value: isMenuOpen)
                .navigationBarBackButtonHidden()
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
    @State var path = NavigationPath()
    var body: some View {
        TabbarCustomView(path: $path)
    }
}

#Preview {
    WrapperTabbarCustomView()
}
