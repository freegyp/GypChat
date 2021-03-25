//
//  ContactsView.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/25/21.
//

import SwiftUI

struct ContactsView<T>: View where T:ObservableObject, T:ContactsViewModelProtocol{
    @ObservedObject var model:ViewModelMockable<T>
    
    @State private var showAddContact:Bool = false
    @State private var searchEmail:String = ""
    @State private var searchEmailWarning:String = ""
    
    @State private var searchedProfile:UserProfile? = nil
    @State private var searchedProfileImage:UIImage = UIImage(systemName: "person")!
    
    @State private var showAlert:Bool = false
    @State private var alertWarning:String = ""
    
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
    
    var body: some View {
        ZStack{
            NavigationView{
                List{
                    ForEach(model.model.friendProfiles, content: { prof in
                        HStack{
                            Image(uiImage: model.model.profilePics[prof.uid] ?? UIImage(systemName: "person")!)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 36)
                                .cornerRadius(18)
                            VStack{
                                Text(prof.displayName ?? "")
                                    .font(.title3)
                                    .foregroundColor(.black)
                                Text(prof.email ?? "")
                                    .font(.body)
                                    .foregroundColor(.black)
                            }
                        }.padding(.all, 12)
                    }).onDelete(perform: { indexSet in
                        let profDel = model.model.friendProfiles[indexSet.first!]
                        do{
                            inProgress = true
                            try model.model.removeContact(profDel, completion: {(ok,errInfo) in
                                inProgress = false
                                if !ok{
                                    alertWarning = errInfo
                                    showAlert = true
                                }
                            })
                        }catch ViewModelsExceptions.notLoggedIn{
                            inProgress = false
                            alertWarning = "Looks like you have signed out!"
                            showAlert = true
                        }catch{
                            inProgress = false
                            alertWarning = "Unknown error!"
                            showAlert = true
                        }
                    })
                }.navigationTitle("Contacts")
                .navigationBarItems(trailing: Button(action: {
                    searchedProfile = nil
                    searchEmail = ""
                    showAddContact = true
                }, label: {
                    Image(systemName:"plus")
                }))
            }.alert(isPresented: $showAlert, content: {
                Alert(title: Text("Error"), message: Text(alertWarning), dismissButton: .cancel())
            }).sheet(isPresented: $showAddContact, content: {
                ZStack{
                    NavigationView{
                        Group{
                            Form{
                                Section{
                                    VStack{
                                        TextField("Email", text: $searchEmail)
                                            .keyboardType(.emailAddress)
                                        if !searchEmailWarning.isEmpty{
                                            Text(searchEmailWarning)
                                                .font(.footnote)
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                
                                if searchedProfile != nil{
                                    Section{
                                        HStack{
                                            Group{
                                                Image(uiImage: searchedProfileImage)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 56)
                                                    .cornerRadius(28)
                                                VStack{
                                                    Text(searchedProfile?.displayName ?? "")
                                                        .font(.title)
                                                        .foregroundColor(.black)
                                                    Text(searchedProfile?.email ?? "")
                                                        .font(.title3)
                                                        .foregroundColor(.black)
                                                }
                                            }
                                            Spacer()
                                            Button(action:{
                                                do{
                                                    showAddContact = false
                                                    inProgress = true
                                                    try model.model.addContact(searchedProfile!){(ok,errInfo) in
                                                        if !ok{
                                                            alertWarning = errInfo
                                                            showAlert = true
                                                        }
                                                        inProgress = false
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
                                            }, label:{
                                                Text("Add")
                                                    .font(.title3)
                                                    .foregroundColor(.white)
                                                    .frame(width:100,height:34)
                                                    .background(Color.blue)
                                                    .cornerRadius(5)
                                            })
                                        }
                                    }
                                }
                            }
                        }.navigationTitle("Search By Email")
                        .navigationBarItems(leading:Button(action: {
                            showAddContact = false
                        }, label: {
                            Text("Cancel")
                        }),trailing: Button(action: {
                            do{
                                inProgress = true
                                try model.model.searchUser(by: searchEmail.lowercased()){(prof,errInfo) in
                                    if let _prof = prof{
                                        model.model.fetchProfileImage(_prof){(img,errInfo) in
                                            if let img = img{
                                                searchedProfileImage = img
                                            }
                                        }
                                    }
                                    searchedProfile = prof
                                    searchEmailWarning = errInfo
                                    inProgress = false
                                }
                            }catch LoginRegExceptions.invalidEmail{
                                searchEmailWarning = "Invalid Email!"
                                inProgress = false
                            }catch{
                                searchEmailWarning = "Unknown Error!"
                                inProgress = false
                            }
                        }, label: {
                            Image(systemName: "magnifyingglass")
                        }))
                    }
                    
                    if inProgress{
                        loadingIndicator
                    }
                }
            })
            
            if inProgress{
                loadingIndicator
            }
        }
    }
}

class ContactsViewModelMocked: ObservableObject,ContactsViewModelProtocol{
    
    var friendProfiles: [UserProfile] = []
    
    var profilePics: [String : UIImage] = [:]
    
    private var allProfiles: [UserProfile] = []
    private var simExceptions:Bool = false
    
    init() {
        let emails = ["abc@xyz.com","bcd@xyz.com","cde@xyz.com","efg@xyz.com","fgh@xyz.com"]
        let names = ["ABC","BCD","CDE","EFG","FGH"]
        for i in 0..<5{
            let prof = try! UserProfile(uid: String.uuid, email: emails[i], displayName: names[i], photoURL: nil)
            allProfiles.append(prof)
            if i > 2{
                friendProfiles.append(prof)
            }
        }
    }
    
    func fetchProfileImage(_ userProf: UserProfile, completion: ((UIImage?, String) -> Void)?) {
        DispatchQueue.global().async {
            sleep(2)
            DispatchQueue.main.async {
                if let completion = completion{
                    completion(nil,"")
                }
            }
        }
    }
    
    func addContact(_ userProf: UserProfile, completion: ((Bool, String) -> Void)?) throws {
        if simExceptions{
            throw ViewModelsExceptions.notLoggedIn
        }
        
        DispatchQueue.global().async {
            sleep(2)
            DispatchQueue.main.async {
                if !self.friendProfiles.contains(userProf){
                    self.friendProfiles.append(userProf)
                }
                if let completion = completion{
                    completion(true,"")
                }
            }
        }
    }
    
    func removeContact(_ userProf: UserProfile, completion: ((Bool, String) -> Void)?) throws {
        if simExceptions{
            throw ViewModelsExceptions.notLoggedIn
        }
        
        DispatchQueue.global().async {
            sleep(2)
            DispatchQueue.main.async {
                self.friendProfiles.removeAll(where: {prof in
                    prof == userProf
                })
                if let completion = completion{
                    completion(true,"")
                }
            }
        }
    }
    
    func searchUser(by email: String, completion: ((UserProfile?, String) -> Void)?) throws {
        if simExceptions{
            throw LoginRegExceptions.invalidEmail
        }
        
        DispatchQueue.global().async {
            sleep(2)
            DispatchQueue.main.async {
                let prof = self.allProfiles.first(where: {_prof in
                    _prof.email == email
                })
                if let completion = completion{
                    completion(prof,prof == nil ? "User not found!" : "")
                }
            }
        }
    }
}

fileprivate struct ContactsViewPreview: View{
    @StateObject var model:ViewModelMockable<ContactsViewModelMocked> = ViewModelMockable(ContactsViewModelMocked())
    var body: some View{
        ContactsViewDev(model: model)
    }
}

typealias ContactsViewDev = ContactsView<ContactsViewModelMocked>
typealias ContactsViewPub = ContactsView<ContactsViewModel>

struct ContactsView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsViewPreview()
    }
}
