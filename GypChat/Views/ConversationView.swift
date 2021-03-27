//
//  ConversationView.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/27/21.
//

import SwiftUI
import Firebase
import FirebaseStorage

struct ConversationView<T>: View where T:ObservableObject, T:ConversationViewModelProtocol{
    @StateObject var model:ViewModelMockable<T>
    
    @State private var msgText:String = ""
    
    @State private var showAlert:Bool = false
    @State private var alertWarning:String = ""
    
    @State private var showSendImageDialog:Bool = false
    
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
    
    private var sendImageButton: some View{
        Button(action: {
            showSendImageDialog = true
        }, label: {
            Image(systemName: "plus.circle")
        }).fullScreenCover(isPresented: $showSendImageDialog, content: {
            ImagePicker(equalRatio: false, handler: {img in
                if let img = img,let data = img.jpegData(compressionQuality: 1.0){
                    let storageRef = Storage.storage().reference()
                    
                    let ref = storageRef.child("message_images/\(model.model.convPath)/\(String.uuid).jpg")
                    
                    inProgress = true
                    
                    let datatask = ref.putData(data, metadata: nil, completion: {(metadata,err) in
                        if let err = err{
                            alertWarning = err.localizedDescription
                            showAlert = true
                            inProgress = false
                        }else{
                            let url = URL(string: "gs://\(ref.bucket)/\(ref.fullPath)")
                            
                            do{
                                if let user_id = model.model.user_id,let other_id = model.model.other_id{
                                    var msg = Message(sender_id: user_id, receiver_id: other_id)
                                    msg.imageURL = url
                                    try model.model.sendMessage(msg, completion: {(ok,errInfo) in
                                        if !ok{
                                            alertWarning = errInfo
                                            showAlert = true
                                        }
                                        inProgress = false
                                    })
                                }else{
                                    throw ViewModelsExceptions.notLoggedIn
                                }
                            }catch ViewModelsExceptions.notLoggedIn{
                                alertWarning = "Looks like you have signed out!"
                                showAlert = true
                                inProgress = false
                            }catch{
                                alertWarning = "Unknown Error!"
                                showAlert = true
                                inProgress = false
                            }
                        }
                    })
                    
                    datatask.resume()
                }
                showSendImageDialog = false
            })
        })
    }
    
    var body: some View {
        ZStack{
            VStack{
                ScrollViewReader{val in
                    ScrollView{
                        ForEach(model.model.messages, content: {msg in
                            MessageView(profilePhoto: (model.model.profilePhoto[msg.sender_id] ?? UIImage(systemName: "person.fill")!),
                                        isCurrentUser: msg.sender_id == model.model.user_id,
                                        text: msg.text,
                                        image: (msg.imageURL == nil ? nil : (model.model.msgImage[msg.imageURL!.absoluteString] ?? UIImage(named: "image_placeholder")!)))
                                .padding([.bottom],15)
                        })
                        .onAppear{
                            if let bottom = model.model.messages.last{
                                val.scrollTo(bottom.id)
                            }
                        }.onChange(of: model.model.messages.last, perform: { _ in
                            if let bottom = model.model.messages.last{
                                val.scrollTo(bottom.id)
                            }
                        })
                    }
                }
                HStack{
                    sendImageButton
                    TextField("Message...", text: $msgText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(minHeight: CGFloat(30))
                    Button(action: {
                        do{
                            if model.model.user_id == nil{
                                throw ViewModelsExceptions.notLoggedIn
                            }
                            
                            let user_id = model.model.user_id!,other_id = model.model.other_id!
                            
                            if !msgText.isEmpty{
                                inProgress = true
                                var msg = Message(sender_id: user_id, receiver_id: other_id)
                                msg.text = msgText
                                try model.model.sendMessage(msg, completion: {(ok,errInfo) in
                                    if ok{
                                        msgText = ""
                                    }else{
                                        alertWarning = errInfo
                                        showAlert = true
                                    }
                                    inProgress = false
                                })
                            }
                        }catch ViewModelsExceptions.notLoggedIn{
                            alertWarning = "Looks like you have signed out!"
                            showAlert = true
                            inProgress = false
                        }catch{
                            alertWarning = "Unknown Error!"
                            showAlert = true
                            inProgress = false
                        }
                    }, label: {
                        Text("Send")
                    })
                }.padding(.all, 15)
            }.alert(isPresented: $showAlert, content: {
                Alert(title: Text("Error"), message: Text(alertWarning), dismissButton: .cancel())
            })
            
            if inProgress{
                loadingIndicator
            }
        }
    }
}

class ConversationViewModelMocked: ObservableObject, ConversationViewModelProtocol{
    @Published var messages: [Message] = []
    
    @Published var user_id: String? = "1234567"
    
    @Published var profilePhoto: [String : UIImage] = [:]
    
    @Published var msgImage: [String : UIImage] = [:]
    
    var other_id: String? = "2345678"
    
    var convPath:String{
        return "1234567_2345678"
    }
    
    private var simulateException:Bool = false
    
    init() {
        for i in 0..<20{
            var msg = i % 2 == 0 ? Message(sender_id: "1234567", receiver_id: "2345678") : Message(sender_id: "2345678", receiver_id: "1234567")
            msg.text = "\(i+1):" + String.uuid
            messages.append(msg)
        }
    }
    
    func sendMessage(_ msg: Message, completion: ((Bool, String) -> Void)?) throws {
        if simulateException{
            throw ViewModelsExceptions.notLoggedIn
        }
        
        DispatchQueue.global().async {
            sleep(5)
            self.messages.append(msg)
            DispatchQueue.main.async {
                if let completion = completion{
                    completion(true,"")
                }
            }
        }
    }
}

fileprivate struct ConversationViewPreview: View{
    var body: some View{
        NavigationView{
            ConversationViewDev(model: ViewModelMockable(ConversationViewModelMocked()))
        }
    }
}

typealias ConversationViewDev = ConversationView<ConversationViewModelMocked>
typealias ConversationViewPub = ConversationView<ConversationViewModel>

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationViewPreview()
    }
}
