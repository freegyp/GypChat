//
//  ConversationViewModelTests.swift
//  GypChatTests
//
//  Created by Yupeng Gu on 3/26/21.
//

import XCTest
@testable import GypChat

import Firebase

class ConversationViewModelTests: XCTestCase {

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
    
    func test_1_add_msg_usr1(){
        let loginRegModel = LoginRegisterViewModel()
        
        var ids:[String] = []
        
        let exp1 = expectation(description: "reg1"),exp2 = expectation(description: "reg2"),exp3 = expectation(description: "wait_send_load")
        
        try? loginRegModel.register(with: "bcd@xyz.com", pwd: "abcdefg", pwdConfirm: "abcdefg", completion: {(ok,errInfo) in
            ids.append(Auth.auth().currentUser!.uid)
            try? Auth.auth().signOut()
            exp1.fulfill()
            try? loginRegModel.register(with: "abc@xyz.com", pwd: "abcdefg", pwdConfirm: "abcdefg", completion: {(ok,errInfo) in
                ids.append(Auth.auth().currentUser!.uid)
                let conversation = try? Conversation(user_ids: ids)
                let model = try? ConversationViewModel(convPath: conversation!.docPath)
                XCTAssertNotNil(model)
                var msg = Message(sender_id: ids[1], receiver_id: ids[0])
                msg.text = "This is a test message."
                exp2.fulfill()
                try? model?.sendMessage(msg, completion: {(ok,errInfo) in
                    DispatchQueue.global().async {
                        sleep(2)
                        XCTAssertEqual((model?.messages ?? []).count, 1)
                        exp3.fulfill()
                    }
                })
            })
        })
        
        wait(for: [exp1,exp2,exp3], timeout: 5.0)
    }
    
    func test_2_add_msg_usr2(){
        let loginRegModel = LoginRegisterViewModel()
        
        var ids:[String] = []
        
        let exp1 = expectation(description: "login1"),exp2 = expectation(description: "login2"),exp3 = expectation(description: "wait_send_load")
        
        try? loginRegModel.signIn(with: "abc@xyz.com", password: "abcdefg", completion: {(ok,errInfo) in
            ids.append(Auth.auth().currentUser!.uid)
            try? Auth.auth().signOut()
            exp1.fulfill()
            try? loginRegModel.signIn(with: "bcd@xyz.com", password: "abcdefg", completion: {(ok,errInfo) in
                ids.append(Auth.auth().currentUser!.uid)
                let conversation = try? Conversation(user_ids: ids)
                let model = try? ConversationViewModel(convPath: conversation!.docPath)
                XCTAssertNotNil(model)
                DispatchQueue.global().async {
                    sleep(2)
                    XCTAssertEqual((model?.messages ?? []).count, 1)
                    var msg = Message(sender_id: ids[1], receiver_id: ids[0])
                    msg.text = "This is a test message."
                    exp2.fulfill()
                    try? model?.sendMessage(msg, completion: {(ok,errInfo) in
                        DispatchQueue.global().async {
                            sleep(2)
                            XCTAssertEqual((model?.messages ?? []).count, 2)
                            exp3.fulfill()
                        }
                    })
                }
            })
        })
        
        wait(for: [exp1,exp2,exp3], timeout: 8.0)
    }

}
