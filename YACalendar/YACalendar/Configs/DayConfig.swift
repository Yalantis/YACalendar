//
//  DayConfig.swift
//  YALCalendar
//
//  Created by Vodolazkyi Anton on 1/31/20.
//  Copyright © 2020 yalantis. All rights reserved.
//

import UIKit

open class DayConfig {
    
    public var textAlignment: NSTextAlignment = .center
    
    public let formetter: DateFormatter = {
        let formetter = DateFormatter()
        formetter.dateFormat = "d"
        return formetter
    }()
    
    public func textColor(for state: DayState, indicator: DayIndicator) -> UIColor {
        switch (state, indicator) {
        case (_, .selected): return .white
        case (_, .startRange), (_, .endRange), (_, .startRangeFilled): return .white
        case (_, .disabled): return UIColor(displayP3Red: 151 / 255, green: 151 / 255, blue: 151 / 255, alpha: 1)
        case (_, .inRange): return .black
        case (.today, _): return .black
        case (.none, _): return .black
        default: return UIColor(displayP3Red: 188 / 255, green: 188 / 255, blue: 188 / 255, alpha: 1)
        }
    }
    
    public func borderColor(for state: DayState, indicator: DayIndicator) -> UIColor? {
        switch (state, indicator) {
        case (.today, _): return UIColor(displayP3Red: 247 / 255, green: 101 / 255, blue: 48 / 255, alpha: 1.0)
        default: return nil
        }
    }
    
    public func borderWidth(for state: DayState, indicator: DayIndicator) -> CGFloat {
        return 0
    }
    
    public func indicatorColor(for state: DayState, indicator: DayIndicator) -> UIColor {
        switch (state, indicator) {
        case (_, .selected): return UIColor(displayP3Red: 247 / 255, green: 101 / 255, blue: 48 / 255, alpha: 1.0)
        case (_, .startRange), (_, .endRange), (_, .startRangeFilled): return .black
        case (_, .inRange): return UIColor.black.withAlphaComponent(0.15)
        default: return .clear
        }
    }
    
    public func eventIndicatorColor(inFuture: Bool) -> UIColor {
        return inFuture ? UIColor(displayP3Red: 247 / 255, green: 101 / 255, blue: 48 / 255, alpha: 1.0) :
            UIColor(displayP3Red: 188 / 255, green: 188 / 255, blue: 188 / 255, alpha: 1)
    }
    
    public func fontSize(for calendarType: CalendarType) -> CGFloat {
        switch calendarType {
        case .oneOnOne: return 14
        case .twoOnThree: return 10
        case .threeOnFour: return 8
        }
    }
    
    public func indicatorInset(for type: CalendarType) -> UIEdgeInsets {
        switch type {
        case .oneOnOne: return UIEdgeInsets(top: 9, left: 9, bottom: 9, right: 9)
        case .twoOnThree: return UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        case .threeOnFour: return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    public func disableIndicatorForm(rect: CGRect) -> CALayer? {
        let inset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        let crossRect = rect.inset(by: inset)
        
        let layer = CAShapeLayer()
        layer.frame = rect
        let path = UIBezierPath()
        path.move(to: crossRect.origin)
        path.addLine(to: CGPoint(x: crossRect.maxX, y: crossRect.maxY))
        path.move(to: CGPoint(x: crossRect.maxX, y: crossRect.minY))
        path.addLine(to: CGPoint(x: crossRect.minX, y: crossRect.maxY))
        path.close()
        layer.path = path.cgPath
        layer.strokeColor = UIColor(displayP3Red: 151 / 255, green: 151 / 255, blue: 151 / 255, alpha: 1).cgColor
        return layer
    }
}
