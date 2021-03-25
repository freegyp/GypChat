//
//  ContentView.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/22/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var loginRegModel:ViewModelMockable<LoginRegisterViewModel> = ViewModelMockable(LoginRegisterViewModel())
    
    @StateObject var mainProfileModel:ViewModelMockable<MainProfileViewModel> = ViewModelMockable(MainProfileViewModel())
    
    @StateObject var contactsModel:ViewModelMockable<ContactsViewModel> = ViewModelMockable(ContactsViewModel())
    
    var body: some View {
        if loginRegModel.model.isLoggedIn{
            TabView{
                
                Group{
                    ContactsViewPub(model: contactsModel)
                }.tabItem {
                    Label("Contacts", systemImage: "list.bullet")
                }
                
                Group{
                    MainProfileViewPub(model: mainProfileModel)
                }.tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
            }
        }else{
            LoginRegisterViewPub(model: loginRegModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
