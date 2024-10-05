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
import FirebaseRemoteConfig

enum Screen: String {
    case home = "home"
    case login = "Login"
    case comic = "comic"
    case detailCollection = "detailCollection"
    case detailImage = "detailImage"
    case story = "story"
    case detailHero = "detailHero"
    case splashScreen = "splashScreen"
    case commentScreen = "commentScreen"
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
        case "commentScreen": self = .commentScreen
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
    let remoteConfig = RemoteConfig.remoteConfig()
    
    init() {
        print("ContentView")
        
    }
    
    private func setupRemoteConfig() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600 // Fetch every hour
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(["min_required_version": "1.4" as NSObject])
    }
    
    func fetchRemoteConfig() {
        remoteConfig.fetch {  status, error in
            if status == .success {
                self.remoteConfig.activate { _, _ in
                    self.checkAppVersion()
                }
            } else if let error = error {
                print("Error fetching remote config: \(error.localizedDescription)")
            }
        }
    }
    
    func checkAppVersion() {
        let minRequiredVersion = remoteConfig["min_required_version"].stringValue
        if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            if currentVersion.compare(minRequiredVersion, options: .numeric) == .orderedAscending {
                // Trigger the force update process
                forceUpdateApp()
            }
        }
    }
    
    private func forceUpdateApp() {
        // Implement the logic to show an alert or modal that forces the user to update the app
        print("App requires an update to version \(remoteConfig["min_required_version"].stringValue)")
        forceUpdate = true
        
    }
    @State var forceUpdate: Bool = false
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
                            
                        }, path: $path).navigationBarBackButtonHidden()
                    }
                case .splashScreen:
                    SplashScreenView(path: $path).navigationBarBackButtonHidden()
                default:
                    LoginView(path: $path).navigationBarBackButtonHidden()
                }
            }
            .alert(isPresented: $forceUpdate) {
                Alert(
                    title: Text("Update Required"),
                    message: Text("A newer version of the app is required. Please update to continue."),
                    primaryButton: .default(Text("Update"), action: {
                        // Redirect to the App Store or update page
                        
                        if let url = URL(string: "itms-apps://apple.com/app/id6474777263") {
                            UIApplication.shared.open(url)
                        }
                    }),
                    secondaryButton: .cancel(Text("Close App"), action: {
                        // Optionally close the app if an update is required
                        exit(0)
                    })
                )
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
            setupRemoteConfig()
            fetchRemoteConfig()
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
