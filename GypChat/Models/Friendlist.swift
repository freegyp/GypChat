//
//  Friendlist.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/24/21.
//

import Foundation

struct Friendlist:Codable {
    var uid:String
    var friendIDs:[String] = []
    
    mutating func addFriend(_ friend_id:String){
        guard !friendIDs.contains(friend_id),friend_id != uid else{
            return
        }
        
        friendIDs.append(friend_id)
    }
    
    mutating func removeFriend(_ friend_id:String){
        friendIDs.removeAll(where: {_id in
            _id == friend_id
        })
    }
}
