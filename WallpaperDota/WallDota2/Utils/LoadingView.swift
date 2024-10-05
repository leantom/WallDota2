//
//  LoadingView.swift
//  WallDota2
//
//  Created by QuangHo on 1/10/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct LoadingView: View {
    
    // The path for the GIF file in your project
    var body: some View {
        VStack {
            if let path = Bundle.main.path(forResource: "loading", ofType: "gif") {
                let url = URL(fileURLWithPath: path)
                
                VStack(spacing: 16) {
                    // Displaying the loading GIF
                    WebImage(url: url)
                        .resizable()
                        .indicator(.activity) // Show an activity indicator while loading
                        .scaledToFit()
                        .frame(width: UIDevice.current.userInterfaceIdiom == .pad ? 120 : 60, height: UIDevice.current.userInterfaceIdiom == .pad ? 60 : 30)
                        .clipped()
                    
                }
                .cornerRadius(12)
                .shadow(radius: 10)
            } else {
                // If the path to the GIF is invalid
                Text("Loading content failed")
                    .foregroundColor(.red)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
