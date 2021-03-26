//
//  Conversation.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/26/21.
//

import Foundation

enum ConversationExceptions:Error {
    case notTwoPartyConversation
    case duplicatePartyConversation
}

struct Conversation: Codable{
    var user_IDs:[String]
    var lastUpdateTime:Date
    var lastMessage:Message?
    
    var docPath:String{
        return user_IDs.sorted().joined(separator: "_")
    }
    
    init(user_ids:[String]) throws {
        if user_ids.count != 2{
            throw ConversationExceptions.notTwoPartyConversation
        }
        
        if user_ids[0] == user_ids[1]{
            throw ConversationExceptions.duplicatePartyConversation
        }
        
        user_IDs = user_ids
        lastUpdateTime = Date()
    }
    
    enum CodingKeys:String,CodingKey {
        case user_IDs
        case lastUpdateTime
        case lastMessage
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(user_IDs, forKey: .user_IDs)
        
        let _lastUpdateTime:Int = Int(lastUpdateTime.timeIntervalSince1970)
        
        try container.encode(_lastUpdateTime, forKey: .lastUpdateTime)
        
        if let _lastMessage = lastMessage{
            try container.encode(_lastMessage, forKey: .lastMessage)
        }
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        user_IDs = try values.decode([String].self, forKey: .user_IDs)
        
        if user_IDs.count != 2{
            throw ConversationExceptions.notTwoPartyConversation
        }
        
        if user_IDs[0] == user_IDs[1]{
            throw ConversationExceptions.duplicatePartyConversation
        }
        
        let _lastUpdateTime = try values.decode(Int.self, forKey: .lastUpdateTime)
        
        lastUpdateTime = Date(timeIntervalSince1970: TimeInterval(_lastUpdateTime))
        
        lastMessage = try? values.decode(Message.self, forKey: .lastMessage)
    }
}
