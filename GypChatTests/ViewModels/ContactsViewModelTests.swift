//
//  ContactsViewModelTests.swift
//  GypChatTests
//
//  Created by Yupeng Gu on 3/24/21.
//

import XCTest

@testable import GypChat

import Firebase
import FirebaseFunctions

class ContactsViewModelTests: XCTestCase {

    class override func setUp() {
        var requestAuth = URLRequest(url: URL(string: "http://localhost:9099/emulator/v1/projects/gyp-toptal-interview-project/accounts")!)
        requestAuth.addValue("Bearer owner",forHTTPHeaderField:"Authorization")
        requestAuth.httpMethod = "DELETE"
        var ok = false,ok2 = false
        let dataTask = URLSession.shared.dataTask(with: requestAuth, completionHandler: {(data,response,err) in
            ok = true
        })
        dataTask.resume()
        
        var requestFirestore = URLRequest(url: URL(string: "http://localhost:8080/emulator/v1/projects/gyp-toptal-interview-project/databases/(default)/documents")!)
        requestFirestore.httpMethod = "DELETE"
        let dataTask2 = URLSession.shared.dataTask(with: requestFirestore, completionHandler: {(data,response,err) in
            ok2 = true
        })
        dataTask2.resume()
        
        while !ok || !ok2 {
            RunLoop.current.run(mode: .common, before: .distantFuture)
        }
    }
    
    override func tearDown() {
        try? Auth.auth().signOut()
    }
    
    func test_1_search_a_user(){
        let loginRegVM = LoginRegisterViewModel(),model = ContactsViewModel()
        
        let exp1 = expectation(description: "register1"),exp2 = expectation(description: "register2"),exp3 = expectation(description: "find_user")
        
        try? loginRegVM.register(with: "abc@xyz.com", pwd: "abcdef", pwdConfirm: "abcdef", completion: {(ok,errInfo) in
            exp1.fulfill()
            try? Auth.auth().signOut()
            try? loginRegVM.register(with: "bcd@xyz.com", pwd: "abcdef", pwdConfirm: "abcdef", completion: {(ok,errInfo) in
                exp2.fulfill()
                try? model.searchUser(by: "abc@xyz.com", completion: {(prof,errInfo) in
                    XCTAssertNotNil(prof)
                    exp3.fulfill()
                })
            })
        })
        
        wait(for: [exp1,exp2,exp3], timeout: 5.0)
    }
    
    func test_2_search_a_user_non_existing(){
        let loginRegVM = LoginRegisterViewModel(),model = ContactsViewModel()
        
        let exp1 = expectation(description: "login"),exp2 = expectation(description: "find_user")
        
        try? loginRegVM.signIn(with: "abc@xyz.com", password: "abcdef", completion: {(ok,errInfo) in
            exp1.fulfill()
            try? model.searchUser(by: "ghi@xyz.com", completion: {(prof,errInfo) in
                XCTAssertNil(prof)
                exp2.fulfill()
            })
        })
        
        wait(for: [exp1,exp2], timeout: 5.0)
    }
    
    func test_3_get_friend_profiles(){
        let loginRegVM = LoginRegisterViewModel(),model = ContactsViewModel()
        
        var friendlist:Friendlist? = nil
        
        let exp1 = expectation(description: "login1"),exp2 = expectation(description: "login2"),exp3 = expectation(description: "login3"),exp4 = expectation(description: "get_profiles")
        
        try? loginRegVM.signIn(with: "abc@xyz.com", password: "abcdef", completion: {(ok,errInfo) in
            friendlist = Friendlist(uid: Auth.auth().currentUser!.uid)
            try? Auth.auth().signOut()
            exp1.fulfill()
            try? loginRegVM.signIn(with: "bcd@xyz.com", password: "abcdef", completion: {(ok,errInfo) in
                friendlist?.addFriend(Auth.auth().currentUser!.uid)
                friendlist?.addFriend(String.uuid)
                try? Auth.auth().signOut()
                exp2.fulfill()
                try? loginRegVM.signIn(with: "abc@xyz.com", password: "abcdef", completion: {(ok,errInfo) in
                    exp3.fulfill()
                    model.fetchProfiles(by: friendlist!, completion: {(profs,errInfo) in
                        XCTAssertEqual(profs.count, 1)
                        exp4.fulfill()
                    })
                })
            })
        })
        
        wait(for: [exp1,exp2,exp3,exp4], timeout: 5.0)
    }
    
    func test_4_add_contact(){
        let loginRegVM = LoginRegisterViewModel(),model = ContactsViewModel()
        
        let exp1 = expectation(description: "sign_in"),exp2 = expectation(description: "search_user"),exp3 = expectation(description: "add_contact"),exp4 = expectation(description: "wait_load")
        
        try? loginRegVM.signIn(with: "abc@xyz.com", password: "abcdef", completion: {(ok,errInfo) in
            exp1.fulfill()
            try? model.searchUser(by: "bcd@xyz.com", completion: {(prof,errInfo) in
                exp2.fulfill()
                if let prof = prof{
                    DispatchQueue.global().async {
                        sleep(2)
                        try? model.addContact(prof, completion: {(ok,errInfo) in
                            exp3.fulfill()
                            DispatchQueue.global().async {
                                sleep(2)
                                exp4.fulfill()
                            }
                        })
                    }
                }
            })
        })
        
        waitForExpectations(timeout: 8.0, handler: {_ in
            XCTAssertEqual(model.friendProfiles.count, 1)
        })
    }
    
    func test_5_remove_contact(){
        let loginRegVM = LoginRegisterViewModel(),model = ContactsViewModel()
        
        let exp1 = expectation(description: "wait_load"),exp2 = expectation(description: "remove_wait")
        
        try? loginRegVM.signIn(with: "abc@xyz.com", password: "abcdef", completion: {(ok,errInfo) in
            DispatchQueue.global().async {
                sleep(2)
                exp1.fulfill()
                XCTAssertEqual(model.friendProfiles.count, 1)
                if let prof = model.friendProfiles.last{
                    try? model.removeContact(prof, completion: {(ok,errInfo) in
                        DispatchQueue.global().async {
                            sleep(2)
                            exp2.fulfill()
                        }
                    })
                }
            }
        })
        
        waitForExpectations(timeout: 8.0, handler: {_ in
            XCTAssertTrue(model.friendProfiles.isEmpty)
        })
    }

}
