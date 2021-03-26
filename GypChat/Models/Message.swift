//
//  Message.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/26/21.
//

import Foundation

struct Message:Codable {
    var user_id:String
    var date:Date = Date()
    var text:String = ""
    var imageURL:URL?
    
    init(user_id:String) {
        self.user_id = user_id
    }
    
    enum CodingKeys: String, CodingKey {
        case user_id
        case date
        case text
        case imageURL
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(user_id, forKey: .user_id)
        
        let _date:Int = Int(date.timeIntervalSince1970)
        
        try container.encode(_date, forKey: .date)
        
        try container.encode(text, forKey: .text)
        
        if let url = imageURL{
            try container.encode(url, forKey: .imageURL)
        }
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        user_id = try values.decode(String.self, forKey: .user_id)
        
        let _date = try values.decode(Int.self, forKey: .date)
        
        date = Date(timeIntervalSince1970: TimeInterval(_date))
        
        text = try values.decode(String.self, forKey: .text)
        
        imageURL = try values.decode(URL.self, forKey: .imageURL)
    }
}
