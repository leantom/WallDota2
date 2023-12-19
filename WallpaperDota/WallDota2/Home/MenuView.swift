//
//  MenuView.swift
//  WallDota2
//
//  Created by QuangHo on 18/12/2023.
//

import SwiftUI

struct SideMenu: View {
    @Binding var isSidebarVisible: Bool
    var sideBarWidth = UIScreen.main.bounds.size.width * 0.8
    var bgColor: Color =
          Color(.init(
                  red: 52 / 255,
                  green: 70 / 255,
                  blue: 182 / 255,
                  alpha: 1))
    
    let gradient: LinearGradient = LinearGradient(
        colors: [Color("k886BF6"), Color("k625AF6")],
        startPoint: .top, endPoint: .bottom
    )

    var MenuChevron: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color("k886BF6"))
                .frame(width: 60, height: 60)
                .rotationEffect(Angle(degrees: 45))
                .offset(x: isSidebarVisible ? -18 : -10)
                .onTapGesture {
                    isSidebarVisible.toggle()
                }

            Image(systemName: "chevron.right")
                .foregroundColor(.white)
                .rotationEffect(
                  isSidebarVisible ?
                    Angle(degrees: 180) : Angle(degrees: 0))
                .offset(x: isSidebarVisible ? -4 : 8)
                .foregroundColor(Color("k886BF6"))
        }
        .offset(x: sideBarWidth / 2, y: 80)
        .animation(.default, value: isSidebarVisible)
    }
    
    var body: some View {
        HStack(alignment: .top) {
            ZStack(alignment: .top) {
                gradient
                MenuChevron
                
                VStack(alignment: .leading, spacing: 20) {
                    userProfile
                    Divider()
                    MenuLinks(items: userActions)
                    Divider().background(.clear)
                    
                    MenuLinks(items: logout)
                }
                .padding(.top, 80)
                .padding(.horizontal, 20)
            }
            .frame(width: sideBarWidth)
            .offset(x: isSidebarVisible ? 0 : -sideBarWidth)
            .animation(.default, value: isSidebarVisible)
            
            Spacer()
        }.ignoresSafeArea()
    }

    var content: some View {
        HStack(alignment: .top) {
            ZStack(alignment: .top) {
                bgColor
            }
            .frame(width: sideBarWidth)
            .offset(x: isSidebarVisible ? 0 : -sideBarWidth)
            .animation(.default, value: isSidebarVisible)
            Spacer()
        }
    }
    
    var userProfile: some View {
            VStack(alignment: .leading) {
                HStack {
                    AsyncImage(
                      url: URL(
                          string: "https://picsum.photos/100")) { image in
                        image
                            .resizable()
                            .frame(width: 50,
                                    height: 50,
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
                        Text("John Doe")
                            .foregroundColor(.white)
                            .bold()
                            .font(.title3)
                        
                    }
                }
                .padding(.bottom, 20)
            }
        }
    
}

var secondaryColor: Color =
              Color(.init(
                red: 100 / 255,
                green: 174 / 255,
                blue: 255 / 255,
                alpha: 1))

struct MenuLinks: View {
    var items: [MenuItem]
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            ForEach(items) { item in
                menuLink(icon: item.icon, text: item.text)
            }
        }
        .padding(.vertical, 14)
        .padding(.leading, 8)
    }
}


struct menuLink: View {
    var icon: String
    var text: String
    var body: some View {
        HStack {
            Image(systemName: icon)
                .resizable()
                .frame(width: 20, height: 20)
                .font(.title2)
                .foregroundColor(.white)
                .padding(.trailing, 10)
            Text(text)
                .foregroundColor(.white)
                .font(.body)
                .fontWeight(.semibold)
        }
        .onTapGesture {
            print("Tapped on \(text)")
        }
    }
}


struct MenuItem: Identifiable {
    var id: Int
    var icon: String
    var text: String
}

var userActions: [MenuItem] = [
    MenuItem(id: 4001, icon: "person.circle.fill", text: "Home"),
    MenuItem(id: 4002, icon: "bag.fill", text: "Favorites"),
    MenuItem(id: 4003, icon: "gift.fill", text: "Downloaded"),
    MenuItem(id: 4004,
              icon: "wrench.and.screwdriver.fill",
              text: "Settings"),
    MenuItem(id: 4005,
              icon: "exclamationmark.triangle.fill",
              text: "Reportn an issue")
]

var logout: [MenuItem] = [
    
    MenuItem(id: 4006,
              icon: "iphone.and.arrow.forward",
              text: "Logout"),
]



struct WrapperMenuView: View {
    @State var isShowing: Bool = true
    var body: some View {
        SideMenu(isSidebarVisible: $isShowing)
    }
}

#Preview {
    WrapperMenuView()
}
