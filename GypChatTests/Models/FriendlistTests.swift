//
//  FriendlistTests.swift
//  GypChatTests
//
//  Created by Yupeng Gu on 3/24/21.
//

import XCTest

@testable import GypChat

class FriendlistTests: XCTestCase {

    func test_1_add_self_as_friend(){
        var friendlist = Friendlist(uid: "1234567")
        
        friendlist.addFriend("1234567")
        
        XCTAssertEqual(friendlist.friendIDs.count, 0)
    }
    
    func test_2_add_duplicate_friends(){
        var friendlist = Friendlist(uid: "1234")
        
        for _id in ["2345","3456","2345","4567"]{
            friendlist.addFriend(_id)
        }
        
        XCTAssertEqual(friendlist.friendIDs.count, 3)
    }
    
    func test_3_remove_friend(){
        var friendlist = Friendlist(uid: "1234")
        
        for _id in ["2345","3456","4567"]{
            friendlist.addFriend(_id)
        }
        
        for _id in ["4567","5678"]{
            friendlist.removeFriend(_id)
        }
        
        XCTAssertEqual(friendlist.friendIDs.count, 2)
    }

}
