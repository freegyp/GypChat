//
//  MainProfileViewModel.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/24/21.
//

import Foundation
import SwiftUI
import Firebase
import ValidationComponents

class MainProfileViewModel: ObservableObject {
    @Published var email:String = ""
    @Published var dispName:String = ""
    @Published var profilePhoto:UIImage = UIImage(systemName: "person")!
    private var photoUrl:URL?{
        didSet{
            //Do it later.
        }
    }
    
    private var handle:AuthStateDidChangeListenerHandle?
    
    init() {
        defer {
            handle = Auth.auth().addStateDidChangeListener({[weak self](auth,user) in
                if let user = user{
                    self?.email = user.email ?? ""
                    self?.dispName = user.displayName ?? ""
                    self?.photoUrl = user.photoURL
                    //Do it later.
                }else{
                    self?.email = ""
                    self?.dispName = ""
                    self?.photoUrl = nil
                    self?.profilePhoto = UIImage(systemName: "person")!
                }
            })
        }
    }
    
    deinit {
        if let handle = handle{
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signOut(){
        try? Auth.auth().signOut()
    }
    
    func updateEmail(_ newEmail:String,completion:((Bool,String)->Void)? = nil) throws{
        if !EmailValidationPredicate().evaluate(with: newEmail){
            throw LoginRegExceptions.invalidEmail
        }
        
        if let user = Auth.auth().currentUser{
            user.updateEmail(to: newEmail, completion: {[weak self]err in
                if err == nil{
                    self?.email = newEmail
                    if let completion = completion{
                        completion(true,"")
                    }
                }else{
                    if let completion = completion{
                        completion(false,err!.localizedDescription)
                    }
                }
            })
        }else{
            if let completion = completion{
                completion(false,"Session currently logged out!")
            }
        }
    }
    
    func updatePassword(_ newPwd:String,_ newPwdConfirm:String,completion:((Bool,String)->Void)? = nil) throws{
        if newPwd.count < 6{
            throw LoginRegExceptions.weakPassword
        }
        
        if newPwdConfirm != newPwd{
            throw LoginRegExceptions.passwordConfirmDismatch
        }
        
        if let user = Auth.auth().currentUser{
            user.updatePassword(to: newPwd, completion: {err in
                if let completion = completion{
                    if let err = err{
                        completion(false,err.localizedDescription)
                    }else{
                        completion(true,"")
                    }
                }
            })
        }else{
            if let completion = completion{
                completion(false,"Session currently logged out!")
            }
        }
    }
    
    func updateProfile(newName:String? = nil,newPhotoUrl:URL? = nil,completion:((Bool,String)->Void)? = nil){
        if newName == nil && newPhotoUrl == nil{
            if let completion = completion{
                completion(true,"")
            }
            return
        }
        
        if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest(){
            if let _name = newName{
                changeRequest.displayName = _name
            }
            if let url = newPhotoUrl{
                changeRequest.photoURL = url
            }
            changeRequest.commitChanges(completion: {[weak self]err in
                if err == nil{
                    if let _name = newName{self?.dispName = _name}
                    if let _url = newPhotoUrl{self?.photoUrl = _url}
                    if let completion = completion{
                        completion(true,"")
                    }
                }else{
                    if let completion = completion{
                        completion(false,err!.localizedDescription)
                    }
                }
            })
        }else{
            if let completion = completion{
                completion(false,"Session currently logged out!")
            }
        }
    }
}

protocol MainProfileViewModelProtocol: AnyObject {
    var email:String {get}
    var dispName:String {get}
    var profilePhoto:UIImage {get}
    func signOut()
    func updateEmail(_ newEmail:String,completion:((Bool,String)->Void)?) throws
    func updatePassword(_ newPwd:String,_ newPwdConfirm:String,completion:((Bool,String)->Void)?) throws
    func updateProfile(newName:String?,newPhotoUrl:URL?,completion:((Bool,String)->Void)?)
}

extension MainProfileViewModel: MainProfileViewModelProtocol{}
