//
//  UserProfileView.swift
//  WallDota2
//
//  Created by QuangHo on 20/12/2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserProfileView: View {
    
    let columns = [GridItem(.flexible(minimum: 50, maximum: 160)), GridItem(.flexible(minimum: 50, maximum: 160)), GridItem(.flexible(minimum: 50, maximum: 160))]
    let gradient: LinearGradient = LinearGradient(
        colors: [Color.black.opacity(0.2), Color.black.opacity(0.1)],
        startPoint: .bottom, endPoint: .top
    )
    @Binding var _firestoreDB:FireStoreDatabase
    @State var listCollectionModel:[ImageModel] = []
    let alertTitle = "Enter your name"
    let alertMessage = "Please provide your name to proceed."
    let textFieldClosure: (String) -> Void = { enteredName in
      // Handle the entered name here
      print("Entered name: \(enteredName)")
    }
    @State var isShowingAlert = false
    @State var username = ""
    
    
    var body: some View {
        VStack {
            VStack {
                Image("avatarapp").resizable()
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(50)
            }
            
            VStack {
                HStack {
                    Text("Anonymous").font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Button {
                        self.isShowingAlert.toggle()
                    } label: {
                        Image(systemName: "pencil.line")
                            .font(.title3)
                            .fontWeight(.regular)
                            .foregroundColor(.black)
                    }.alert(alertTitle, isPresented: $isShowingAlert, actions: {
                        // Any view other than Button would be ignored
                        TextField("Username", text: .constant(""))
                        Button("OK", action: {
                            // MARK: -- update username
                        })
                        Button("Cancel", role: .cancel, action: {})
                    }, message: {
                        // Any view other than Text would be ignored
                        Text("Please enter your username")
                    })

                    
                        
                }
            }
            HStack {
                
                Text("Liked").font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                Spacer()
            }.padding()
            ScrollView {
                like
            }
            
        }
    }
    
    func authenticate() {
        
    }
    
    @State var isgetFullThumnailFull = false
    
    var like: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(listCollectionModel, id: \.id) {item in
                HStack {
                    ZStack {
                        VStack {
                            if isgetFullThumnailFull {
                                WebImage(url: URL(string: item.thumbnailFull))
                                    .resizable()
                                    .placeholder {
                                        ProgressView()
                                    }
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(10)
                            } else {
                                ProgressView()
                            }
                        }
                        gradient
                        
                    }
                    .clipped()
                    
                }
                    .cornerRadius(10)
                    .clipped()
                    .onTapGesture {
                        print(item.heroID)
                        //self.action(item.heroID)
                    }
            }
        }
        .padding()
        .onAppear(perform: {
            self.listCollectionModel = _firestoreDB.listImageLiked
            Task {
                for item in listCollectionModel {
                    if item.thumbnailFull.isEmpty {
                        if let thumbnail = await _firestoreDB.getURL(path: item.thumbnail) {
                            item.thumbnailFull = thumbnail.absoluteString
                        }
                        print(item.thumbnail + " thumbnail")
                    }
                    
                }
                
                isgetFullThumnailFull = true
            }
            
        })
        .refreshable {
            await _firestoreDB.fetchDataFromFirestore()
            self.listCollectionModel = _firestoreDB.getImages(by: "cute")
        }
    }
}

