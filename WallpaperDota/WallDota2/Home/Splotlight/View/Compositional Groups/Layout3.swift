//
//  Layout3.swift
//  CompositionalLayout
//
//  Created by recherst on 2021/9/7.
//

import SwiftUI
import SDWebImageSwiftUI

struct Layout3: View {
    var cards: [ImageModel]
    let tapViewDetail: (ImageModel) -> Void
    var body: some View {
        HStack(spacing: 4) {
            VStack(spacing: 4) {
                if cards.count >= 2 {
                    AnimatedImage(url: URL(string: cards[1].thumbnailFull))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: (width / 3), height: 123)
                        .cornerRadius(4)
                        .modifier(ContextModifier(card: cards[1]))
                        .onTapGesture {
                            tapViewDetail(cards[1])
                        }
                }
                if cards.count == 3 {
                    AnimatedImage(url: URL(string: cards[2].thumbnailFull))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: (width / 3), height: 123)
                        .cornerRadius(4)
                        .modifier(ContextModifier(card: cards[2]))
                        .onTapGesture {
                            tapViewDetail(cards[2])
                        }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)

            AnimatedImage(url: URL(string: cards[0].thumbnailFull))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: (width - (width / 3) + 4), height: 250)
                .cornerRadius(4)
                .modifier(ContextModifier(card: cards[0]))
                .onTapGesture {
                    tapViewDetail(cards[0])
                }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct Layout3_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
