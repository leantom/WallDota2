//
//  TopView.swift
//  WallDota2
//
//  Created by QuangHo on 14/12/2023.
//

import SwiftUI

struct TopView: View {
    @Binding  var toastIsVisible:Bool
    @Binding  var isLoading:Bool
    @Binding  var progressBarValue: Double
    @Binding  var title: String
    var actionOpenMenu:(()-> Void)
    var body: some View {
        ZStack {
            VStack {
                HStack {
                   
                    Spacer()
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                    Spacer()
                    Button(action: {}, label: {
                        Image(systemName: "bell")
                            .foregroundColor(.black)
                            .font(.title3)
                    })
                    .padding()
                }
                .frame(height: 48)
            }
            
            if isLoading {
                VStack {
                    Spacer()
                    ProgressBarView(progress: progressBarValue)
                        .frame(height: 1)
                        
                }
            }
            
            
            if toastIsVisible{
                ToastView(message: "Image saved to Photos successfully!", isVisible: $toastIsVisible)
                    .clipped()
            }
        }
        
    }
}

struct WrapperTopView: View {
    @State var isShow: Bool = true
    @State private var isLoading = true
    @State var progressBarValue: Double = 0.2
    @State var title: String = "Home"
    var body: some View {
        TopView(toastIsVisible: $isShow,
                isLoading: $isLoading,
                progressBarValue: $progressBarValue,
                title: $title, actionOpenMenu: {})
    }
}

#Preview {
    WrapperTopView()
}
