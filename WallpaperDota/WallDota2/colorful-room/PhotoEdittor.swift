//
//  ContentView.swift
//  colorful-room
//
//  Created by macOS on 7/3/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI
import UIKit
import PixelEnginePackage

struct PhotoEdittor: View {
    
    
    
    @State private var showSheet = false
    
    @State private var showImageEdit = false
    // for pick view
    @State private var pickImage: UIImage?
    // for edit view
    @State public var inputImage: UIImage?
    
    var actionBack:(() -> Void)
    
    let imageHeight:Double = 355
    
    var body: some View {
        
        NavigationStack{
            ZStack(alignment: .top){
                Color.myBackground
                    .edgesIgnoringSafeArea(.all)
                Image("intro-image")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: CGFloat(imageHeight))
                    .edgesIgnoringSafeArea(.top)
                
                GeometryReader { geo in
                    VStack(alignment: .center, spacing: 24) {
                        HStack {
                            Button(action: {
                                withAnimation {
                                    self.actionBack()
                                }
                                
                            }, label: {
                                Image(systemName: "arrow.backward")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            })
                            .frame(width: 40, height: 40)
                            .background(Color("kC6C2D8").opacity(0.8))
                            .cornerRadius(10)
                            .padding()
                            Spacer()
                        }
                        Spacer()
                        HStack{
                            Text("Create your\ncool filter")
                                .font(.system(size: 32, weight: .semibold))
                                .fontWeight(.semibold)
                                .padding(.leading, 22)
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        VStack(spacing: 24){
                            ForEach(K.introContent, id: \.["title"]){item in
                                ListTitle(
                                    title: item["title"],
                                    supTitle: item["supTitle"],
                                    leadingImage: item["leadingImage"],
                                    highlight: item["highlight"]
                                )
                            }
                        }
                        Spacer().frame(height: 0)
                        
                        ZStack{
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: UIScreen.main.bounds.width - 60, height: 52)
                                .cornerRadius(10)
                            HStack(alignment: .center, spacing: 10){
                                
                                Image("icon-photo-add")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(Color.black)
                                    .frame(width: 18, height: 18)
                                Text("CHOOSE YOUR PICTURE")
                                    .font(.headline)
                                    .foregroundColor(Color.black)
                                    
                            }
                            
                            .onTapGesture {
                                if inputImage == nil {
                                    self.showSheet = true
                                    self.showImageEdit = false
                                    self.inputImage = nil
                                    return
                                }
                                
                                self.showImageEdit = true
                            }
                        }
                       
                    }
                }
            }
            
        }
        
        .navigationDestination(isPresented: $showImageEdit) {
            PhotoEditView(isDissmiss: $showImageEdit,
                                                     pickImage: $inputImage)
            .navigationBarBackButtonHidden()
        }
        .sheet(isPresented: $showSheet, onDismiss: loadImage){
            ImagePicker(image: self.$pickImage)
        }.onAppear(perform: {
            // self.pickImage = UIImage(named: "carem")
            // self.loadImage()
            
        })
        
    }
    
    func loadImage(){
        print("loadImage: \(pickImage != nil)")
        guard self.pickImage != nil else {
            return
        }
        self.inputImage = self.pickImage
        self.showImageEdit = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PhotoEdittor(actionBack: {})
                .background(Color(UIColor.systemBackground))
                .environment(\.colorScheme, .dark)
                .environmentObject(PECtl.shared)
                .environmentObject(DataColor.shared)
        }
    }
}
