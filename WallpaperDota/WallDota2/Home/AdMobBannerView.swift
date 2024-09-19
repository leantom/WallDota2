//
//  AdMobBannerView.swift
//  WallDota2
//
//  Created by QuangHo on 12/9/24.
//

import SwiftUI
import GoogleMobileAds
protocol BannerViewControllerWidthDelegate: AnyObject {
    func bannerViewController(_ bannerViewController: BannerViewController, didUpdate width: CGFloat)
}


class BannerViewController: UIViewController {
    weak var delegate: BannerViewControllerWidthDelegate?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        // Tell the delegate the initial ad width.
        delegate?.bannerViewController(self, didUpdate: view.frame.inset(by: view.safeAreaInsets).size.width)
    }
}
struct BannerView: UIViewControllerRepresentable {
    
    static let shared: BannerView = BannerView()
    
    @State
    private var viewWidth: CGFloat = .zero
    
    private let bannerView = GADBannerView()
    private let adUnitID = "ca-app-pub-7153595903380471/4763811553"
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let bannerViewController = BannerViewController()
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = bannerViewController
        bannerViewController.view.addSubview(bannerView)
        bannerViewController.delegate = context.coordinator
        
        return bannerViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard viewWidth != .zero else { return }
        
        // Request a banner ad with the updated viewWidth.
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView.load(GADRequest())
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, BannerViewControllerWidthDelegate {
        let parent: BannerView
        
        init(_ parent: BannerView) {
            self.parent = parent
        }
        
        // MARK: - BannerViewControllerWidthDelegate methods
        
        func bannerViewController(_ bannerViewController: BannerViewController, didUpdate width: CGFloat) {
            // Pass the viewWidth from Coordinator to BannerView.
            parent.viewWidth = width
        }
    }
}

struct AdMobBannerView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-7153595903380471/4763811553" // Replace with your actual Ad Unit ID
        
        // Use the correct way to find the root view controller in SwiftUI
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            bannerView.rootViewController = windowScene.windows.first?.rootViewController
        }
        
        bannerView.load(GADRequest())
        return bannerView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        // You may want to update the ad request or ad unit id if needed
    }

}


#Preview {
    AdMobBannerView()
}
