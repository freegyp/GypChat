//
//  LoginRegisterViewModelTests.swift
//  GypChatTests
//
//  Created by Yupeng Gu on 3/23/21.
//

import XCTest
import Firebase

@testable import GypChat

class LoginRegisterViewModelTests: XCTestCase {

    class override func setUp() {
        var requestAuth = URLRequest(url: URL(string: "http://localhost:9099/emulator/v1/projects/gyp-toptal-interview-project/accounts")!)
        requestAuth.addValue("Bearer owner",forHTTPHeaderField:"Authorization")
        requestAuth.httpMethod = "DELETE"
        var ok = false
        let dataTask = URLSession.shared.dataTask(with: requestAuth, completionHandler: {(data,response,err) in
            ok = true
        })
        dataTask.resume()
        
        while !ok {
            RunLoop.current.run(mode: .common, before: .distantFuture)
        }
    }

    func test_1_register_with_invalid_email() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let vm = LoginRegisterViewModel()
        
        XCTAssertThrowsError(try vm.register(with: "abc@xyz", pwd: "abcdefg", pwdConfirm: "abcdefg"))
    }
    
    func test_2_register_with_invalid_password(){
        let vm = LoginRegisterViewModel()
        
        XCTAssertThrowsError(try vm.register(with: "abc@xyz.com", pwd: "abcd", pwdConfirm: "abcd"))
    }
    
    func test_3_register_with_wrong_password_confirmation(){
        let vm = LoginRegisterViewModel()
        
        XCTAssertThrowsError(try vm.register(with: "abc@xyz.com", pwd: "abcdefg", pwdConfirm: "abcd"))
    }
    
    func test_4_register_with_no_error(){
        let vm = LoginRegisterViewModel()
        
        let exp = expectation(description: "register_finish")
        
        XCTAssertNoThrow(try vm.register(with: "abc@xyz.com", pwd: "abcdefg", pwdConfirm: "abcdefg", completion: {(success,errInfo) in
            XCTAssertTrue(success)
            XCTAssertEqual(errInfo, "")
            exp.fulfill()
        }))
        
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_5_register_with_duplicate_email(){
        let vm = LoginRegisterViewModel()
        
        let exp = expectation(description: "register_finish")
        
        XCTAssertNoThrow(try vm.register(with: "abc@xyz.com", pwd: "abcdefg", pwdConfirm: "abcdefg", completion: {(success,errInfo) in
            XCTAssertFalse(success)
            XCTAssertNotEqual(errInfo, "")
            exp.fulfill()
        }))
        
        wait(for: [exp], timeout: 2.0)
    }
    
    func test_5_login_with_invalid_email(){
        let vm = LoginRegisterViewModel()
        
        XCTAssertThrowsError(try vm.signIn(with: "abc@xyz", password: "abcdefg"))
    }
    
    func test_6_login_with_invalid_password(){
        let vm = LoginRegisterViewModel()
        
        XCTAssertThrowsError(try vm.signIn(with: "abc@xyz.com", password: "abcd"))
    }
    
    func test_7_login_with_unregistered_email(){
        let vm = LoginRegisterViewModel()
        
        let exp = expectation(description: "login_finish")
        
        XCTAssertNoThrow(try vm.signIn(with: "abc@def.com", password: "abcdefg", completion: {(success,errInfo) in
            XCTAssertFalse(success)
            XCTAssertNotEqual(errInfo, "")
            exp.fulfill()
        }))
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_8_login_with_unmatching_password(){
        let vm = LoginRegisterViewModel()
        
        let exp = expectation(description: "login_finish")
        
        XCTAssertNoThrow(try vm.signIn(with: "abc@xyz.com", password: "bcdefg", completion: {(success,errInfo) in
            XCTAssertFalse(success)
            XCTAssertNotEqual(errInfo, "")
            exp.fulfill()
        }))
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_9_login_with_no_error(){
        let vm = LoginRegisterViewModel()
        
        let exp = expectation(description: "login_finish")
        
        XCTAssertNoThrow(try vm.signIn(with: "abc@xyz.com", password: "abcdefg", completion: {(success,errInfo) in
            XCTAssertTrue(success)
            XCTAssertEqual(errInfo, "")
            exp.fulfill()
        }))
        
        wait(for: [exp], timeout: 1.0)
    }
    
    override func tearDown() {
        try? Auth.auth().signOut()
    }

}
