//
//  CalendarView.swift
//  YALCalendar
//
//  Created by Vodolazkyi Anton on 1/31/20.
//  Copyright © 2020 yalantis. All rights reserved.
//

import UIKit

@objc
public protocol CalendarViewDelegate: class {
    @objc optional func didSelectDate(_ date: Date)
    @objc optional func didSelectRange(_ startDate: Date, endDate: Date)
    @objc optional func didUpdateDisplayedDate(_ date: Date)
    @objc optional func didChangeOrientation(_ isPortrait: Bool)
}

public class CalendarView: UIView {
    
    public final class Config {
        public var month = MonthConfig()
        public var day = DayConfig()
        public var monthTitle = MonthHeaderConfig()
        public var yearHeader = YearHeaderConfig()
        public var daySymbols = DaySymbolsConfig()
    }
    
    // MARK: - Properties
    
    public var selectionType: SelectionType = .one
    public var config: Config = Config()
    public var currentDate: Date = Date()
    
    public var isPagingEnabled: Bool {
        get {
            return scrollView.isPagingEnabled
        } set {
            scrollView.isPagingEnabled = newValue
        }
    }
    
    public weak var calendarDelegate: CalendarViewDelegate?
    
    public var data: CalendarData? {
        didSet { redraw() }
    }
    
    public var grid: Grid = Grid() {
        didSet { redraw() }
    }
    
    public private(set) var isPortrait = true {
        didSet {
            calendarDelegate?.didChangeOrientation?(isPortrait)
        }
    }
    
    private let scrollView = UIScrollView()
    private let daysSymbolsSeparatorView = UIView()

