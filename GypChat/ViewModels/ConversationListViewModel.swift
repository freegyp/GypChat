//
//  ConversationListViewModel.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/28/21.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import CodableFirebase

class ConversationListViewModel: ObservableObject {
    @Published var conversations:[Conversation] = []
    @Published var user_id:String? = nil
    @Published var profilePhoto:[String:UIImage] = [:]
    @Published var profileNames:[String:String] = [:]
    
    private var authHandle:AuthStateDidChangeListenerHandle?
    private var convListener:ListenerRegistration?
    
    private var query:Query?{
        guard let user_id = user_id else{
            return nil
        }
        
        let ref = Firestore.firestore().collection("Conversations")
        
        return ref.order(by: "lastUpdateTime", descending: true)
                    .whereField("user_IDs", arrayContains: user_id)
                    .limit(to: 20)
    }
    
    init() {
        if let user = Auth.auth().currentUser{
            user_id = user.uid
        }
        if let query = query{
            convListener = query.addSnapshotListener({[weak self](snapshot,err) in
                if let snapshot = snapshot{
                    var convs:[Conversation] = []
                    for doc in snapshot.documents{
                        let data = doc.data()
                        if let conv = try? FirestoreDecoder().decode(Conversation.self, from: data){
                            convs.append(conv)
                            for _id in conv.user_IDs{
                                try? self?.fetchProfilePhotoAndName(_id)
                            }
                        }
                    }
                    self?.conversations = convs
                }
            })
        }
        authHandle = Auth.auth().addStateDidChangeListener({[weak self](auth,user) in
            if let listener = self?.convListener{
                listener.remove()
                self?.convListener = nil
            }
            if let user = user{
                self?.user_id = user.uid
                if let query = self?.query{
                    self?.convListener = query.addSnapshotListener({(snapshot,err) in
                        if let snapshot = snapshot{
                            var convs:[Conversation] = []
                            for doc in snapshot.documents{
                                let data = doc.data()
                                if let conv = try? FirestoreDecoder().decode(Conversation.self, from: data){
                                    convs.append(conv)
                                    for _id in conv.user_IDs{
                                        try? self?.fetchProfilePhotoAndName(_id)
                                    }
                                }
                            }
                            self?.conversations = convs
                        }
                    })
                }
            }
        })
    }
    
    deinit {
        authHandle = nil
        if let listener = convListener{
            listener.remove()
        }
        convListener = nil
    }
    
    private func fetchProfilePhotoAndName(_ _id:String) throws{
        guard Auth.auth().currentUser != nil else{
            throw ViewModelsExceptions.notLoggedIn
        }
        
        if self.profilePhoto[_id] != nil{
            return
        }
        
        let functions = Functions.globalFunctions()
        
        functions.httpsCallable("findUserWithID").call(["user_id":_id], completion: {[weak self](res,err) in
            if let res = res,let data = res.data as? [String:Any],let prof = try? FirestoreDecoder().decode(UserProfile.self, from: data){
                if let name = prof.displayName{
                    self?.profileNames[_id] = name
                }
                if let url = prof.photoURL{
                    let ref = Storage.storage().reference(forURL: url.absoluteString)
                    ref.getData(maxSize: 64*1024*1024, completion: {(data,err) in
                        if let data = data, let img = UIImage(data: data){
                            self?.profilePhoto[_id] = img
                        }
                    })
                }
            }
        })
    }
}

protocol ConversationListViewModelProtocol: AnyObject {
    var conversations:[Conversation] {get}
    var user_id:String? {get}
    var profilePhoto:[String:UIImage] {get}
    var profileNames:[String:String] {get}
}

extension ConversationListViewModel: ConversationListViewModelProtocol {}
