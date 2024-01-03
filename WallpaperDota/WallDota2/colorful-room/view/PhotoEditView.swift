//
//  PhotoEditView.swift
//  colorful-room
//
//  Created by macOS on 7/8/20.
//  Copyright © 2020 PingAK9. All rights reserved.
//

import SwiftUI


struct PhotoEditView: View {
    @Binding var isDissmiss: Bool
    
    @State private var showImagePicker = false
    @Binding var pickImage:UIImage?
    @EnvironmentObject var shared:PECtl
    @Environment(\.presentationMode) var presentationMode
   
    var body: some View {
        NavigationView{
            ZStack{
                Color.myBackground
                    .edgesIgnoringSafeArea(.all)
                VStack{
                    HStack{
                        Button(action:{
                            isDissmiss.toggle()
                            
                        }){
                            Text("Back")
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }
                        Spacer()
                        if(shared.previewImage != nil){
                            NavigationLink(destination: ExportView()){
                                Text("Export")
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                            }
                        } else {
                            ProgressView()
                        }
                    }
                    .zIndex(1)
                    PhotoEditorView().frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(0)
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .onAppear(perform: {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)){
                    guard let image = pickImage else {
                        return
                    }
                    PECtl.shared.setImage(image: image)
                }
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showImagePicker, onDismiss: self.loadImage){
            ZStack{
                ImagePicker(image: self.$pickImage)
            }
        }
    }
    
    
    func loadImage(){
        print("Photo edit: pick image finish")
        guard let image = self.pickImage else {
            return
        }
        self.pickImage = nil
        print("Photo edit: pick then setImage")
        self.shared.setImage(image: image)
    }
}




//struct PhotoEditView_Previews: PreviewProvider {
//    @State var isShowing: Bool = false
//    
//    static var previews: some View {
//        Group {
//            PhotoEditView(image: UIImage(named: "carem"),
//                          isDismiss: $isShowing)
//                .background(Color(UIColor.systemBackground))
//                .environment(\.colorScheme, .dark)
//                .environmentObject(PECtl.shared)
//        }
//    }
//}
