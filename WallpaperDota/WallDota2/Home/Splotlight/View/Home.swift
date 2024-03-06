//
//  Home.swift
//  CompositionalLayout
//
//  Created by recherst on 2021/9/7.
//

import SwiftUI

class JSONViewModel: ObservableObject {
    @Published var cards: [ImageModel] = []

    @Published var search = ""

    // Compositional layout array
    @Published var compositionalArray: [[ImageModel]] = []

    init(images: [ImageModel]) {
        setCompositionalLayout(images: images)
    }

    func setCompositionalLayout(images: [ImageModel]) {
        var currentArrayCards: [ImageModel] = []
        images.forEach { card in
            currentArrayCards.append(card)

            if currentArrayCards.count == 3 {
                // Append to main array
                compositionalArray.append(currentArrayCards)
                currentArrayCards.removeAll()
            }

            // If not 3 or even no of cards
            if currentArrayCards.count != 3 && card.id == images.last!.id {
                // Append to main array
                compositionalArray.append(currentArrayCards)
                currentArrayCards.removeAll()
            }
        }
    }
}
