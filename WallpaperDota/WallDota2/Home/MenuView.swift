//
//  MenuView.swift
//  WallDota2
//
//  Created by QuangHo on 18/12/2023.
//

import SwiftUI

struct SideMenu: View {
    @Binding var isSidebarVisible: Bool
    @State var isDeleteAccount: Bool = false
    
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
    var actionChooseProfileUser: ((Int)->Void)
    var actionChooseCollection: ((Int)->Void)
    var actionChooseHome: ((Int)->Void)
    var actionLogout: ((Int)->Void)
    var actionDeleteAccount: (()->Void)
    @Binding var userLogin: NewUser?
    @State var username: String = "Anynomous"
    
    var MenuChevron: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(gradient)
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

        }
        .offset(x: sideBarWidth / 2, y: 50)
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
                    MenuLinks(actionTapMenu: {id in
                        print(id)
                        switch id {
                        case 4001:
                            isSidebarVisible.toggle()
                            self.actionChooseHome(1)
                        case 4002:
                            isSidebarVisible.toggle()
                            self.actionChooseProfileUser(3)
                        case 4003:
                            isSidebarVisible.toggle()
                            self.actionChooseCollection(2)
                        case 4004:
                            isSidebarVisible.toggle()
                            actionDeleteAccount()
                        
                        default:return
                        }
                    }, items: userActions)
                    
                    Divider().background(.clear)
                    
                    MenuLinks(actionTapMenu: { id in
                        isSidebarVisible.toggle()
                        self.actionLogout(4)
                    }, items: logout)
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
                        Text(username)
                            .foregroundColor(.white)
                            .bold()
                            .font(.caption)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.bottom, 20)
            }
            .onAppear(perform: {
                
                Task {
                    sleep(2)
                    userLogin = await LoginViewModel.shared.getUserDetail()
                    username = userLogin?.username ?? ""
                }
                
            })
        }
    
}

var secondaryColor: Color =
              Color(.init(
                red: 100 / 255,
                green: 174 / 255,
                blue: 255 / 255,
                alpha: 1))

struct MenuLinks: View {
    var actionTapMenu:((Int)-> Void)
    var items: [MenuItem]
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            ForEach(items) { item in
                menuLink(icon: item.icon, text: item.text)
                    .onTapGesture {
                        self.actionTapMenu(item.id)
                    }
                    
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
    }
}


struct MenuItem: Identifiable {
    var id: Int
    var icon: String
    var text: String
}

var userActions: [MenuItem] = [
    MenuItem(id: 4001, icon: "person.circle.fill", text: "Home"),
    MenuItem(id: 4002, icon: "bag.fill", text: "Liked"),
    MenuItem(id: 4003, icon: "gift.fill", text: "Collections"),
    MenuItem(id: 4004,
              icon: "wrench.and.screwdriver.fill",
              text: "Delete Account")
//    MenuItem(id: 4005,
//              icon: "exclamationmark.triangle.fill",
//              text: "Report an issue")
]

var logout: [MenuItem] = [
    
    MenuItem(id: 4006,
              icon: "iphone.and.arrow.forward",
              text: "Logout"),
    
]

struct WrapperMenuView: View {
    @State var isShowing: Bool = true
    @State var user: NewUser? = NewUser(username: "Anynomous", email: "gam@g.lcom", providers: "none", created_at: 0, last_login_at: 0, userid: UUID().uuidString)
    var body: some View {
        SideMenu(isSidebarVisible: $isShowing, actionChooseProfileUser: {_ in }, actionChooseCollection: {_ in }, actionChooseHome: {_ in }, actionLogout: {_ in}, actionDeleteAccount: {}, userLogin: $user)
    }
}

#Preview {
    WrapperMenuView()
}
