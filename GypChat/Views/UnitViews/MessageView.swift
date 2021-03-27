//
//  MessageView.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/27/21.
//

import SwiftUI

struct MessageView: View {
    var profilePhoto:UIImage
    var isCurrentUser:Bool
    var text:String
    var image:UIImage?
    var body: some View {
        HStack(alignment: .bottom, spacing: 10){
            if isCurrentUser{
                Spacer()
            }else{
                Image(uiImage: profilePhoto)
                    .resizable()
                    .frame(width: 32, height: 32, alignment: .center)
                    .cornerRadius(16)
                    .shadow(radius: 16)
            }
            Group{
                if let img = image{
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .frame(width: 300)
                        .cornerRadius(10)
                }else{
                    Text(text)
                        .padding(10)
                        .foregroundColor(isCurrentUser ? Color.white : Color.black)
                        .background(isCurrentUser ? Color.purple : Color.white)
                        .cornerRadius(10)
                }
            }.shadow(radius: 10)
            if isCurrentUser{
                Image(uiImage: profilePhoto)
                    .resizable()
                    .frame(width: 32, height: 32, alignment: .center)
                    .cornerRadius(16)
                    .shadow(radius: 16 )
            }else{
                Spacer()
            }
        }.padding([.leading,.trailing], 10)
    }
}

fileprivate struct MessageViewPreview: View{
    var body: some View{
        MessageView(profilePhoto: UIImage(systemName: "person.fill")!,
                    isCurrentUser: false,
                    text: """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
            """,
                    image: UIImage(named: "image_placeholder")
                    )
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageViewPreview()
    }
}
