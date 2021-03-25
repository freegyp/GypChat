//
//  Friendlist.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/24/21.
//

import Foundation

struct Friendlist:Codable,Equatable {
    var uid:String
    var friendIDs:[String] = []
    
    mutating func addFriend(_ friend_id:String){
        guard friendIDs.count < 100,!friendIDs.contains(friend_id),friend_id != uid else{
            return
        }
        
        friendIDs.append(friend_id)
    }
    
    mutating func removeFriend(_ friend_id:String){
        friendIDs.removeAll(where: {_id in
            _id == friend_id
        })
    }
    
    static func ==(l:Friendlist, r:Friendlist) -> Bool{
        return l.uid == r.uid && l.friendIDs == r.friendIDs
    }
}
