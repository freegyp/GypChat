//
//  Message.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/26/21.
//

import Foundation

struct Message:Codable, Identifiable, Equatable {
    var id: String {msg_id}
    var msg_id:String
    var sender_id:String
    var receiver_id:String
    var date:Date = Date()
    var text:String = ""
    var imageURL:URL?
    
    init(sender_id:String,receiver_id:String) {
        self.sender_id = sender_id
        self.receiver_id = receiver_id
        msg_id = String.uuid
    }
    
    static func ==(l:Message, r:Message) -> Bool{
        return l.msg_id == r.msg_id
    }
    
    enum CodingKeys: String, CodingKey {
        case msg_id
        case sender_id
        case receiver_id
        case date
        case text
        case imageURL
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(msg_id, forKey: .msg_id)
        
        try container.encode(sender_id, forKey: .sender_id)
        
        try container.encode(receiver_id, forKey: .receiver_id)
        
        let _date:Int = Int(date.timeIntervalSince1970)
        
        try container.encode(_date, forKey: .date)
        
        try container.encode(text, forKey: .text)
        
        if let url = imageURL{
            try container.encode(url, forKey: .imageURL)
        }
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        msg_id = try values.decode(String.self, forKey: .msg_id)
        
        sender_id = try values.decode(String.self, forKey: .sender_id)
        
        receiver_id = try values.decode(String.self, forKey: .receiver_id)
        
        let _date = try values.decode(Int.self, forKey: .date)
        
        date = Date(timeIntervalSince1970: TimeInterval(_date))
        
        text = try values.decode(String.self, forKey: .text)
        
        imageURL = try? values.decode(URL.self, forKey: .imageURL)
    }
}
