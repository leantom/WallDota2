//
//  ShowToast.swift
//  WallDota2
//
//  Created by QuangHo on 18/12/2023.
//

import SwiftUI

struct ToastView: View {
  let message: String
  @Binding var isVisible: Bool

  var body: some View {
    if isVisible {
      Text(message)
            .font(.caption)
        .padding()
        .foregroundColor(.white)
        .background(Color.blue.opacity(0.7))
        .cornerRadius(10)
        .fixedSize(horizontal: false, vertical: true)
        .transition(.opacity)
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isVisible = false
          }
        }.frame(height: 48)
    } else {
      EmptyView()
    }
  }
}

struct WrapperToastView: View {
  @State private var toastIsVisible = false

  var body: some View {
    VStack {
      Button("Show Toast") {
        toastIsVisible = true
      }
      ToastView(message: "This is a toast notification!", isVisible: $toastIsVisible)
    }
  }
}
#Preview {
    WrapperToastView()
}
