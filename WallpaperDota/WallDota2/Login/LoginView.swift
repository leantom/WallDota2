//
//  LoginView.swift
//  WallDota2
//
//  Created by QuangHo on 12/12/2023.
//

import SwiftUI
import AuthenticationServices
import FirebaseAuth
import CryptoKit

class AppleSignInHandler: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    var currentNonce: String = ""
    var actionLoginSuccessfully:(()->Void)?
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
         // Return the first window in the current window scene as the presentation anchor for the ASAuthorizationController
         return UIApplication.shared.connectedScenes
             .first { $0.activationState == .foregroundActive }
             .map { $0 as? UIWindowScene }
             .flatMap { $0?.windows.first } ?? UIApplication.shared.windows.first!
     }


   
    static func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    static func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // Apple Sign In was successful.
            // You can now use the `appleIDCredential` to authenticate the user in your app.
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            
            // Initialize a Firebase credential, including the user's full name.
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                           rawNonce: self.currentNonce,
                                                           fullName: appleIDCredential.fullName)
            // Exchange Apple ID token for Firebase credential
            Auth.auth().signIn(with: credential) { [self] (authResult, error) in
                if let err = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(err.localizedDescription)
                    return
                }
                // User is signed in to Firebase with Apple.
                // ...
                
                if let result = authResult {
                    Task {
                        await LoginViewModel.shared.createUser(user: result.user, provider: "apple")
                        if let actionLoginSuccessfully = actionLoginSuccessfully {
                            actionLoginSuccessfully()
                        }
                        AppSetting.setLogined(value: true)
                    }
                    
                }
                
            }
        
//             print("Apple Sign In was successful. User's full name is: \(userFullName)")
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Apple Sign In failed.
        // You can handle the error here.
        print("Apple Sign In failed with error: \(error.localizedDescription)")
    }
}

struct LoginView: View {
    
    let backgroundImage = Image("image4")
    let gradient: LinearGradient = LinearGradient(
        colors: [Color.black.opacity(0.7), Color.clear],
        startPoint: .bottom, endPoint: .top
    )
    var loginViewModel = LoginViewModel.shared
    @State var email: String = "Continue with Email"
    @State var emailIcon: String = "mail.fill"
    @State var googleLoginTitle: String = "Continue with Google"
    @State var googleIcon: String = "g.square"
    @State var appleLoginTitle: String = "Continue with Apple"
    @State var appleIcon: String = "apple.logo"
    
    @State private var showSignInWithAppleSheet = false
    @State private var isLogined = false
    @State var currentNonce: String = ""
    
    let appleSignInHandler = AppleSignInHandler()
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                backgroundImage
                                    .resizable()
                                    .scaledToFill()
                                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer(minLength: 160)
                    VStack(spacing: 20,content: {
                        Image(uiImage: UIImage(named: "AppIcon") ?? UIImage())
                            .resizable()
                            .frame(width: 68, height: 68)
                            .cornerRadius(10)
                        Text("Because your view deserves to be epic.")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    })
                    VStack(spacing: 40) {
                        Spacer()
                        VStack(spacing: 24) {
//                            ShareCodeButton(title: $email, icon: $emailIcon, action: {
//                                
//                            })
//                                .background(Color(red: 0.324, green: 0.448, blue: 0.7))
//                                .cornerRadius(10)
                            
                            ShareCodeButton(title: $googleLoginTitle, icon: $googleIcon, action: {
                                Task {
                                    isLogined = await loginViewModel.signInWithGoogle()
                                }
                                
                            })
                                .background(Color(red: 0.167, green: 0.246, blue: 0.386))
                                .cornerRadius(10)
                            
                            ShareCodeButton(title: $appleLoginTitle, icon: $appleIcon, action: {
                                let nonce = AppleSignInHandler.randomNonceString()
                                currentNonce = nonce
                                appleSignInHandler.currentNonce = currentNonce
                                let appleIDProvider = ASAuthorizationAppleIDProvider()
                                let request = appleIDProvider.createRequest()
                                request.nonce = AppleSignInHandler.sha256(nonce)
                                request.requestedScopes = [.fullName, .email]
                                
                                let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                                authorizationController.delegate = appleSignInHandler
                                authorizationController.presentationContextProvider = appleSignInHandler
                                authorizationController.performRequests()
                                
                                appleSignInHandler.actionLoginSuccessfully = {
                                    isLogined = true
                                }
                            })
                            .background(Color(hue: 0.607, saturation: 0.601, brightness: 0.159))
                            .cornerRadius(10)
                        }
                        
                        HStack(spacing: 0) {
                            
                            Button(action: {
                                // MARK: --skip
                                Task {
                                    await loginViewModel.signinWithAnynomous()
                                    isLogined = true
                                }
                                
                            }, label: {
                                Text("Skip")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            })
                            .padding()
                            .frame(height: 48)
                            .background(
                              RoundedRectangle(cornerRadius: 10)
                                .fill(.accent)
                                .shadow(color: .black, radius: 5) // Shadow applied to background shape
                            )
                           
                            
                        }
                        Spacer()
                    }
                    
                    
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
