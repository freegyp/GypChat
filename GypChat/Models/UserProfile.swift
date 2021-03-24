//
//  UserProfile.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/24/21.
//

import Foundation
import ValidationComponents

struct UserProfile: Codable{
    var uid:String
    var email:String?
    var displayName:String?
    var photoURL:URL?
    
    init(uid:String,email:String? = nil,displayName:String? = nil,photoURL:URL? = nil) throws{
        self.uid = uid
        
        if let _email = email{
            if !EmailValidationPredicate().evaluate(with: _email){
                throw LoginRegExceptions.invalidEmail
            }
            self.email = _email
        }
        
        if let dispName = displayName{
            self.displayName = dispName
        }
        
        if let url = photoURL{
            self.photoURL = url
        }
    }
    
    enum CodingKeys:String,CodingKey {
        case uid
        case email
        case displayName
        case photoURL
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        uid = try values.decode(String.self, forKey: .uid)
        
        email = try? values.decode(String.self, forKey: .email)
        
        if let _email = email,!EmailValidationPredicate().evaluate(with: _email){
            throw LoginRegExceptions.invalidEmail
        }
        
        displayName = try? values.decode(String.self, forKey: .displayName)
        
        photoURL = try? values.decode(URL.self, forKey: .photoURL)
    }
}
