//
//  YearHeaderConfig.swift
//  YALCalendar
//
//  Created by Vodolazkyi Anton on 2/13/20.
//  Copyright © 2020 yalantis. All rights reserved.
//

import UIKit

open class YearHeaderConfig {
    
    public var textColor: UIColor = .black
    public var currentTextColor: UIColor = UIColor(displayP3Red: 247 / 255, green: 101 / 255, blue: 48 / 255, alpha: 1.0)
    public var textAlignment: NSTextAlignment = .left
    public var separatorColor: UIColor = UIColor(displayP3Red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 240 / 255)

    public var formatter: DateFormatter = {
        let formetter = DateFormatter()
        formetter.dateFormat = "yyyy"
        return formetter
    }()

    public func font(for calendarType: CalendarType) -> UIFont {
        switch calendarType {
        case .oneOnOne: return UIFont.systemFont(ofSize: 32, weight: .bold)
        case .twoOnThree: return UIFont.systemFont(ofSize: 32, weight: .bold)
        case .threeOnFour: return UIFont.systemFont(ofSize: 32, weight: .bold)
        }
    }
}
