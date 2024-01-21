//
//  UIImage+Extension.swift
//  WallDota2
//
//  Created by QuangHo on 12/12/2023.
//

import Foundation
import UIKit
import SwiftUI



struct ImageWrapper: Hashable {
    let image: Image
    let id: UUID

    init(image: Image) {
        self.image = image
        self.id = UUID()
    }
}

extension ImageWrapper {
    public static func == (lhs: ImageWrapper, rhs: ImageWrapper) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

func randomColor() -> Color {
  let hue = Double.random(in: 0...360) / 360
  let saturation = Double.random(in: 0.5...1)
  let brightness = Double.random(in: 0.5...1)
  return Color(hue: hue, saturation: saturation, brightness: brightness)
}
extension Color {
    static func getPrimaryColor() -> Color {
        return Color(red: 0.068, green: 0.099, blue: 0.158)
    }
}

 
