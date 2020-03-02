//
//  MonthHeaderConfig.swift
//  YALCalendar
//
//  Created by Vodolazkyi Anton on 2/4/20.
//  Copyright © 2020 yalantis. All rights reserved.
//

import UIKit

open class MonthHeaderConfig {
    
    public var textColor: UIColor = .black
    public var currentTextColor: UIColor = UIColor(displayP3Red: 255 / 255, green: 99 / 255, blue: 0 / 255, alpha: 1.0)
    public var textAlignment: NSTextAlignment = .left
    public var showSeparator: Bool = false
    public var separatorColor: UIColor = UIColor(displayP3Red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 240 / 255)

    public var formatter: DateFormatter = {
        let formetter = DateFormatter()
        formetter.dateFormat = "MMMM"
        return formetter
    }()

    public func font(for calendarType: CalendarType) -> UIFont {
        switch calendarType {
        case .oneOnOne: return UIFont.systemFont(ofSize: 18, weight: .medium)
        case .twoOnThree: return UIFont.systemFont(ofSize: 18, weight: .semibold)
        case .threeOnFour: return UIFont.systemFont(ofSize: 14, weight: .semibold)
        }
    }
}
