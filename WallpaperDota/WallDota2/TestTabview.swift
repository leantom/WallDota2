//
//  TestTabview.swift
//  WallDota2
//
//  Created by QuangHo on 12/12/2023.
//

import SwiftUI

struct TestTabview: View {
    @State var isShowPopup = false
    let gradient: LinearGradient = LinearGradient(
        colors: [Color.accentColor, Color.clear],
        startPoint: .bottom, endPoint: .top
    )
    var body: some View {
        ZStack {
            gradient
                .onTapGesture {
                    withAnimation {
                        isShowPopup.toggle()
                    }
                }
            VStack {
                Spacer()
                if isShowPopup {
                    VStack {
                        Text("Content")
                    }
                    .frame(height: 400)
                    .transition(.move(edge: .bottom))
                }
                
            }
        }
    }
}

#Preview {
    TestTabview()
}
