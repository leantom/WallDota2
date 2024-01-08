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
        Toggle(isOn: $isShowPopup, label: {
            Text(isShowPopup ? "VN" : "EN")
                .font(.caption)
        })
        .frame(width: 80)
        Toggle(isShowPopup ? "VN" : "EN", isOn: $isShowPopup)
            .toggleStyle(.switch)
            .frame(width: 80)
    }
}

#Preview {
    TestTabview()
}
