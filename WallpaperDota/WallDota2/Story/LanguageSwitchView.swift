//
//  LanguageSwitchView.swift
//  WallDota2
//
//  Created by QuangHo on 19/9/24.
//

import SwiftUI

struct LanguageSwitchView: View {
    @Binding var isVietnamese: Bool
    
    @State var changeValue: Bool = false
    
    
    var body: some View {
        HStack {
            
            Toggle(isOn: $changeValue) {
                
            }
            .toggleStyle(.switch)
            .onChange(of: changeValue) { newValue in
                            if newValue {
                                changeLanguage(to: "vi")
                            } else {
                                changeLanguage(to: "en")
                            }
                        }
            Text(isVietnamese ? "VN" : "EN")
                .font(.caption)
                .foregroundColor(.red.opacity(0.7))
                .fontWeight(.bold)
                .padding(.leading, 5)
            
        }
        .onAppear(perform: {
            changeValue = isVietnamese
        })
        .padding()
    }
    
    func changeLanguage(to langCode: String) {
        // Update the app's locale
        isVietnamese = langCode == "vi"
        UserDefaults.standard.set([langCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        
    }
}


struct WrapperLanguageSwitchView : View {
    @State var isEnglish = false
    var body: some View {
        LanguageSwitchView(isVietnamese: $isEnglish)
    }
}

#Preview {
    WrapperLanguageSwitchView()
}
