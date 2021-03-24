//
//  MainProfileViewModelTests.swift
//  GypChatTests
//
//  Created by Yupeng Gu on 3/24/21.
//

import XCTest

@testable import GypChat

import Firebase

class MainProfileViewModelTests: XCTestCase {

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
    
    class override func tearDown() {
        try? Auth.auth().signOut()
    }
    
    func test_1_update_email_invalid_email(){
        let vm = MainProfileViewModel()
        
        let loginRegVM = LoginRegisterViewModel()
        
        let exp = expectation(description: "registration_finish")
        
        try? loginRegVM.register(with: "abc@xyz.com", pwd: "abcdefg", pwdConfirm: "abcdefg", completion: {(_ok,errInfo) in
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 2.0)
        
        XCTAssertThrowsError(try vm.updateEmail("abc@xyz"))
    }
    
    func test_2_update_email_successful(){
        let vm = MainProfileViewModel(),vm2 = LoginRegisterViewModel()
        
        let exp1 = expectation(description: "update_email"),exp2 = expectation(description: "re_login")
        
        XCTAssertNoThrow(try vm.updateEmail("bcd@xyz.com", completion: {(ok,errInfo) in
            exp1.fulfill()
            XCTAssertTrue(ok)
            XCTAssertEqual(errInfo, "")
            vm.signOut()
            try? vm2.signIn(with: "bcd@xyz.com", password: "abcdefg", completion: {(ok,errInfo) in
                exp2.fulfill()
            })
        }))
        
        waitForExpectations(timeout: 2.0, handler: {_ in
            XCTAssertEqual(Auth.auth().currentUser?.email, "bcd@xyz.com")
        })
    }
    
    func test_3_update_profile_display_name(){
        let vm = MainProfileViewModel()
        
        let exp = expectation(description: "update_name")
        
        vm.updateProfile(newName: "BCD", completion: {(ok,errInfo) in
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 2.0, handler: {_ in
            XCTAssertEqual(vm.dispName, "BCD")
        })
    }
    
    func test_4_update_password_weak_password(){
        let vm = MainProfileViewModel()
        
        XCTAssertThrowsError(try vm.updatePassword("abcd", "abcd"))
    }
    
    func test_5_update_password_unmatch_password_confirm(){
        let vm = MainProfileViewModel()
        
        XCTAssertThrowsError(try vm.updatePassword("abcdefghijklmn", "abcdefg"))
    }
    
    func test_6_update_password_successful(){
        let vm = MainProfileViewModel(),vm2 = LoginRegisterViewModel()
        
        let exp = expectation(description: "update_password"),exp2 = expectation(description: "re_login")
        
        XCTAssertNoThrow(try vm.updatePassword("bcdefg", "bcdefg", completion: {(ok,errInfo) in
            if ok{exp.fulfill()}
            vm.signOut()
            try? vm2.signIn(with: "bcd@xyz.com", password: "bcdefg", completion: {(ok,errInfo) in
                if ok{exp2.fulfill()}
            })
        }))
        
        wait(for: [exp,exp2], timeout: 2.0)
    }

}
