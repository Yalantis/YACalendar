//
//  MonthHeaderView.swift
//  YALCalendar
//
//  Created by Vodolazkyi Anton on 2/13/20.
//  Copyright © 2020 yalantis. All rights reserved.
//

import UIKit

public final class MonthHeaderView: UIView {
    
    private let monthLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(monthLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with config: MonthHeaderConfig, monthData: MonthData, calendarType: CalendarType) {
        monthLabel.frame = bounds.inset(by: calendarType.monthTitleInset)
        monthLabel.textColor = monthData.isCurrentMonth ? config.currentTextColor : config.textColor
        monthLabel.text = config.formatter.string(from: monthData.startMonthDate)
        monthLabel.font = config.font(for: calendarType)
        monthLabel.textAlignment = config.textAlignment
    
        if config.showSeparator {
            let separatorView = UIView()
            separatorView.frame = CGRect(x: 0, y: bounds.maxY - 8, width: frame.width, height: 1)
            separatorView.backgroundColor = config.separatorColor
            addSubview(separatorView)
        }
    }
}
