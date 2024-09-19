//
//  Test_Animation1.swift
//  WallDota2
//
//  Created by QuangHo on 20/04/2024.
//

import SwiftUI

struct Test_Animation1: View {
    @State var isShow = false
    var body: some View {
        NavigationStack{
            ZStack {
                if isShow {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.red.gradient)
                        .transition(.reserveflip)
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.blue.gradient)
                        .transition(.flip)
                }
            }.frame(width: 200, height: 300)
            
            Button {
                withAnimation(.bouncy(duration: 3)) {
                    isShow.toggle()
                }
                
            } label: {
                Text("Change")
            }
            
        }
        .navigationTitle("Flip Transition")
    }
}

#Preview {
    Test_Animation1()
}

struct FlipTransition: ViewModifier {
    var progress = 0
    func body(content: Content) -> some View {
        content.rotation3DEffect(
            .init(degrees: Double(progress * 180)),
            axis: (x: 0.0, y: 1.0, z: 0.0)
        )
        .rotationEffect(.degrees(Double(progress * 180)))
    }
}
extension AnyTransition {
    static let flip: AnyTransition = .modifier(active: FlipTransition(progress: 1), identity: FlipTransition())
    static let reserveflip: AnyTransition = .modifier(active: FlipTransition(progress: -1), identity: FlipTransition())
}
