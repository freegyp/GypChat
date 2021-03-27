//
//  MessageTests.swift
//  GypChatTests
//
//  Created by Yupeng Gu on 3/26/21.
//

import XCTest

@testable import GypChat

import CodableFirebase

class MessageTests: XCTestCase {

    func test_1_message_encode(){
        var msg = Message(sender_id:"1234567",receiver_id:"2345678")
        
        msg.text = "This is a test message."
        
        msg.imageURL = URL(string: "https://google.com")
        
        XCTAssertNoThrow(try FirebaseEncoder().encode(msg))
    }
    
    func test_2_message_decode(){
        let data:[String:Any] = ["msg_id":String.uuid,
                                 "sender_id":"1234567",
                                 "receiver_id":"2345678",
                                 "date":Int(Date().timeIntervalSince1970),
                                 "text":"This is a test message.",
                                 "imageURL":"https://google.com"]
        
        XCTAssertNoThrow(try FirebaseDecoder().decode(Message.self, from: data))
    }

}