    private let daysStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        return stackView
    }()

    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    // MARK: - Public Methods
    
    public func scroll(to date: Date) {
        guard let data = data, let monthWithCurrentDate = data.monthData(with: date) else { return }
        
        var origin = grid.originForMonth(
            with: monthWithCurrentDate.offset,
            position: monthWithCurrentDate.element.gridPosition,
            data: data,
            yearNumber: monthWithCurrentDate.element.yearNumber,
            showTitle: config.month.showTitle,
            rectSize: scrollView.frame.size,
            isPortrait: isPortrait,
            showDaysOut: config.month.showDaysOut
        )
        if origin == .zero {
            origin.x += 1
        }
        scrollView.contentOffset = origin
    }
    
    public func selectDay(with date: Date) {
        guard let day = data?.day(with: date) else { return }
        
        day.select()
        
        if grid.calendarType == .oneOnOne {
            day.view?.configure(with: config.day, day: day, calendarType: grid.calendarType)
        }
    }
    
    public func selectDays(with dates: [Date]) {
        let days = data?.allDays
            .filter { $0.canSelect }
            .filter { day in
                return dates.contains(where: { data?.isDate($0, inSameDayAs: day.date) == true })
            }
                    
        days?.forEach {
            $0.select()
            
            if grid.calendarType == .oneOnOne {
                $0.view?.configure(with: config.day, day: $0, calendarType: grid.calendarType)
            }
        }
    }
    
    public func disableDays(with dates: [Date]) {
        let days = data?.allDays
            .filter { $0.state != .out }
            .filter { day in
                return dates.contains(where: { data?.isDate($0, inSameDayAs: day.date) == true })
            }
                    
        days?.forEach {
            $0.setDisabled()
            
            if grid.calendarType == .oneOnOne {
                $0.view?.configure(with: config.day, day: $0, calendarType: grid.calendarType)
            }
        }
    }
    
    public func setEvents(_ events: [CalendarEvent]) {
        let days = data?.setEvents(events)
        days?.forEach { $0.view?.updateEventIndicator(with: config.day, day: $0) }
    }
    
    public func selectRange(with startDay: Date, endDate: Date) {
        let days = data?.allDays
            .filter { $0.canSelect }
            .filter { $0.date >= startDay && $0.date <= endDate }
            .sorted(by: { $0.date < $1.date })

        days?.enumerated().forEach {
            if $0.offset == 0 {
                $0.element.fillStartRange()
            } else if $0.offset == (days?.count ?? 0) - 1 {
                $0.element.endRange()
            } else {
                $0.element.setInRange()
            }
            
            if grid.calendarType == .oneOnOne {
                $0.element.view?.configure(with: config.day, day: $0.element, calendarType: grid.calendarType)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func initialize() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        addGestureRecognizer(tapGesture)
        
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        addSubview(daysStackView)
        addSubview(daysSymbolsSeparatorView)
    }
    
    @objc
    private func redraw() {
        scrollView.frame.size = bounds.size
        
        if grid.calendarType == .oneOnOne && config.daySymbols.isEnabled {
            scrollView.frame.origin.y = config.daySymbols.height
            daysStackView.isHidden = false
            daysSymbolsSeparatorView.isHidden = false
        } else {
            scrollView.frame.origin.y = 0
            daysStackView.isHidden = true
            daysSymbolsSeparatorView.isHidden = true
        }
        
        scrollView.delegate = nil
        scrollView.contentOffset = .zero
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        
        data?.months.forEach {
            $0.view = nil
        }
        
        calculateMonths()
        calculateContentSize()
        scrollView.delegate = self
        animateTransition()
        scroll(to: currentDate)
        
        guard let data = data else { return }
        
        if config.daySymbols.isEnabled {
            let symbols = config.daySymbols.type.names(from: data.calendar)
            setDays(symbols)
        }
    }
    
    @objc
    private func orientationChanged() {
        guard UIDevice.current.orientation.isValidInterfaceOrientation else {
            return
        }
        
        let newOrientationPortait = UIDevice.current.orientation.isPortrait
        
        if newOrientationPortait != isPortrait {
            isPortrait = newOrientationPortait
            redraw()
        }
    }
    
    @objc
    private func tapped(_ sender: UITapGestureRecognizer) {
        guard let data = data else { return }
        
        let tappedPoint = sender.location(in: scrollView)
        
        guard let tappedMonth = data.months.first(where: { $0.rect.contains(tappedPoint) }) else { return }
        
        if grid.calendarType == .oneOnOne {
            let tappedPointInMonth = sender.location(in: tappedMonth.view)
            let tappedWeek = tappedMonth.weeks.first(where: { $0.rect.contains(tappedPointInMonth) })
            let tappedPointInWeek = sender.location(in: tappedWeek?.view)
            
            var selectedDay = tappedWeek?.days.first(where: { $0.rect.contains(tappedPointInWeek) })
            
            if selectedDay == nil {
                var currentDiff: CGFloat = abs(tappedPointInWeek.x - (tappedWeek?.days.first?.rect.midX ?? 0))
                selectedDay = tappedWeek?.days.first
                
                for day in (tappedWeek?.days ?? []) {
                    let diff = abs(tappedPointInWeek.x - day.rect.midX)
                    
                    if diff < currentDiff {
                        currentDiff = diff
                        selectedDay = day
                    }
                }
            }
            
            guard let day = selectedDay, day.canSelect else { return }
            
            switch selectionType {
            case .one:
                let allSelectedDays = data.allDays.filter { $0.isSelected }
                
                allSelectedDays.forEach { data in
                    data.select()
                    data.view?.configure(with: config.day, day: data, calendarType: grid.calendarType)
                }
                
                day.select()
                day.view?.configure(with: config.day, day: day, calendarType: grid.calendarType)
                calendarDelegate?.didSelectDate?(day.date)

            case .range:
                let allDays = data.allDays
                
                if allDays.contains(where: { $0.indicator == .startRange || $0.indicator == .startRangeFilled }) == false {
                    day.startRange()
                    day.view?.configure(with: config.day, day: day, calendarType: grid.calendarType)
                } else if allDays.contains(where: { $0.indicator == .endRange }) == false {
                    let startRangeDay = allDays.first(where: { $0.indicator == .startRange }) ?? day
                    
                    if day.date <= startRangeDay.date {
                        startRangeDay.resetIndicator()
                        startRangeDay.view?.configure(with: config.day, day: startRangeDay, calendarType: grid.calendarType)
                        
                        day.startRange()
                        day.view?.configure(with: config.day, day: day, calendarType: grid.calendarType)
                    } else {
                        startRangeDay.fillStartRange()
                        startRangeDay.view?.configure(with: config.day, day: startRangeDay, calendarType: grid.calendarType)
                        
                        day.endRange()
                        day.view?.configure(with: config.day, day: day, calendarType: grid.calendarType)
                        
                        let inRangeDays = allDays.filter { $0.date > startRangeDay.date && $0.date < day.date && $0.canSelect }
                        
                        inRangeDays.forEach { data in
                            data.setInRange()
                            data.view?.configure(with: config.day, day: data, calendarType: grid.calendarType)
                        }
                                  
                        calendarDelegate?.didSelectRange?(startRangeDay.date, endDate: day.date)
                    }
                    
                } else {
                    allDays.forEach { data in
                        data.resetIndicator()
                        data.view?.configure(with: config.day, day: data, calendarType: grid.calendarType)
                    }
                    
                    day.startRange()
                    day.view?.configure(with: config.day, day: day, calendarType: grid.calendarType)
                }
                
                
            case .many:
                day.select()
                day.view?.configure(with: config.day, day: day, calendarType: grid.calendarType)
                calendarDelegate?.didSelectDate?(day.date)
            }
        } else {
            calendarDelegate?.didSelectDate?(tappedMonth.startMonthDate)
        }
    }
    
    private func calculateMonths() {
        guard let data = data else { return }
        
        var column = 0
        var row = 0
        
        for month in data.months.enumerated() {
            // Months Calculation
            let isLastInRow = month.offset != 0 && column == grid.calendarType.matrix(isPortait: isPortrait).columns - 1
            
            if isLastInRow || (month.element.isFirstMonthInYear && month.offset != 0) {
                row += 1
                column = 0
            } else if month.offset != 0 {
                column += 1
            }
            
            let position = GridPostion(row: row, column: column)
            let monthRect = grid.monthRect(
                for: month.offset,
                data: data,
                position: position,
                showTitle: config.month.showTitle,
                yearNumber: month.element.yearNumber,
                rectSize: scrollView.frame.size,
                isPortrait: isPortrait,
                showDaysOut: config.month.showDaysOut
            )
            month.element.gridPosition = position
            month.element.rect = monthRect
            
            for week in month.element.weeks.enumerated() where config.month.showDaysOut || week.offset <= month.element.numberOfWeeks - 1 {
                // Weeks Calculation
                let weekRect = grid.weekRect(for: week.offset, showTitle: config.month.showTitle, monthRect: monthRect)
                week.element.rect = weekRect
                
                for day in week.element.days.enumerated() {
                    // Days Calculation
                    day.element.rect = grid.dayRect(for: day.offset, weekRect: weekRect)
                }
            }
        }
    }
    
    private func drawVisibleMonths(visibleRect: CGRect) {
        for monthData in (data?.months ?? []) where monthData.view == nil && monthData.rect.intersects(visibleRect) {
            
            let monthView = UIView(frame: monthData.rect)
            scrollView.addSubview(monthView)
            monthData.view = monthView
            
            if monthData.isFirstMonthInYear && grid.calendarType != .oneOnOne && grid.scrollDirection == .vertical {
                let yearHeaderViewRect = grid.yearHeaderRect(monthRect: monthData.rect, containerRect: frame)
                let yearHeaderView = YearHeaderView(frame: yearHeaderViewRect)
                yearHeaderView.configure(
                    with: config.yearHeader,
                    isCurrentYear: monthData.isCurrentYear,
                    yearDate: monthData.startMonthDate,
                    calendarType: grid.calendarType
                )
                scrollView.addSubview(yearHeaderView)
            }
            
            if config.month.showTitle {
                let monthHeaderView = MonthHeaderView(frame: grid.monthHeaderRect(monthWidth: monthData.rect.width))
                monthHeaderView.configure(with: config.monthTitle, monthData: monthData, calendarType: grid.calendarType)
                monthView.addSubview(monthHeaderView)
            }
            
            monthData.weeks.forEach { week in
                guard week.rect != .zero else { return }
                
                let weekView = UIView(frame: week.rect)
                week.view = weekView
                monthView.addSubview(weekView)
                
                week.days.forEach { day in
                    if config.month.showDaysOut || monthData.containsDate(day.date) {
                        let dayView = DayView(frame: day.rect)
                        day.view = dayView
                        dayView.configure(with: config.day, day: day, calendarType: grid.calendarType)
                        weekView.addSubview(dayView)
                    }
                }
            }
        }
        
        if let month = data?.months
            .sorted(by: { $0.rect.origin.x < $1.rect.origin.x })
            .first(where: { $0.rect.intersects(visibleRect) }) {
            calendarDelegate?.didUpdateDisplayedDate?(month.startMonthDate)
        }
    }
    
    private func calculateContentSize() {
        guard let data = data else {
            scrollView.contentSize = .zero
            return
        }
        
        let gridSize = grid.contentSize(
            for: data,
            rectSize: scrollView.frame.size,
            showTitle: config.month.showTitle,
            isPortrait: isPortrait,
            showDaysOut: config.month.showDaysOut
        )
        scrollView.contentSize = gridSize
    }
    
    private func setDays(_ days: [String]) {
        daysStackView.arrangedSubviews.forEach {
            daysStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
                
        for day in days {
            let label = UILabel()
            label.text = day.uppercased()
            label.font = config.daySymbols.font
            label.textColor = config.daySymbols.textColor
            label.textAlignment = config.daySymbols.textAlignment
            daysStackView.addArrangedSubview(label)
        }
        
        let inset = (scrollView.frame.width - (CGFloat(grid.calendarType.matrix(isPortait: isPortrait).columns) * grid.calendarType.monthSize(showTitle: config.month.showTitle).width)) / 2
        daysStackView.frame.origin.x = inset
        daysStackView.frame.size = CGSize(width: frame.width - (inset * 2), height: config.daySymbols.height)
        daysSymbolsSeparatorView.frame = CGRect(x: 0, y: daysStackView.frame.maxY, width: scrollView.frame.width, height: 1)
        daysSymbolsSeparatorView.backgroundColor = config.daySymbols.separatorColor
    }
    
    private func animateTransition() {
        let transition = CATransition()
        transition.duration = 0.2
        transition.timingFunction = CAMediaTimingFunction(name: .easeIn)
        transition.type = .fade
        layer.add(transition, forKey: nil)
    }
}

extension CalendarView: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.frame.size)
        drawVisibleMonths(visibleRect: visibleRect)
    }
}
