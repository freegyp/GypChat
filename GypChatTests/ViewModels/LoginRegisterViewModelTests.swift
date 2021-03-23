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
            if let err = err{
                print(err)
            }
            ok = true
        })
        dataTask.resume()
        
        while !ok {
            RunLoop.current.run()
        }
    }

    func test_1_Register_with_invalid_email() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let vm = LoginRegisterViewModel()
        
        XCTAssertThrowsError(try vm.register(with: "abc@xyz", pwd: "abcdefg", pwdConfirm: "abcdefg"))
    }
    
    override func tearDown() {
        try? Auth.auth().signOut()
    }

}
