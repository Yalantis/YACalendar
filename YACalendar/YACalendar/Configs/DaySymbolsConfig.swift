//
//  DaySymbolsConfig.swift
//  YALCalendar
//
//  Created by Vodolazkyi Anton on 2/4/20.
//  Copyright © 2020 yalantis. All rights reserved.
//

import UIKit

open class DaySymbolsConfig {
    
    public var isEnabled: Bool = true
    public var type: DaySymbols = .short
    public var height: CGFloat = 30
    public var textColor: UIColor = UIColor(displayP3Red: 188 / 255, green: 188 / 255, blue: 188 / 255, alpha: 1.0)
    public var font = UIFont.systemFont(ofSize: 12, weight: .regular)
    public var textAlignment: NSTextAlignment = .center
    public var separatorColor: UIColor = UIColor(displayP3Red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 1.0)
}
