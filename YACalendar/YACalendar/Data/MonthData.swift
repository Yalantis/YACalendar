//
//  MonthData.swift
//  YALCalendar
//
//  Created by Vodolazkyi Anton on 1/31/20.
//  Copyright © 2020 yalantis. All rights reserved.
//

import UIKit

struct GridPostion {
    let row: Int
    let column: Int
}

final class MonthData {
    
    var rect: CGRect = .zero
    var view: UIView? = nil
    var weeks: [WeekData]
    var gridPosition: GridPostion = .init(row: 0, column: 0)

    let startMonthDate: Date
    let endMonthDate: Date
    let isFirstMonthInYear: Bool
    let isCurrentYear: Bool
    let isCurrentMonth: Bool
    let numberOfWeeks: Int
    //we need it to calculate year title
    let yearNumber: Int
    
    init(
        startMonthDate: Date,
        endMonthDate: Date,
        weeks: [WeekData],
        isFirstMonthInYear: Bool,
        yearNumber: Int,
        isCurrentMonth: Bool,
        isCurrentYear: Bool,
        numberOfWeeks: Int
    ) {
        self.startMonthDate = startMonthDate
        self.endMonthDate = endMonthDate
        self.weeks = weeks
        self.isFirstMonthInYear = isFirstMonthInYear
        self.yearNumber = yearNumber
        self.isCurrentMonth = isCurrentMonth
        self.isCurrentYear = isCurrentYear
        self.numberOfWeeks = numberOfWeeks
    }
    
    func containsDate(_ date: Date) -> Bool {
        return date >= startMonthDate && date <= endMonthDate
    }
}
