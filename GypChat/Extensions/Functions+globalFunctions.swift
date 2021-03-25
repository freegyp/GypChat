//
//  Functions+globalFunctions.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/25/21.
//

import Foundation
import Firebase
import FirebaseFunctions

extension Functions{
    static func globalFunctions() -> Functions{
        let functions = Functions.functions()
        
        if ProcessInfo.processInfo.environment["unit_tests"] == "true"{
            functions.useEmulator(withHost: "http://localhost", port: 5001)
        }
        
        return functions
    }
}
