//
//  ContentView.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/22/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var loginRegModel:ViewModelMockable<LoginRegisterViewModel> = ViewModelMockable(LoginRegisterViewModel())
    
    var body: some View {
        if loginRegModel.model.isLoggedIn{
            Text("Hello, view under construction!")
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
