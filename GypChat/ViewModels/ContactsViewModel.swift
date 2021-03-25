//
//  ContactsViewModel.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/24/21.
//

import Foundation
import SwiftUI
import ValidationComponents
import Firebase
import FirebaseFunctions
import FirebaseStorage
import CodableFirebase

enum ViewModelsExceptions:Error {
    case notLoggedIn
}

class ContactsViewModel: ObservableObject{
    
    @Published private(set) var friendProfiles:[UserProfile] = []
    @Published private(set) var profilePics:[String:UIImage] = [:]
    
    private var authHandle:AuthStateDidChangeListenerHandle?
    private var contactsListener:ListenerRegistration?
    
    private var contacts:Friendlist?{
        didSet{
            if let _contacts = contacts{
                self.fetchProfiles(by: _contacts, completion: {[weak self](profs,errInfo) in
                    self?.friendProfiles = profs
                    self?.profilePics = [:]
                    for prof in profs{
                        self?.fetchProfileImage(prof, completion: {(img,errInfo) in
                            self?.profilePics[prof.uid] = img
                        })
                    }
                })
            }else{
                friendProfiles = []
                profilePics = [:]
            }
        }
    }
    
    init() {
        if let user = Auth.auth().currentUser{
            contacts = Friendlist(uid: user.uid)
            let ref = Firestore.firestore().collection("Contacts").document(user.uid)
            ref.addSnapshotListener({[weak self](snapshot,err) in
                if let data = snapshot?.data(),let friendlist = try? FirestoreDecoder().decode(Friendlist.self, from: data){
                    self?.contacts = friendlist
                }
            })
        }
        
        authHandle = Auth.auth().addStateDidChangeListener({[weak self](auth,user) in
            if let listener = self?.contactsListener{
                listener.remove()
            }
            self?.contactsListener = nil
            if let user = user{
                self?.contacts = Friendlist(uid: user.uid)
                let ref = Firestore.firestore().collection("Contacts").document(user.uid)
                ref.addSnapshotListener({(snapshot,err) in
                    if let data = snapshot?.data(),let friendlist = try? FirestoreDecoder().decode(Friendlist.self, from: data){
                        self?.contacts = friendlist
                    }
                })
            }
        })
    }
    
    deinit {
        authHandle = nil
        if let listener = contactsListener{
            listener.remove()
        }
    }
    
    func fetchProfileImage(_ userProf:UserProfile,completion:((UIImage?,String)->Void)? = nil){
        guard let url = userProf.photoURL else{
            if let completion = completion{
                completion(nil,"")
            }
            return
        }
        
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        ref.getData(maxSize: 64*1024*1024, completion: {(data,err) in
            if let completion = completion{
                if let err = err{
                    completion(nil,err.localizedDescription)
                }else if let data = data,let img = UIImage(data: data){
                    completion(img,"")
                }else{
                    completion(nil,"Failed to decode image data!")
                }
            }
        })
    }
    
    func addContact(_ userProf:UserProfile,completion:((Bool,String)->Void)? = nil) throws{
        guard contacts != nil,let user = Auth.auth().currentUser else {
            throw ViewModelsExceptions.notLoggedIn
        }
        
        var _contacts = contacts!
        _contacts.addFriend(userProf.uid)
        
        if _contacts == contacts{
            if let completion = completion{
                completion(true,"")
            }
            return
        }
        
        let data = try FirestoreEncoder().encode(_contacts)
        
        let ref = Firestore.firestore().collection("Contacts").document(user.uid)
        
        ref.setData(data, completion: {(err) in
            if let completion = completion{
                if let err = err{
                    completion(false,err.localizedDescription)
                }else{
                    completion(true,"")
                }
            }
        })
    }
    
    func removeContact(_ userProf:UserProfile,completion:((Bool,String)->Void)? = nil) throws{
        guard contacts != nil,let user = Auth.auth().currentUser else {
            throw ViewModelsExceptions.notLoggedIn
        }
        
        var _contacts = contacts!
        _contacts.removeFriend(userProf.uid)
        
        if _contacts == contacts{
            if let completion = completion{
                completion(true,"")
            }
            return
        }
        
        let data = try FirestoreEncoder().encode(_contacts)
        
        let ref = Firestore.firestore().collection("Contacts").document(user.uid)
        
        ref.setData(data, completion: {(err) in
            if let completion = completion{
                if let err = err{
                    completion(false,err.localizedDescription)
                }else{
                    completion(true,"")
                }
            }
        })
    }
    
    func searchUser(by email:String,completion:((UserProfile?,String)->Void)? = nil) throws{
        if !EmailValidationPredicate().evaluate(with: email){
            throw LoginRegExceptions.invalidEmail
        }
        
        let functions = Functions.globalFunctions()
        
        functions.httpsCallable("findUser").call(["user_email":email], completion: {(res,err) in
            if let completion = completion{
                if let err = err{
                    completion(nil,err.localizedDescription)
                }else if let data = res?.data as? [String:Any],let prof = try? FirestoreDecoder().decode(UserProfile.self, from: data){
                    completion(prof,"")
                }else{
                    completion(nil,"Failed to decode the data fetched from the server.")
                }
            }
        })
    }
    
    func fetchProfiles(by friendlist:Friendlist,completion:(([UserProfile],String)->Void)? = nil){
        
        let functions = Functions.globalFunctions()
        
        let payload = try? FirebaseEncoder().encode(friendlist)
        
        functions.httpsCallable("getProfiles").call(payload, completion: {(res,err) in
            if let completion = completion{
                if let err = err{
                    print(err)
                    completion([],err.localizedDescription)
                }else if let data = res?.data as? [String:Any],let _res = try? FirebaseDecoder().decode(ProfilesQueryResult.self, from: data){
                    completion(_res.found,"")
                }else{
                    completion([],"Failed to decode the data fetched from the server.")
                }
            }
        })
    }
}

protocol ContactsViewModelProtocol:AnyObject {
    var friendProfiles:[UserProfile] {get}
    var profilePics:[String:UIImage] {get}
    func addContact(_ userProf:UserProfile,completion:((Bool,String)->Void)?) throws
    func removeContact(_ userProf:UserProfile,completion:((Bool,String)->Void)?) throws
    func searchUser(by email:String,completion:((UserProfile?,String)->Void)?) throws
    func fetchProfileImage(_ userProf:UserProfile,completion:((UIImage?,String)->Void)?)
}

extension ContactsViewModel:ContactsViewModelProtocol {}
