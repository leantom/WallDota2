import SwiftUI
import UIKit
import SDWebImageSwiftUI

struct WrapperImageModifierView: View {
    
    let gradient: LinearGradient = LinearGradient(
        colors: [Color.blue.opacity(0.2), Color.clear],
        startPoint: .top, endPoint: .bottom
    )
    @Binding var model: ImageModel
    let dismissModal: () -> Void
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                gradient.ignoresSafeArea()
                
                WebImage(url: URL(string: model.imageUrlFull))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .ignoresSafeArea()
                    .modifier(ImageModifier(contentSize: CGSize(width: proxy.size.width, height: proxy.size.height)))
                
                VStack {
                    HStack {
                        
                        Button(action: {
                            withAnimation {
                                dismissModal()
                            }
                            
                        }, label: {
                            Image(systemName: "arrow.backward")
                                .foregroundColor(.white)
                                .font(.title2)
                        })
                        .frame(width: 40, height: 40)
                        .background(Color("kC6C2D8").opacity(0.8))
                        .cornerRadius(10)
                        Spacer()
                    }.padding()
                    Spacer()
                }
            }
            
        }
    }
}

struct ImageModifier: ViewModifier {
    private var contentSize: CGSize
    private var min: CGFloat = 1.0
    private var max: CGFloat = 2.0
    @State var currentScale: CGFloat = 1.0

    init(contentSize: CGSize) {
        self.contentSize = contentSize
    }
    
    var doubleTapGesture: some Gesture {
        TapGesture(count: 2).onEnded {
            if currentScale <= min { currentScale = max } else
            if currentScale >= max { currentScale = min } else {
                currentScale = ((max - min) * 0.5 + min) < currentScale ? max : min
            }
        }
    }
    
    func body(content: Content) -> some View {
        ScrollView([.horizontal, .vertical]) {
            content
                .frame(width: contentSize.width * currentScale, height: contentSize.height * currentScale, alignment: .center)
                .modifier(PinchToZoom(minScale: min, maxScale: max, scale: $currentScale))
        }
        .gesture(doubleTapGesture)
        .animation(.easeInOut, value: currentScale)
    }
}

class PinchZoomView: UIView {
    let minScale: CGFloat
    let maxScale: CGFloat
    var isPinching: Bool = false
    var scale: CGFloat = 1.0
    let scaleChange: (CGFloat) -> Void
    
    init(minScale: CGFloat,
           maxScale: CGFloat,
         currentScale: CGFloat,
         scaleChange: @escaping (CGFloat) -> Void) {
        self.minScale = minScale
        self.maxScale = maxScale
        self.scale = currentScale
        self.scaleChange = scaleChange
        super.init(frame: .zero)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
        pinchGesture.cancelsTouchesInView = false
        addGestureRecognizer(pinchGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func pinch(gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            isPinching = true
            
        case .changed, .ended:
            if gesture.scale <= minScale {
                scale = minScale
            } else if gesture.scale >= maxScale {
                scale = maxScale
            } else {
                scale = gesture.scale
            }
            scaleChange(scale)
        case .cancelled, .failed:
            isPinching = false
            scale = 1.0
        default:
            break
        }
    }
}

struct PinchZoom: UIViewRepresentable {
    let minScale: CGFloat
    let maxScale: CGFloat
    @Binding var scale: CGFloat
    @Binding var isPinching: Bool
    
    func makeUIView(context: Context) -> PinchZoomView {
        let pinchZoomView = PinchZoomView(minScale: minScale, maxScale: maxScale, currentScale: scale, scaleChange: { scale = $0 })
        return pinchZoomView
    }
    
    func updateUIView(_ pageControl: PinchZoomView, context: Context) { }
}

struct PinchToZoom: ViewModifier {
    let minScale: CGFloat
    let maxScale: CGFloat
    @Binding var scale: CGFloat
    @State var anchor: UnitPoint = .center
    @State var isPinching: Bool = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale, anchor: anchor)
            .animation(.spring(), value: isPinching)
            .overlay(PinchZoom(minScale: minScale, maxScale: maxScale, scale: $scale, isPinching: $isPinching))
    }
}
