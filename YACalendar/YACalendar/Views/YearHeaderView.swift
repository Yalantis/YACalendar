//
//  YearHeaderView.swift
//  YALCalendar
//
//  Created by Vodolazkyi Anton on 2/13/20.
//  Copyright © 2020 yalantis. All rights reserved.
//

import UIKit

public final class YearHeaderView: UIView {
    
    private let yearLabel = UILabel()
    private let separatorView = UIView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        yearLabel.frame.size = frame.size
        addSubview(yearLabel)
        
        separatorView.frame = CGRect(x: 0, y: bounds.maxY, width: frame.width, height: 1)
        addSubview(separatorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with config: YearHeaderConfig, isCurrentYear: Bool, yearDate: Date, calendarType: CalendarType) {
        yearLabel.text = config.formatter.string(from: yearDate)
        yearLabel.textAlignment = config.textAlignment
        yearLabel.font = config.font(for: calendarType)
        yearLabel.textColor = isCurrentYear ? config.currentTextColor : config.textColor
        separatorView.backgroundColor = config.separatorColor
    }
}
