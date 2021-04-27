//
//  Date+Extensions.swift
//  BlxLogging
//
//  Created by Andreas Oetjen on 22.03.21.
//

import Foundation

extension Date {
    var timestampString:String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: self)
    }
}
