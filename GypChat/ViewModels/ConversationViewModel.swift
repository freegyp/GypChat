//
//  ConversationViewModel.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/26/21.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import FirebaseFunctions
import CodableFirebase

class ConversationViewModel: ObservableObject{
    
    @Published var messages:[Message] = []
    @Published var user_id:String? = nil
    @Published var profilePhoto:[String:UIImage] = [:]
    @Published var msgImage:[String:UIImage] = [:]
    
    private var convPath:String
    private var user_IDs:[String]
    private var page_size:Int = 10
    
    private var msgListener:ListenerRegistration?
    private var authHandle:AuthStateDidChangeListenerHandle?
    
    init(convPath:String) throws {
        self.convPath = convPath
        self.user_IDs = convPath.split(separator: "_").map({String($0)})
        
        if self.user_IDs.count != 2{
            throw ConversationExceptions.notTwoPartyConversation
        }
        
        if self.user_IDs[0] == self.user_IDs[1]{
            throw ConversationExceptions.duplicatePartyConversation
        }
        
        for _id in self.user_IDs{
            try? self.fetchProfilePhoto(_id)
        }
        
        let query = Firestore.firestore()
            .collection("Conversations").document(convPath).collection("Messages")
            .order(by: "date", descending: false)
            .limit(toLast: page_size)
        
        msgListener = query.addSnapshotListener({[weak self](snapshot,err) in
            if let changes = snapshot?.documentChanges{
                for change in changes{
                    if let msg = try? FirestoreDecoder().decode(Message.self, from: change.document.data()){
                        self?.messages.append(msg)
                        if let url = msg.imageURL{
                            self?.fetchMessageImage(url)
                        }
                    }
                }
            }
        })
        
        authHandle = Auth.auth().addStateDidChangeListener({[weak self](auth,user) in
            if let user = user{
                self?.user_id = user.uid
            }
        })
    }
    
    func sendMessage(_ msg:Message,completion:((Bool,String)->Void)?) throws{
        guard Auth.auth().currentUser != nil else{
            throw ViewModelsExceptions.notLoggedIn
        }
        
        let data = try FirestoreEncoder().encode(msg)
        
        let functions = Functions.globalFunctions()
        
        functions.httpsCallable("sendMessage").call(data, completion: {(res,err) in
            if let completion = completion{
                if let err = err{
                    completion(false,err.localizedDescription)
                }else{
                    completion(true,"")
                }
            }
        })
    }
    
    private func fetchProfilePhoto(_ _id:String) throws{
        guard Auth.auth().currentUser != nil else{
            throw ViewModelsExceptions.notLoggedIn
        }
        
        if self.profilePhoto[_id] != nil{
            return
        }
        
        let functions = Functions.globalFunctions()
        
        functions.httpsCallable("findUserWithID").call(["user_id":_id], completion: {[weak self](res,err) in
            if let res = res,let data = res.data as? [String:Any],let prof = try? FirestoreDecoder().decode(UserProfile.self, from: data),let url = prof.photoURL{
                let ref = Storage.storage().reference(forURL: url.absoluteString)
                ref.getData(maxSize: 64*1024*1024, completion: {(data,err) in
                    if let data = data, let img = UIImage(data: data){
                        self?.profilePhoto[_id] = img
                    }
                })
            }
        })
    }
    
    private func fetchMessageImage(_ imgURL:URL){
        let path = imgURL.absoluteString
        
        let ref = Storage.storage().reference(forURL: path)
        ref.getData(maxSize: 64*1024*1024, completion: {[weak self](data,err) in
            if let data = data, let img = UIImage(data: data){
                self?.msgImage[path] = img
            }
        })
    }
    
}

protocol ConversationViewModelProtocol: AnyObject {
    var messages:[Message] {get}
    var user_id:String? {get}
    var profilePhoto:[String:UIImage] {get}
    var msgImage:[String:UIImage] {get}
    func sendMessage(_ msg:Message,completion:((Bool,String)->Void)?) throws
}

extension ConversationViewModel: ConversationViewModelProtocol {}
