//
//  LoginRegisterViewModel.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/23/21.
//

import Foundation
import SwiftUI
import Firebase
import ValidationComponents

enum LoginRegViewModelExceptions:Error{
    case invalidEmail
    case weakPassword
    case passwordConfirmDismatch
}

class LoginRegisterViewModel:ObservableObject{
    @Published var isLoggedIn:Bool
    
    var handle:AuthStateDidChangeListenerHandle?
    
    init() {
        defer {
            handle = Auth.auth().addStateDidChangeListener({[weak self](auth,user) in
                self?.isLoggedIn = user != nil
            })
        }
        isLoggedIn = Auth.auth().currentUser != nil
    }
    
    deinit {
        if let handle = handle{
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signIn(with email:String,password:String,completion:((Bool,String)->Void)? = nil) throws{
        if !EmailValidationPredicate().evaluate(with: email){
            //Invalid email.
            throw LoginRegViewModelExceptions.invalidEmail
        }
        
        if password.count < 6{
            //Too weak password.
            throw LoginRegViewModelExceptions.weakPassword
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: {(res,err) in
            if let completion = completion{
                if let err = err{
                    completion(false,err.localizedDescription)
                }else{
                    completion(true,"")
                }
            }
        })
    }
    
    func register(with email:String,pwd:String,pwdConfirm:String,completion:((Bool,String)->Void)? = nil) throws{
        if !EmailValidationPredicate().evaluate(with: email){
            //Invalid email.
            throw LoginRegViewModelExceptions.invalidEmail
        }
        
        if pwd.count < 6{
            //Too weak password.
            throw LoginRegViewModelExceptions.weakPassword
        }
        
        if pwdConfirm != pwd{
            throw LoginRegViewModelExceptions.passwordConfirmDismatch
        }
        
        Auth.auth().createUser(withEmail: email, password: pwd, completion: {(res,err) in
            if let completion = completion{
                if let err = err{
                    completion(false,err.localizedDescription)
                }else{
                    completion(true,"")
                }
            }
        })
    }
}
