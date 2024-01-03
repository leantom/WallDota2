//
//  ProgressBarView.swift
//  WallDota2
//
//  Created by QuangHo on 18/12/2023.
//

import SwiftUI

struct ProgressBarView: View {
    let progress: Double

      var body: some View {
        GeometryReader { geometry in
          ZStack(alignment: .leading) {
            Color.gray.opacity(0.2)
              .frame(width: geometry.size.width, height: 2)
            Color.green
              .frame(width: geometry.size.width * progress, height: 2)
          }
        }
      }
}
struct WrapperProgressBarView: View {
    @State var progress: Double = 0.1
    var body: some View {
        ProgressBarView(progress: progress)
    }
}
#Preview {
    WrapperProgressBarView()
}
