//
//  Tabbar+Extention.swift
//  WallDota2
//
//  Created by QuangHo on 25/9/24.
//
import UIKit

extension UITabBarController {
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        tabBar.layer.masksToBounds = true
        
        tabBar.frame = CGRect(x: tabBar.frame.origin.x, y: UIScreen.main.bounds.size.height - tabBar.frame.size.height, width: tabBar.frame.size.width, height: tabBar.frame.size.height)
        
        // Shadow view logic for adding a shadow behind the tab bar
        if let shadowView = view.subviews.first(where: { $0.accessibilityIdentifier == "TabBarShadow" }) {
            shadowView.frame = tabBar.frame
        } else {
            let shadowView = UIView(frame: .zero)
            shadowView.frame = tabBar.frame
            shadowView.accessibilityIdentifier = "TabBarShadow"
            shadowView.backgroundColor = UIColor.white
            shadowView.layer.cornerRadius = tabBar.layer.cornerRadius
            shadowView.layer.maskedCorners = tabBar.layer.maskedCorners
            shadowView.layer.masksToBounds = false
            shadowView.layer.shadowColor = UIColor.black.cgColor
            shadowView.layer.shadowOffset = CGSize(width: 0.0, height: -0.0)
            shadowView.layer.shadowOpacity = 0.2
            shadowView.layer.shadowRadius = 10
            view.addSubview(shadowView)
            view.bringSubviewToFront(tabBar)
        }
    }

}
