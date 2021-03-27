//
//  ConversationTests.swift
//  GypChatTests
//
//  Created by Yupeng Gu on 3/26/21.
//

import XCTest

@testable import GypChat

import CodableFirebase

class ConversationTests: XCTestCase {

    func test_1_conversation_encode(){
        let ids = ["1234567","2345678"]
        var conversation = try? Conversation(user_ids: ids)
        
        XCTAssertNotNil(conversation)
        
        var msg = Message(sender_id: "1234567",receiver_id:"2345678")
        msg.text = "This is a test message."
        conversation?.lastMessage = msg
        
        XCTAssertNoThrow(try FirebaseEncoder().encode(conversation!))
    }
    
    func test_2_conversation_encode(){
        let data:[String:Any] = ["user_IDs":["1234567","2345678"],
                                 "lastUpdateTime":Int(Date().timeIntervalSince1970),
                                 "lastMessage":["msg_id":String.uuid,
                                                "sender_id":"1234567",
                                                "receiver_id":"2345678",
                                                "date":Int(Date().timeIntervalSince1970),
                                                "text":"This is a test message.",
                                                "imageURL":"https://google.com"]]
        
        XCTAssertNoThrow(try FirebaseDecoder().decode(Conversation.self, from: data))
    }

}
