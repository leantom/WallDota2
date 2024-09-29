import SwiftUI

struct LikeView: View {
    
    // MARK:- variables
    let animationDuration: Double = 0.25
    
    @State var isAnimating: Bool = false
    @State var shrinkIcon: Bool = false
    @State var floatLike: Bool = false
    @State var showFlare: Bool = false
    var actionLike: () -> Void
    // MARK:- views
    var body: some View {
        ZStack {
            Color.clear
                .edgesIgnoringSafeArea(.all)
            ZStack {
                if (floatLike) {
                    CapusuleGroupView(isAnimating: $floatLike)
                        .offset(y: -130)
                        .scaleEffect(self.showFlare ? 1.25 : 0.8)
                        .opacity(self.floatLike ? 1 : 0)
                        .animation(Animation.spring().delay(animationDuration / 2), value: floatLike)
                }
                Circle()
                    .foregroundColor(self.isAnimating ? Color.likeColor : Color.likeOverlay)
                    .animation(Animation.easeOut(duration: animationDuration * 2).delay(animationDuration), value: isAnimating)
                HeartImageView()
                    .foregroundColor(.white)
                    .offset(y: 2)
                    .scaleEffect(self.isAnimating ? 1.25 : 1)
                    .overlay(
                        Color.likeColor
                            .mask(
                                HeartImageView()
                            )
                            .offset(y: 2)
                            .scaleEffect(self.isAnimating ? 1.35 : 0)
                            .animation(Animation.easeIn(duration: animationDuration), value: isAnimating)
                            .opacity(self.isAnimating ? 0 : 1)
                            .animation(Animation.easeIn(duration: animationDuration).delay(animationDuration), value: isAnimating)
                    )
            }.frame(width: 30, height: 30)
            .scaleEffect(self.shrinkIcon ? 0.35 : 1)
            .animation(Animation.spring(response: animationDuration, dampingFraction: 1, blendDuration: 1), value: shrinkIcon)
            if (floatLike) {
                FloatingLike(isAnimating: $floatLike)
                    .offset(y: -40)
            }
        }.onTapGesture {
            withAnimation {
                if (!floatLike) {
                    self.floatLike.toggle()
                    self.isAnimating.toggle()
                    self.shrinkIcon.toggle()
                    Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: false) { _ in
                        withAnimation {
                            self.shrinkIcon.toggle()
                            self.showFlare.toggle()
                            self.actionLike()
                        }
                    }
                } else {
                    self.isAnimating = false
                    self.shrinkIcon = false
                    self.showFlare = false
                    self.floatLike = false
                }
            }
        }
    }
}

struct LikeButton_Previews: PreviewProvider {
    static var previews: some View {
        LikeView(actionLike: {})
    }
}
