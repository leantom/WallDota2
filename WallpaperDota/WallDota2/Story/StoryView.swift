//
//  StoryView.swift
//  WallDota2
//
//  Created by QuangHo on 03/01/2024.
//

import SwiftUI
import SDWebImageSwiftUI

struct StoryView: View {
    let dismissModal: () -> Void
    @Binding var model: StoryModel
    @State var isGetDoneAPI: Bool = false
    @State private var scrollPosition: CGFloat = 0
    @State private var alphaButtonClose: CGFloat = 0.5
    
    @Binding var isVietnameseLanguage: Bool
    var body: some View {
        NavigationStack {
            ZStack {
                
                ScrollView {
                    VStack {
                        VStack {
                            // image
                            ZStack {
                                if isGetDoneAPI {
                                    AnimatedImage(url: URL(string: model.thumbnail))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .scaledToFill()
                                        .frame(height: 250)
                                        .clipped()
                                        .clipShape(
                                            .rect(
                                                topLeadingRadius: 20,
                                                bottomLeadingRadius: 0,
                                                bottomTrailingRadius: 0,
                                                topTrailingRadius: 20
                                            )
                                        )
                                } else {
                                    ProgressView()
                                }
                                
                                
                                VStack {
                                    Spacer()
                                    HStack {
                                        avatar
                                        Spacer()
                                    }
                                }
                            }
                        }
                        VStack(spacing: 10) {
                            HStack {
                                
                                Text(isVietnameseLanguage ? "The story below is purely fictional...":"Câu chuyện dưới đây hoàn toàn là hư cấu..."  )
                                    .fontWeight(.light)
                                    .font(.caption)
                                    .padding(.leading, 15)
                                
                                Spacer()
                            }
                            
                            HStack {
                                
                                Text(model.content.title)
                                    .fontWeight(.bold)
                                    .font(.title2)
                                    .padding(.leading, 15)
                                Spacer()
                            }
                            
                            VStack {
                                Text(model.content.story)
                                    .font(.caption)
                                    .fontWeight(.regular)
                                    .lineSpacing(10)
                                    .padding()
                            }
                            
                            // text and
                        }
                    }
                    .background(GeometryReader { geometry in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin)
                    })
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                       
                        self.scrollPosition = value.y
                        // alpha header view will from 1->0
                //        // also increase
                        var maxValue = CGFloat(0.8)
                        var minValue = CGFloat(0.5)
                        var offset = abs((value.y) * (maxValue - minValue))
                        var offsetAlpha = maxValue - offset / 250
                
                        let alpha = max(min(offsetAlpha, maxValue), minValue)
                        alphaButtonClose = alpha
                        print(alpha)
                    }
                }
                .coordinateSpace(name: "scroll")
                VStack {
                    HStack {
                        Button {
                            dismissModal()
                        } label: {
                            Image(systemName: "x.circle.fill")
                                .foregroundColor(.black.opacity(alphaButtonClose))
                                .font(.title)
                        }
                        Spacer()
                    }
                    Spacer()
                }.padding()
                
                VStack {
                    Spacer()
                    HStack(spacing: 10) {
                        Spacer()
                        Button(action: {
                            print("Round Action")
                        }) {
                            Image(systemName: "heart")
                                .frame(width: 35, height: 35)
                                .foregroundColor(Color.white)
                                .background(Color(red: 0.104, green: 0.082, blue: 0.243))
                                .clipShape(Circle())
                                .shadow(color: .gray, radius: 5, x: 2, y: 2)
                        }
                        Button(action: {
                            print("Round Action")
                        }) {
                            Image(systemName: "ellipsis")
                                .frame(width: 35, height: 35)
                                .foregroundColor(Color.white)
                                .background(Color(red: 0.104, green: 0.082, blue: 0.243))
                                .clipShape(Circle())
                                .shadow(color: .gray, radius: 5, x: 2, y: 2)
                        }.padding(.trailing, 15)
                        
                    }
                }
            }
            .onAppear(perform: {
                Task {
                    let firebaseData = FireStoreDatabase.shared
                    let url = await firebaseData.getURL(path: model.thumbnail)
                    if let _url = url,  _url.absoluteString.isEmpty == false {
                        model.thumbnail = url?.absoluteString ?? ""
                    }
                    isGetDoneAPI = true
                }
            })
        }
    }
    
    var avatar: some View {
        VStack(alignment: .leading) {
            HStack {
                AsyncImage(
                  url: URL(
                      string: "https://picsum.photos/100")) { image in
                    image
                        .resizable()
                        .frame(width: 35,
                                height: 35,
                                alignment: .center)
                        .clipShape(Circle())
                        .overlay {
                            Circle().stroke(.blue, lineWidth: 2)
                        }
                } placeholder: {
                    ProgressView()
                }
                .aspectRatio(3 / 2, contentMode: .fill)
                .shadow(radius: 4)
                .padding(.trailing, 18)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Anynomous")
                        .foregroundColor(.white)
                        .bold()
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
        }
    }
    
    
}

struct WrappedStoryView: View {
    @State var model = StoryModel()
    @State var islanguage: Bool = true
    var body: some View {
        StoryView(dismissModal: {}, model: $model, isVietnameseLanguage: $islanguage)
    }
}

#Preview {
    WrappedStoryView()
}
