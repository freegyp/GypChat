//
//  UserProfileTests.swift
//  GypChatTests
//
//  Created by Yupeng Gu on 3/24/21.
//

import XCTest
import CodableFirebase

@testable import GypChat

class UserProfileTests: XCTestCase {

    func test_1_create_user_uid_only(){
        XCTAssertNoThrow(try UserProfile(uid: "1234567"))
    }
    
    func test_2_create_user_invalid_email(){
        XCTAssertThrowsError(try UserProfile(uid: "1234567", email: "abc@xyz"))
    }
    
    func test_3_create_user_valid_email(){
        XCTAssertNoThrow(try UserProfile(uid: "1234567", email: "abc@xyz.com", displayName: "ABC"))
    }
    
    func test_4_create_user_from_hashmap(){
        let data = ["uid":"1234567",
                    "email":"abc@xyz.com"]
        
        let user = try? FirestoreDecoder().decode(UserProfile.self, from: data)
        
        XCTAssertNotNil(user)
        XCTAssertEqual(user?.uid, "1234567")
        XCTAssertEqual(user?.email, "abc@xyz.com")
        XCTAssertNil(user?.displayName)
        XCTAssertNil(user?.photoURL)
    }
    
    func test_5_create_user_from_hashmap_invalid_email(){
        let data = ["uid":"1234567",
                    "email":"abc@x"]
        
        let user = try? FirestoreDecoder().decode(UserProfile.self, from: data)
        
        XCTAssertNil(user)
    }
    
    func test_6_encode_user_into_hashmap(){
        let user = try! UserProfile(uid: "1234567", email: "abc@xyz.com", displayName: "ABC")
        
        let data = try? FirebaseEncoder().encode(user)
        
        XCTAssertNotNil(data)
    }

}
