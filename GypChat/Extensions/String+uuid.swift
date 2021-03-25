//
//  String+uuid.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/25/21.
//

import Foundation

extension String{
    static var uuid:String{
        let s = UUID().uuidString
        var res = ""
        for c in s{
            if c != "-"{res.append(c)}
        }
        return res
    }
}
