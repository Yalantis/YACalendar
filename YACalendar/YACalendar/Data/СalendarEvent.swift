//
//  СalendarEvent.swift
//  YALCalendar
//
//  Created by Vodolazkyi Anton on 2/17/20.
//  Copyright © 2020 yalantis. All rights reserved.
//

import Foundation

public class CalendarEvent {
    
    public let title: String
    public let startDate: Date
    public let endDate: Date

    public init(title: String, startDate: Date, endDate: Date) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
    }
}
