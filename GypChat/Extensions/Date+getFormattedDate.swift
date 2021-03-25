//
//  Date+getFormattedDate.swift
//  GypChat
//
//  Created by Yupeng Gu on 3/25/21.
//

import Foundation

extension Date {
   func getFormattedDate(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        dateformat.timeZone = .autoupdatingCurrent
        return dateformat.string(from: self)
    }
}
