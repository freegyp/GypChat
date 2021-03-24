//
//  MainProfileView.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/24/21.
//

import SwiftUI
import ValidationComponents
import FirebaseStorage
import Firebase

struct MainProfileView<T>: View where T:MainProfileViewModelProtocol, T:ObservableObject{
    @ObservedObject var model:ViewModelMockable<T>
    
    @State private var newEmail:String = ""
    @State private var newEmailWarning:String = ""
    @State private var newPassword:String = ""
    @State private var newPasswordWarning:String = ""
    @State private var newPwdConfirm:String = ""
    @State private var newPwdConfirmWarning:String = ""
    @State private var newName:String = ""
    @State private var newNameWarning:String = ""
    
    @State private var showChangeEmail:Bool = false
    @State private var showChangePassword:Bool = false
    @State private var showChangeName:Bool = false
    @State private var showChangeProfilePhoto:Bool = false
    
    @State private var showChangeProfilePhotoAlert:Bool = false
    @State private var changeProfilePhotoAlertMessage:String = ""
    
    @State private var inProgress:Bool = false
    @State private var animating:Bool = false
    
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
    
    var changeNameButton: some View{
        Button(action: {
            newName = ""
            newNameWarning = ""
            showChangeName = true
        }, label: {
            Text("Change Name")
                .font(.title)
                .foregroundColor(.black)
                .padding([.top,.bottom], 15)
        }).sheet(isPresented: $showChangeName){
            ZStack{
                NavigationView{
                    Form{
                        VStack{
                            TextField("New Name", text: $newName)
                            if !newNameWarning.isEmpty{
                                Text(newNameWarning)
                                    .font(.footnote)
                                    .foregroundColor(.red)
                            }
                        }
                    }.navigationTitle("Change Name")
                    .navigationBarItems(leading: Button("Cancel", action: {
                        showChangeName = false
                    }), trailing: Button("Submit", action: {
                        inProgress = true
                        model.model.updateProfile(newName: newName, newPhotoUrl: nil, completion: {(ok,errInfo) in
                            if !ok{
                                newNameWarning = errInfo
                            }else{
                                showChangeName = false
                            }
                            inProgress = false
                        })
                    }))
                }
                if inProgress{
                    loadingIndicator
                }
            }
        }
    }
    
    var changeProfilePhotoButton: some View{
        Button(action: {
            showChangeProfilePhoto = true
        }, label: {
            Text("Change Profile Photo")
                .font(.title)
                .foregroundColor(.black)
                .padding([.top,.bottom], 15)
        }).fullScreenCover(isPresented: $showChangeProfilePhoto, content: {
            ImagePicker(equalRatio: true, handler: {img in
                if let _img = img,let data = _img.jpegData(compressionQuality: 1.0){
                    let storageRef = Storage.storage().reference()
                    
                    let ref = storageRef.child("profile_photos/\(Auth.auth().currentUser!.uid).jpg")
                    
                    inProgress = true
                    let dataTask = ref.putData(data, metadata: nil, completion: {(metadata,err) in
                        if let err = err{
                            changeProfilePhotoAlertMessage = err.localizedDescription
                            showChangeProfilePhotoAlert = true
                            inProgress = false
                        }else{
                            let url = URL(string: "gs://\(ref.bucket)/\(ref.fullPath)")
                            
                            model.model.updateProfile(newName: nil, newPhotoUrl: url, completion: {(ok,errInfo) in
                                if !ok{
                                    changeProfilePhotoAlertMessage = errInfo
                                    showChangeProfilePhotoAlert = true
                                }
                                inProgress = false
                            })
                        }
                    })
                    
                    dataTask.resume()
                }
                
                showChangeProfilePhoto = false
            })
        }).alert(isPresented: $showChangeProfilePhotoAlert, content: {
            Alert(title: Text("Image Upload Failed."), message: Text(changeProfilePhotoAlertMessage), dismissButton: .default(Text("Ok.")))
        })
    }
    
    var changeEmailButton: some View{
        Button(action: {
            newEmail = ""
            newEmailWarning = ""
            showChangeEmail = true
        }, label: {
            Text("Change Email")
                .font(.title)
                .foregroundColor(.black)
                .padding([.top,.bottom], 15)
                .keyboardType(.emailAddress)
        }).sheet(isPresented: $showChangeEmail, content: {
            ZStack{
                NavigationView{
                    Form{
                        VStack{
                            TextField("New Email", text: $newEmail)
                            if !newEmailWarning.isEmpty{
                                Text(newEmailWarning)
                                    .font(.footnote)
                                    .foregroundColor(.red)
                            }
                        }
                    }.navigationTitle("Change Email")
                    .navigationBarItems(leading: Button("Cancel", action: {
                        showChangeEmail = false
                    }), trailing: Button("Submit", action: {
                        inProgress = true
                        do{
                            try model.model.updateEmail(newEmail, completion: {(ok,errInfo) in
                                if !ok{
                                    newEmailWarning = errInfo
                                }else{
                                    showChangeEmail = false
                                }
                                inProgress = false
                            })
                        }catch LoginRegExceptions.invalidEmail{
                            newEmailWarning = "Invalid Email!"
                            inProgress = false
                        }catch{
                            newEmailWarning = "Uncaught Error!"
                            inProgress = false
                        }
                    }))
                }
                if inProgress{
                    loadingIndicator
                }
            }
        })
    }
    
