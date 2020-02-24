//
//  DaySymbols.swift
//  YALCalendar
//
//  Created by Vodolazkyi Anton on 2/4/20.
//  Copyright © 2020 yalantis. All rights reserved.
//

import Foundation

public enum DaySymbols {
    case short, veryShort
    
    func names(from calendar: Calendar) -> [String] {
        var symbols = [String]()
        
        switch self {
        case .short: symbols = calendar.shortWeekdaySymbols
        case .veryShort: symbols = calendar.veryShortWeekdaySymbols
        }
        
        if calendar.firstWeekday == 1 {
            return symbols
        } else {
            let allDaysWihoutFirst = Array(symbols[calendar.firstWeekday - 1..<symbols.count])
            return allDaysWihoutFirst + symbols[0..<calendar.firstWeekday - 1]
        }
    }
}
