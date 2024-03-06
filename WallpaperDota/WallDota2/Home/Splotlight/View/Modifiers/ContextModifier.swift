//
//  ContextModifier.swift
//  CompositionalLayout
//
//  Created by recherst on 2021/9/7.
//

import SwiftUI

struct ContextModifier: ViewModifier {
    // ContextMenu Modifier
    var card: ImageModel

    func body(content: Content) -> some View {
        content
            .contextMenu(menuItems: {
                Text("By \(card.heroID)")
            })
            .contentShape(RoundedRectangle(cornerRadius: 5))
    }
}
