//
//  AppSetting.swift
//  WallDota2
//
//  Created by QuangHo on 20/12/2023.
//

import Foundation
import FirebaseAuth

class AppSetting {
    static let shared = AppSetting()
    var fcmToken: String = ""
    
    var isLogined: Bool = false {
        didSet {
            
        }
    }
   
    static func setLogined(value: Bool) {
        UserDefaults.standard.set(value, forKey: "isLogined")
    }
    
    
    static func setFirstLogined(value: Bool) {
        UserDefaults.standard.set(value, forKey: "isFirstLogined")
    }
    
    
   static func checkLogined() -> Bool {
        if let isLogined = UserDefaults.standard.object(forKey: "isLogined") as? Bool {
            return isLogined
        }
        return false
    }
    
    static  func checkisFirstLogined() -> Bool {
        if let isFirstLogined = UserDefaults.standard.object(forKey: "isFirstLogined") as? Bool {
            return isFirstLogined
        }
        return true
    }
    
    
}
