//
//  AppDelegate.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/22/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFunctions

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        if ProcessInfo.processInfo.environment["unit_tests"] == "true" {
            print("Setting up Firebase emulator localhost:8080")
            let settings = Firestore.firestore().settings
            settings.host = "localhost:8080"
            settings.isPersistenceEnabled = false
            settings.isSSLEnabled = false
            Firestore.firestore().settings = settings
            Auth.auth().useEmulator(withHost:"localhost", port:9099)
        }
        
        return true
    }
}