    var changePasswordButton: some View{
        Button(action: {
            newPassword = ""
            newPasswordWarning = ""
            newPwdConfirm = ""
            newPwdConfirmWarning = ""
            showChangePassword = true
        }, label: {
            Text("Change Password")
                .font(.title)
                .foregroundColor(.black)
                .padding([.top,.bottom], 15)
        }).sheet(isPresented: $showChangePassword, content: {
            ZStack{
                NavigationView{
                    Form{
                        VStack{
                            SecureField("New Password", text: $newPassword)
                            if !newPasswordWarning.isEmpty{
                                Text(newPasswordWarning)
                                    .font(.footnote)
                                    .foregroundColor(.red)
                            }
                        }
                        VStack{
                            SecureField("Confirm Password", text: $newPwdConfirm)
                            if !newPwdConfirmWarning.isEmpty{
                                Text(newPwdConfirmWarning)
                                    .font(.footnote)
                                    .foregroundColor(.red)
                            }
                        }
                    }.navigationTitle("Change Password")
                    .navigationBarItems(leading: Button("Cancel", action: {
                        showChangePassword = false
                    }), trailing: Button("Submit", action: {
                        inProgress = true
                        do{
                            try model.model.updatePassword(newPassword, newPwdConfirm, completion: {(ok,errInfo) in
                                if !ok{
                                    newPasswordWarning = errInfo
                                }else{
                                    showChangePassword = false
                                }
                                inProgress = false
                            })
                        }catch LoginRegExceptions.weakPassword{
                            newPasswordWarning = "A valid password should contain at least 6 characters!"
                            inProgress = false
                        }catch LoginRegExceptions.passwordConfirmDismatch{
                            newPwdConfirmWarning = "Password confirmation does not match!"
                            inProgress = false
                        }catch{
                            newPasswordWarning = "Uncaught Error!"
                            inProgress = false
                        }
                    }))
                }
                if inProgress{
                    loadingIndicator
                }
            }
        })
    }
    
    var signOutButton: some View{
        Button(action: {
            model.model.signOut()
        }, label: {
            Text("Sign Out")
                .font(.title)
                .foregroundColor(.red)
                .padding([.top,.bottom], 15)
        })
    }
    
    var body: some View {
        ZStack{
            Form{
                Section{
                    HStack{
                        Image(uiImage: model.model.profilePhoto)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 72)
                            .cornerRadius(36)
                            
                        VStack{
                            Text(model.model.dispName)
                                .font(.largeTitle)
                            Text(model.model.email)
                                .font(.title3)
                        }
                    }.padding([.top,.bottom,.leading], 15)
                }
                
                Section{
                    changeNameButton
                    
                    changeProfilePhotoButton
                    
                    changeEmailButton
                    
                    changePasswordButton
                }
                
                Section{
                    signOutButton
                }
            }
            
            if inProgress{
                loadingIndicator
            }
        }
    }
}

class MainProfileViewModelMocked:ObservableObject, MainProfileViewModelProtocol{
    var email: String = "abc@xyz.com"
    
    var dispName: String = "ABC"
    
    var profilePhoto: UIImage{
        UIImage(systemName: "person")!
    }
    
    func signOut() {
        
    }
    
    func updateEmail(_ newEmail: String, completion: ((Bool, String) -> Void)?) throws {
        if !EmailValidationPredicate().evaluate(with: newEmail){
            throw LoginRegExceptions.invalidEmail
        }
        
        DispatchQueue.global().async {
            sleep(2)
            DispatchQueue.main.async {
                if let completion = completion{
                    completion(false,"You can only change email in connected mode, not in preview mode.")
                }
            }
        }
    }
    
    func updatePassword(_ newPwd: String, _ newPwdConfirm: String, completion: ((Bool, String) -> Void)?) throws {
        if newPwd.count < 6{
            throw LoginRegExceptions.weakPassword
        }
        
        if newPwd != newPwdConfirm{
            throw LoginRegExceptions.passwordConfirmDismatch
        }
        
        DispatchQueue.global().async {
            sleep(2)
            DispatchQueue.main.async {
                if let completion = completion{
                    completion(false,"You can only change password in connected mode, not in preview mode.")
                }
            }
        }
    }
    
    func updateProfile(newName: String?, newPhotoUrl: URL?, completion: ((Bool, String) -> Void)?) {
        DispatchQueue.global().async {
            sleep(2)
            DispatchQueue.main.async {
//                if newName != nil{
//                    self.dispName = newName!
//                }
                if let completion = completion{
                    completion(false,"You can only update profile in connected mode, not in preview mode.")
                }
            }
        }
    }
}

fileprivate struct MainProfileViewPreview: View{
    @StateObject var model:ViewModelMockable<MainProfileViewModelMocked> = ViewModelMockable(MainProfileViewModelMocked())
    var body: some View{
        MainProfileViewDev(model: model)
    }
}

typealias MainProfileViewDev = MainProfileView<MainProfileViewModelMocked>
typealias MainProfileViewPub = MainProfileView<MainProfileViewModel>

struct MainProfileView_Previews: PreviewProvider {
    static var previews: some View {
        MainProfileViewPreview()
    }
}
