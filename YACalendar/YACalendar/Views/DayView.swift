//
//  DayView.swift
//  YALCalendar
//
//  Created by Vodolazkyi Anton on 2/4/20.
//  Copyright © 2020 yalantis. All rights reserved.
//

import UIKit

fileprivate let dayIndicatorViewTag = 11101
fileprivate let eventIndicatorViewTag = 11102

public final class DayView: UIView {
    
    private let dayLabel: UILabel
    
    public override init(frame: CGRect) {
        dayLabel = UILabel(frame: CGRect(origin: .zero, size: frame.size))
        super.init(frame: frame)
        
        addSubview(dayLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateEventIndicator(with config: DayConfig, day: DayData) {
        subviews.filter { $0.tag == eventIndicatorViewTag }.forEach { $0.removeFromSuperview() }
        
        if day.events.isEmpty == false {
            let view = UIView(frame: CGRect(x: bounds.midX - 3, y: bounds.maxY - 6, width: 6, height: 6))
            view.tag = eventIndicatorViewTag
            view.layer.cornerRadius = view.frame.height / 2
            view.backgroundColor = config.eventIndicatorColor(inFuture: day.inFuture)
            insertSubview(view, at: 0)
        }
    }
    
    func configure(with config: DayConfig, day: DayData, calendarType: CalendarType) {
        subviews.filter { $0.tag == dayIndicatorViewTag }.forEach { $0.removeFromSuperview() }
        
        dayLabel.text = config.formetter.string(from: day.date)
        dayLabel.textAlignment = config.textAlignment
        dayLabel.font = UIFont.systemFont(ofSize: config.fontSize(for: calendarType))
        dayLabel.textColor = config.textColor(for: day.state, indicator: day.indicator)
        
        if day.state == .today || day.indicator != .none {
            let view = UIView()
            let inset = config.indicatorInset(for: calendarType)
            view.frame = bounds.inset(by: inset)
            view.layer.cornerRadius = view.frame.height / 2
            view.tag = dayIndicatorViewTag
            view.backgroundColor = config.indicatorColor(for: day.state, indicator: day.indicator)
            view.layer.borderColor = config.borderColor(for: day.state, indicator: day.indicator)?.cgColor
            view.layer.borderWidth = config.borderWidth(for: day.state, indicator: day.indicator)
            insertSubview(view, at: 0)

            switch (day.state, day.indicator) {
            case (_, .startRangeFilled), (_, .endRange):
                let backView = UIView()
                backView.frame = CGRect(
                    x: day.indicator == .endRange ? -calendarType.distanceBetweenDays / 2 : bounds.width / 2,
                    y: inset.top,
                    width: (bounds.width / 2) + calendarType.distanceBetweenDays / 2,
                    height: bounds.height - (inset.top + inset.bottom)
                )
                backView.tag = dayIndicatorViewTag
                backView.backgroundColor = config.indicatorColor(for: day.state, indicator: .inRange)
                insertSubview(backView, at: 1)
                break
                
            case (_, .inRange):
                view.frame = CGRect(
                    x: -calendarType.distanceBetweenDays / 2,
                    y: inset.top,
                    width: bounds.width + calendarType.distanceBetweenDays,
                    height: bounds.height - (inset.top + inset.bottom)
                )
                view.layer.cornerRadius = 0
                break
                
            case (_, .disabled):
                guard let disableLayer = config.disableIndicatorForm(rect: view.bounds) else {
                    break
                }
                
                view.layer.addSublayer(disableLayer)
                break
                
            default: break
            }
        }
    }
}
