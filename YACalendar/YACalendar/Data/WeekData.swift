//
//  WeekData.swift
//  YALCalendar
//
//  Created by Vodolazkyi Anton on 1/31/20.
//  Copyright © 2020 yalantis. All rights reserved.
//

import UIKit

final class WeekData {
    
    var rect: CGRect = .zero
    var view: UIView? = nil
    var days: [DayData]
    
    private let startWeekDate: Date
    
    init(startWeekDate: Date, days: [DayData]) {
        self.startWeekDate = startWeekDate
        self.days = days
    }
}
