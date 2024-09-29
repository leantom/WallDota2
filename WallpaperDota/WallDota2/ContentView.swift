//
//  ContentView.swift
//  WallDota2
//
//  Created by QuangHo on 12/12/2023.
//
import SwiftUI
import Firebase
import FirebaseAuth
import AlertToast
import Network
import NavigationTransitions

enum Screen: String {
    case home = "home"
    case login = "Login"
    case comic = "comic"
    case detailCollection = "detailCollection"
    case detailImage = "detailImage"
    case story = "story"
    case detailHero = "detailHero"
    case splashScreen = "splashScreen"
    case unknown
    
    init(rawValue: String) {
            switch rawValue {
            
            case "Login": self = .login
            case "comic": self = .comic
            case "detailCollection": self = .detailCollection
            case "detailImage": self = .detailImage
            case "story": self = .story
            case "detailHero": self = .detailHero
            case "home": self = .home
            case "splashScreen": self = .splashScreen
            default: self = .unknown
            }
        }
}

struct ContentView: View {
    

    let monitor = NWPathMonitor()
    
    @StateObject var notificationManager = NotificationManager()
    @State var ismissingInternet = false
    @State private var images = [Image]()
    
    @State var modelSelected: ImageModel = ImageModel()
    @State var items: [ImageModel] = []
    @State var imagesByID: [ImageModel] = []
    @State var storySelected: StoryModel?
    init() {
       
    }
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path){
            VStack {
                if AppSetting.checkisFirstLogined() {
                    SplashScreenView(currentIndex: 0, path: $path).navigationBarBackButtonHidden()
                }  else {
                    LoginView(path: $path).navigationBarBackButtonHidden()
                }
            }.navigationDestination(for: String.self) { value in
                switch Screen(rawValue: value) {
                case .login:
                    LoginView(path: $path).navigationBarBackButtonHidden()
                case .detailCollection:
                    DetailHeroView(path: $path)
                    .navigationBarBackButtonHidden()
                case .detailImage:
                    ShowDetailImageView(path: $path)
                    .navigationBarBackButtonHidden()
                case .detailHero:
                    DetailHeroView(path: $path)
                    .navigationBarBackButtonHidden()
                case .home:
                    TabbarCustomView(path: $path)
                        .navigationBarBackButtonHidden()
                case .comic:
                    if let comic = AppSetting.shared.comicSelected {
                        ComicReviewView(comic: comic)
                        .navigationBarBackButtonHidden()
                    }
                case .story:
                    if let story = AppSetting.shared.storySelected {
                        
                        StoryView(model: story, actionChooseStory: { model in
                            
                        }).navigationBarBackButtonHidden()
                    }
                case .splashScreen:
                    SplashScreenView(path: $path).navigationBarBackButtonHidden()
                default:
                    LoginView(path: $path).navigationBarBackButtonHidden()
                }
            }
            
           
        }.toast(isPresenting: $ismissingInternet){
            //AlertToast(displayMode: .banner(.slide), type: .regular, title: "No internet connection")
            AlertToast(displayMode: .hud, type: .regular, title: "No internet connection")
        }
        .navigationTransition(.fade(.cross))
        .onAppear(perform: {
            let queue = DispatchQueue(label: "NetworkMonitor")
            monitor.start(queue: queue)
            monitor.pathUpdateHandler = { path in
                if path.status == .satisfied {
                    ismissingInternet = false
                    print("Internet connection is available.")
                    // Perform actions when internet is available
                } else {
                    ismissingInternet = true
                    print("Internet connection is not available.")
                    // Perform actions when internet is not available
                }
            }
        })
    }

    private func loadImages() {
        // Replace with your actual image loading logic
        images.append(Image("image1"))
        images.append(Image("image2"))
        images.append(Image("image3"))
        images.append(Image("image4"))
        print("abc")
    }
}

#Preview {
    ContentView()
}
