//
//  Test_Animation2.swift
//  WallDota2
//
//  Created by QuangHo on 20/04/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct Test_animation2:  View {
    var body: some View {
        if #available(iOS 17.0, *) {
            Image(systemName: "pencil.tip.crop.circle.fill")
                .foregroundColor(.blue)
                .symbolEffect(.variableColor.iterative.dimInactiveLayers, isActive: false)
                .symbolEffect(.scale.up)
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    Test_animation2()
}
