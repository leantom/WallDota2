//
//  LoginView.swift
//  WallDota2
//
//  Created by QuangHo on 12/12/2023.
//

import SwiftUI
import AuthenticationServices

class AppleSignInHandler: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
         // Return the first window in the current window scene as the presentation anchor for the ASAuthorizationController
         return UIApplication.shared.connectedScenes
             .first { $0.activationState == .foregroundActive }
             .map { $0 as? UIWindowScene }
             .flatMap { $0?.windows.first } ?? UIApplication.shared.windows.first!
     }


    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Apple Sign In was successful.
            // You can now use the `appleIDCredential` to authenticate the user in your app.
            let userFullName = appleIDCredential
            print("Apple Sign In was successful. User's full name is: \(userFullName)")
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Apple Sign In failed.
        // You can handle the error here.
        print("Apple Sign In failed with error: \(error.localizedDescription)")
    }
}

struct LoginView: View {
    
    let backgroundImage = Image("image3")
    let gradient: LinearGradient = LinearGradient(
        colors: [Color.black.opacity(0.4), Color.clear],
        startPoint: .bottom, endPoint: .top
    )
    var loginViewModel = LoginViewModel()
    @State var email: String = "Continue with Email"
    @State var emailIcon: String = "mail.fill"
    @State var googleLoginTitle: String = "Continue with Google"
    @State var googleIcon: String = "g.square"
    @State var appleLoginTitle: String = "Continue with Apple"
    @State var appleIcon: String = "apple.logo"
    
    @State private var showSignInWithAppleSheet = false
    @State private var isLogined = false
    
    let appleSignInHandler = AppleSignInHandler()
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                backgroundImage
                                    .resizable()
                                    .scaledToFill()
                                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    VStack(spacing: 20,content: {
                        Image("logo-no-background")
                            .resizable()
                            .frame(width: 100, height: 100)
                        Text("Because your view deserves to be epic.")
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    })
                    
                    VStack(spacing: 24) {
                        ShareCodeButton(title: $email, icon: $emailIcon, action: {
                            
                        })
                            .background(Color(red: 0.324, green: 0.448, blue: 0.7))
                            .cornerRadius(10)
                        ShareCodeButton(title: $googleLoginTitle, icon: $googleIcon, action: {
                            Task {
                                isLogined = await loginViewModel.signInWithGoogle()
                            }
                            
                        })
                            .background(Color(red: 0.167, green: 0.246, blue: 0.386))
                            .cornerRadius(10)
                        
                        ShareCodeButton(title: $appleLoginTitle, icon: $appleIcon, action: {
                            let appleIDProvider = ASAuthorizationAppleIDProvider()
                            let request = appleIDProvider.createRequest()
                            request.requestedScopes = [.fullName, .email]
                            
                            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                            authorizationController.delegate = appleSignInHandler
                            authorizationController.presentationContextProvider = appleSignInHandler
                            authorizationController.performRequests()
                        })
                        .background(Color(hue: 0.607, saturation: 0.601, brightness: 0.159))
                        .cornerRadius(10)
                    }
                    
                    HStack(spacing: 0) {
                        
                        Button(action: {
                            // MARK: --skip
                            isLogined = true
                        }, label: {
                            Text(isLogined ? "Skip" : "Next")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        })
                        .padding()
                    }
                    
                    Spacer()
                }
                
                if isLogined {
                    TabbarCustomView()
                        .frame(width: UIScreen.main.bounds.width)
                        .navigationBarBackButtonHidden()
                        .background(.white)
                }
            }
        }.navigationDestination(isPresented: $isLogined) {
            TabbarCustomView().navigationBarBackButtonHidden()
        }
        
    }
}


struct ShareCodeButton: View {
    @Binding var title: String
    @Binding var icon: String
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
           
        })
        .frame(height: 48)
        .padding(.horizontal, 40)
        .foregroundColor(.white)
        .modifier(ScreenWidthModifier())
    }
}

struct ScreenWidthModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.frame(maxWidth: UIScreen.main.bounds.width - 80)
    }
}

#Preview {
    LoginView()
}
