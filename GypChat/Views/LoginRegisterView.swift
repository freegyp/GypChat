//
//  LoginRegisterView.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/23/21.
//

import SwiftUI
import ValidationComponents

struct LoginRegisterView<T>: View where T:LoginRegisterViewModelProtocol, T:ObservableObject{
    @ObservedObject var model:ViewModelMockable<T>
    @State private var loginPage:Bool = true
    
    @State private var inProgress:Bool = false
    @State private var animating:Bool = false
    
    @State private var email:String = ""
    @State private var emailWarning:String = ""
    @State private var password:String = ""
    @State private var pwdWarning:String = ""
    @State private var pwdConfirm:String = ""
    @State private var pwdConfirmWarning:String = ""
    
    
    private var loadingIndicator: some View{
        Group{
            Rectangle().fill(Color.white.opacity(0.1))
            Image(systemName: "arrow.2.circlepath")
                .font(.system(size: 30.0))
                .rotationEffect(Angle(degrees: animating ? 360 : 0.0))
                .animation(Animation.linear(duration: 2.0)
                            .repeatForever(autoreverses: false))
                .onAppear{
                    animating = true
                }
                .onDisappear{
                    animating = false
                }
        }
    }
    
    private var loginBody: some View{
        VStack{
            Group{
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .font(.title)
                Divider()
                if !emailWarning.isEmpty{
                    HStack{
                        Text(emailWarning)
                            .font(.body)
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
                SecureField("Password", text: $password)
                    .font(.title)
                    .padding([.top], 15)
                Divider()
                if !pwdWarning.isEmpty{
                    HStack{
                        Text(pwdWarning)
                            .font(.body)
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }.frame(maxWidth: 400)
            
            Button(action: {
                do{
                    emailWarning = ""
                    pwdWarning = ""
                    inProgress = true
                    try model.model.signIn(with: email, password: password, completion: {(ok,errInfo) in
                        if !ok{
                            emailWarning = errInfo
                        }
                        inProgress = false
                    })
                }catch LoginRegExceptions.invalidEmail{
                    emailWarning = "Invalid Email!"
                    inProgress = false
                }catch LoginRegExceptions.weakPassword{
                    pwdWarning = "A valid password should contain at least 6 characters!"
                    inProgress = false
                }catch{
                    emailWarning = "Uncaught Error!"
                    inProgress = false
                }
            }, label: {
                Text("Sign In")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 360, height: 50)
                    .background(Color.green)
                    .cornerRadius(20)
            }).padding([.top], 20)
            .padding([.bottom], 30)
            
            HStack(spacing: 0) {
                Text("Don't have an account? ")
                Button(action: {
                    loginPage.toggle()
                }) {
                    Text("Sign Up.").foregroundColor(.black)
                }
            }
        }
    }
    
    private var registerBody: some View{
        VStack{
            Group{
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .font(.title)
                Divider()
                if !emailWarning.isEmpty{
                    HStack{
                        Text(emailWarning)
                            .font(.body)
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
                SecureField("Password", text: $password)
                    .font(.title)
                    .padding([.top], 15)
                Divider()
                if !pwdWarning.isEmpty{
                    HStack{
                        Text(pwdWarning)
                            .font(.body)
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
                SecureField("Confirm Password", text: $pwdConfirm)
                    .font(.title)
                    .padding([.top], 15)
                Divider()
                if !pwdConfirmWarning.isEmpty{
                    HStack{
                        Text(pwdConfirmWarning)
                            .font(.body)
                            .foregroundColor(.red)
                        Spacer()
                    }
                }
            }.frame(maxWidth: 400)
            
            Button(action: {
                do{
                    emailWarning = ""
                    pwdWarning = ""
                    pwdConfirmWarning = ""
                    inProgress = true
                    try model.model.register(with: email, pwd: password, pwdConfirm: pwdConfirm, completion: {(ok,errInfo) in
                        if !ok{
                            emailWarning = errInfo
                        }
                        inProgress = false
                    })
                }catch LoginRegExceptions.invalidEmail{
                    emailWarning = "Invalid Email!"
                    inProgress = false
                }catch LoginRegExceptions.weakPassword{
                    pwdWarning = "A valid password should contain at least 6 characters!"
                    inProgress = false
                }catch LoginRegExceptions.passwordConfirmDismatch{
                    pwdConfirmWarning = "Password confirmation does not match!"
                    inProgress = false
                }catch{
                    emailWarning = "Uncaught Error!"
                    inProgress = false
                }
            }, label: {
                Text("Sign Up")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 360, height: 50)
                    .background(Color.green)
                    .cornerRadius(20)
            }).padding([.top], 20)
            .padding([.bottom], 30)
            
            HStack(spacing: 0, content: {
                Text("Have an account? ")
                Button(action: {
                    loginPage.toggle()
                }, label: {
                    Text("Sign In.").foregroundColor(.black)
                })
            })
        }
    }
    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Image(systemName: "bubble.left.and.bubble.right.fill").font(.custom("superLarge", size: 72, relativeTo: .largeTitle))
                    Text("GypChat").font(.custom("snell roundhand", size: 48))
                }.foregroundColor(.purple)
                
                VStack{
                    if loginPage{
                        loginBody
                    }else{
                        registerBody
                    }
                }.padding([.leading,.trailing], 20)
                .padding([.top], 55)
            }
            
            if inProgress{
                loadingIndicator
            }
        }
    }
}

class LoginRegisterViewModelMocked:ObservableObject, LoginRegisterViewModelProtocol{
    @Published var isLoggedIn: Bool
    
    init() {
        isLoggedIn = false
    }
    
    func signIn(with email: String, password: String, completion: ((Bool, String) -> Void)? = nil) throws {
        if !EmailValidationPredicate().evaluate(with: email){
            throw LoginRegExceptions.invalidEmail
        }
        
        if password.count < 6{
            throw LoginRegExceptions.weakPassword
        }
        
        DispatchQueue.global().async {
            sleep(3)
            DispatchQueue.main.async {
                if let completion = completion{
                    completion(false,"This user account either does not exist or has been deleted.")
                }
            }
        }
    }
    
    func register(with email: String, pwd: String, pwdConfirm: String, completion: ((Bool, String) -> Void)? = nil) throws {
        if !EmailValidationPredicate().evaluate(with: email){
            throw LoginRegExceptions.invalidEmail
        }
        
        if pwd.count < 6{
            throw LoginRegExceptions.weakPassword
        }
        
        if pwdConfirm != pwd{
            throw LoginRegExceptions.passwordConfirmDismatch
        }
        
        DispatchQueue.global().async {
            sleep(3)
            DispatchQueue.main.async {
                if let completion = completion{
                    completion(false,"This email has been used to create a user account already. Please use another email.")
                }
            }
        }
    }
}

fileprivate struct LoginRegisterViewPreview: View{
    @StateObject var model:ViewModelMockable<LoginRegisterViewModelMocked> = ViewModelMockable(LoginRegisterViewModelMocked())
    var body: some View{
        LoginRegisterViewDev(model: model)
    }
}

typealias LoginRegisterViewDev = LoginRegisterView<LoginRegisterViewModelMocked>
typealias LoginRegisterViewPub = LoginRegisterView<LoginRegisterViewModel>

struct LoginRegisterView_Previews: PreviewProvider {
    static var previews: some View {
        LoginRegisterViewPreview()
    }
}
