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
    
    @StateObject var conversationListModel:ViewModelMockable<ConversationListViewModel> = ViewModelMockable(ConversationListViewModel())
    
    @State private var selectedTab:Int = 0
    
    var body: some View {
        if loginRegModel.model.isLoggedIn{
            TabView(selection: $selectedTab){
                
                Group{
                    ConversationListViewPub(model: conversationListModel)
                }.tabItem {
                    Label("Conversations", systemImage: "bubble.left.and.bubble.right.fill")
                        .foregroundColor(.purple)
                }.tag(0)
                
                Group{
                    ContactsViewPub(model: contactsModel)
                }.tabItem {
                    Label("Contacts", systemImage: "list.bullet")
                        .foregroundColor(.purple)
                }.tag(1)
                
                Group{
                    MainProfileViewPub(model: mainProfileModel)
                }.tabItem {
                    Label("Profile", systemImage: "person.circle")
                        .foregroundColor(.purple)
                }.tag(2)
            }.onOpenURL(perform: {url in
                if url.scheme == "gypchat",url.host == "conversations"{
                    selectedTab = 0
                }
            })
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
