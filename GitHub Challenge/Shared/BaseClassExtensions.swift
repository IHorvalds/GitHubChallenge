//
//  BaseClassExtensions.swift
//  GitHub Challenge
//
//  Created by Tudor Croitoru on 11/10/2019.
//  Copyright © 2019 Tudor Croitoru. All rights reserved.
//

import Foundation

extension Double {
    var kmFormatted: String {

        if self >= 10000, self <= 999999 {
            return String(format: "%.1fK", locale: Locale.current,self/1000).replacingOccurrences(of: ".0", with: "")
        }

        if self > 999999 {
            return String(format: "%.1fM", locale: Locale.current,self/1000000).replacingOccurrences(of: ".0", with: "")
        }

        return String(format: "%.0f", locale: Locale.current,self)
    }
}

extension Date {
    static func atLeastTenSeconds(between date1: Date, and date2: Date) -> Bool {
        let result: TimeInterval
        if date1 >= date2 {
            result = date1.timeIntervalSince(date2)
        } else {
            result = date2.timeIntervalSince(date1)
        }
        
        return result >= 10
    }
    
    static func atLeastTwoSeconds(between date1: Date, and date2: Date) -> Bool {
        let result: TimeInterval
        if date1 >= date2 {
            result = date1.timeIntervalSince(date2)
        } else {
            result = date2.timeIntervalSince(date1)
        }
        
        return result >= 2
    }
}
