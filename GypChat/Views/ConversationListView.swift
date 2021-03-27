//
//  ConversationListView.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/28/21.
//

import SwiftUI

struct ConversationListView<T>: View where T:ObservableObject, T:ConversationListViewModelProtocol{
    @ObservedObject var model:ViewModelMockable<T>
    
    @State private var conversation_path:String = ""
    @State private var inConversation:Bool = false
    
    private func convDest(_ path:String) -> some View{
        let convVM = try? ConversationViewModel(convPath: path)
        return Group{
            if convVM != nil{
                ConversationViewPub(model: ViewModelMockable(convVM!))
            }else{
                EmptyView()
            }
        }
    }
    
    var body: some View {
        NavigationView{
            Group{
                VStack{
                    List{
                        ForEach(model.model.conversations, content: {conv in
                            Link(destination: URL(string: "gypchat://conversations/\(conv.docPath)")!, label: {
                                row(conv)
                            })
                        })
                    }
                    NavigationLink(destination: convDest(conversation_path),
                                   isActive: $inConversation, label: {
                                    EmptyView()
                                   })
                }
            }.navigationTitle("Conversations")
        }.onOpenURL(perform: {url in
            if url.scheme == "gypchat",url.host == "conversations",url.pathComponents.count == 2{
                conversation_path = url.pathComponents[1]
                inConversation = true
            }
        })
    }
    
    private func row(_ conv:Conversation) -> some View{
        let uid = conv.user_IDs.first(where: {$0 != model.model.user_id})!
        
        return HStack{
            Image(uiImage: model.model.profilePhoto[uid] ?? UIImage(systemName: "person.fill")!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48)
                .cornerRadius(24)
            VStack(alignment: .leading,spacing:10){
                Text(model.model.profileNames[uid] ?? "Unknown name")
                    .font(.title2)
                    .foregroundColor(.purple)
                Group{
                    if let msg = conv.lastMessage{
                        Text(msg.imageURL != nil ? "Image......" : ((msg.sender_id == model.model.user_id ? "You:" : "") + msg.text))
                            .font(.body)
                            .foregroundColor(.black)
                    }else{
                        Spacer()
                    }
                }
            }
        }
    }
}

class ConversationListViewModelMocked: ObservableObject, ConversationListViewModelProtocol{
    @Published var conversations: [Conversation] = []
    
    @Published var user_id: String? = String.uuid
    
    @Published var profilePhoto: [String : UIImage] = [:]
    
    @Published var profileNames: [String : String] = [:]
    
    init() {
        let f1 = try! UserProfile(uid: String.uuid, email: "abc@xyz.com", displayName: "ABC", photoURL: nil)
        let f2 = try! UserProfile(uid: String.uuid, email: "bcd@xyz.com", displayName: "BCD", photoURL: nil)
        let f3 = try! UserProfile(uid: String.uuid, email: "cde@xyz.com", displayName: "CDE", photoURL: nil)
        let f4 = try! UserProfile(uid: String.uuid, email: "efg@xyz.com", displayName: "EFG", photoURL: nil)
        for friend in [f1,f2,f3,f4]{
            var conv = try! Conversation(user_ids: [user_id!,friend.uid])
            var msg = Message(sender_id: user_id!, receiver_id: friend.uid)
            msg.text = String.uuid
            conv.lastMessage = msg
            conversations.append(conv)
            profileNames[friend.uid] = friend.displayName!
        }
    }
}

fileprivate struct ConversationListViewPreview: View{
    @StateObject var model:ViewModelMockable<ConversationListViewModelMocked> = ViewModelMockable(ConversationListViewModelMocked())
    var body: some View{
        ConversationListViewDev(model: model)
    }
}

typealias ConversationListViewDev = ConversationListView<ConversationListViewModelMocked>
typealias ConversationListViewPub = ConversationListView<ConversationListViewModel>

struct ConversationListView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationListViewPreview()
    }
}
