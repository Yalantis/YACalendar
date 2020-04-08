//
//  Grid.swift
//  YALCalendar
//
//  Created by Vodolazkyi Anton on 1/31/20.
//  Copyright © 2020 yalantis. All rights reserved.
//

import UIKit

public class Grid {
 
    public var calendarType: CalendarType = .oneOnOne
    public var scrollDirection: ScrollDirection = .horizonal

    private let daysInWeek = 7
    
    func contentSize(
        for data: CalendarData,
        rectSize: CGSize,
        showTitle: Bool,
        isPortrait: Bool,
        showDaysOut: Bool) -> CGSize {
        let matrix = calendarType.matrix(isPortait: isPortrait)
         
        switch scrollDirection {
        case .horizonal where calendarType == .week:
            let height = calendarType.weekHeight + calendarType.firstWeekTopInset
            var width: CGFloat = 0.0
            
            for monthData in data.months.enumerated() {
                let monthWidthData = monthWidthInWeekView(for: monthData.element, monthIndex: monthData.offset, rectSize: rectSize)
                
                if let firstXOffset = monthWidthData.x {
                    width += firstXOffset
                }
                width += monthWidthData.width
            }
            return CGSize(width: width, height: height)
            
        case .horizonal:
            let itemsPerPage = matrix.columns * matrix.rows
            let pages = (CGFloat(data.months.count) / CGFloat(itemsPerPage)).rounded(.up)
            let width = pages * rectSize.width
            return CGSize(width: width, height: rectSize.height)
            
        case .vertical:
            let maxYear = CGFloat(data.months.max(by: { $0.yearNumber < $1.yearNumber })?.yearNumber ?? 0)
            let heightOfYearHeaders = maxYear * calendarType.yearHeaderHeight
            
            if calendarType == .oneOnOne && showDaysOut == false {
                var height: CGFloat = calendarType.monthVerticalInset + heightOfYearHeaders
                
                for month in data.months {
                    height += calendarType.monthSize(showTitle: showTitle, numberOfWeeks: month.numberOfWeeks).height + calendarType.monthVerticalInset
                }
                return CGSize(width: rectSize.width, height: height)
            } else {
                let maxRow = CGFloat(data.months.max(by: { $0.gridPosition.row < $1.gridPosition.row })?.gridPosition.row ?? 0) + 1  // because row starts from 0
                let height = maxRow * (calendarType.monthSize(showTitle: showTitle).height + calendarType.monthVerticalInset) + calendarType.monthVerticalInset + heightOfYearHeaders
                return CGSize(width: rectSize.width, height: height)
            }
        }
    }

    func monthRect(
        for index: Int,
        data: CalendarData,
        position: GridPostion,
        showTitle: Bool,
        yearNumber: Int,
        rectSize: CGSize,
        isPortrait: Bool,
        previousMonthMaxX: CGFloat,
        showDaysOut: Bool) -> CGRect {
        let matrix = calendarType.matrix(isPortait: isPortrait)
        let monthSize = calendarType.monthSize(showTitle: showTitle)
        let leadingInset = (rectSize.width - (CGFloat(matrix.columns) * monthSize.width)) / CGFloat(matrix.columns + 1)

        switch scrollDirection {
        case .horizonal where calendarType == .week:
            var x: CGFloat = 0.0
            let month = data.months[index]
            let monthWidthData = monthWidthInWeekView(for: month, monthIndex: index, rectSize: rectSize)

            if let xValue = monthWidthData.x {
                x = xValue
            } else {
                x = previousMonthMaxX
            }
            
            let size = CGSize(
                    width: monthWidthData.width,
                    height: calendarType.firstWeekTopInset + calendarType.weekHeight
                )
            
            let originPoint = CGPoint(x: x, y: 0)
            return CGRect(origin: originPoint, size: size)
            
        case .horizonal:
            let xIndexOffset = CGFloat(index / (matrix.columns * matrix.rows)) * rectSize.width
            let leading = leadingInset * (CGFloat(index % matrix.columns) + 1)
            let x = leading + xIndexOffset + CGFloat(index % matrix.columns) * monthSize.width
            let monthInset = (CGFloat((index / matrix.columns) % matrix.rows) + 1) * calendarType.monthVerticalInset
            let y = CGFloat((index / matrix.columns) % matrix.rows) * monthSize.height + monthInset
            let originPoint = CGPoint(x: x, y: y)
            return CGRect(origin: originPoint, size: monthSize)

        case .vertical:
            let leading = leadingInset * (CGFloat(position.column) + 1)
            let x = (CGFloat(position.column) * monthSize.width) + leading
            
            if calendarType == .oneOnOne && showDaysOut == false {
                var y: CGFloat = 0
                var monthSize: CGSize = .zero
                
                for monthData in data.months.enumerated() {
                    y += calendarType.monthVerticalInset
                    
                    if monthData.offset == index {
                        monthSize = calendarType.monthSize(showTitle: showTitle, numberOfWeeks: monthData.element.numberOfWeeks)
                        break
                    }
                    y += calendarType.monthSize(showTitle: showTitle, numberOfWeeks: monthData.element.numberOfWeeks).height
                }
                
                let originPoint = CGPoint(x: x, y: y)
                return CGRect(origin: originPoint, size: monthSize)
                
            } else {
                let yearOffset = CGFloat(yearNumber) * calendarType.yearHeaderHeight
                let y = (CGFloat(position.row) * monthSize.height) + (CGFloat(position.row + 1) * calendarType.monthVerticalInset) + yearOffset
                let originPoint = CGPoint(x: x, y: y)
                return CGRect(origin: originPoint, size: monthSize)
            }
        }
    }
    
    func weekRectForWeekView(monthData: MonthData, weekIndex: Int, screenWidth: CGFloat, previousWeekEndX: CGFloat) -> CGRect {
        let isFirstWeek = weekIndex == 0
        let dayWidth: CGFloat = screenWidth / CGFloat(daysInWeek)
        var weekWidth: CGFloat = dayWidth * CGFloat(daysInWeek)
        let daysInCurrentWeek = monthData.weeks[weekIndex].days.filter { $0.state != .out }
        let isLastWeek = isFirstWeek == false && daysInCurrentWeek.count != daysInWeek

        if isFirstWeek || isLastWeek {
            weekWidth = CGFloat(daysInCurrentWeek.count) * (dayWidth)
        }
        
        return CGRect(
            x: previousWeekEndX,
            y: calendarType.firstWeekTopInset,
            width: weekWidth,
            height: calendarType.weekHeight
        )
    }
    
    func weekRect(for weekIndex: Int, showTitle: Bool, rect: CGRect) -> CGRect {
        var weekSize = CGSize(width: rect.width, height: calendarType.weekHeight)
        weekSize.width -= calendarType.weekInset.left + calendarType.weekInset.right
        
        let x: CGFloat = calendarType.weekInset.left
        let titleInset = showTitle ? calendarType.firstWeekTopInset : calendarType.weekInset.top
        let y: CGFloat = titleInset + (calendarType.weekInset.top * CGFloat(weekIndex)) + (CGFloat(weekIndex) * weekSize.height)
        return CGRect(origin: CGPoint(x: x, y: y), size: weekSize)
    }
    
    func dayRect(for dayIndex: Int, weekRect: CGRect) -> CGRect {
        let daySize = CGSize(
            width: ((weekRect.width - (calendarType.distanceBetweenDays * CGFloat(daysInWeek - 1))) / CGFloat(daysInWeek)),
            height: weekRect.height
        )
        let x: CGFloat = (CGFloat(dayIndex) * daySize.width) + (calendarType.distanceBetweenDays * CGFloat(dayIndex))
        let y: CGFloat = 0.0
        return CGRect(origin: CGPoint(x: x, y: y), size: daySize)
    }
    
    func dayRectForWeekView(for dayIndex: Int, weekRect: CGRect, screenWidth: CGFloat) -> CGRect {
        let dayWidth: CGFloat = screenWidth / CGFloat(daysInWeek)
        
        let daySize = CGSize(
            width: dayWidth,
            height: weekRect.height
        )
        let x: CGFloat = (CGFloat(dayIndex) * daySize.width)
        let y: CGFloat = 0.0
        return CGRect(origin: CGPoint(x: x, y: y), size: daySize)
    }
    
    func yearHeaderRect(monthRect: CGRect, containerRect: CGRect) -> CGRect {
        return CGRect(
            x: monthRect.origin.x,
            y: monthRect.origin.y - (calendarType.yearHeaderHeight + calendarType.monthVerticalInset / 2),
            width: containerRect.width - (monthRect.origin.x * 2),
            height: calendarType.yearHeaderHeight
        )
    }
    
    func monthHeaderRect(monthWidth: CGFloat) -> CGRect {
        switch calendarType {
        case .oneOnOne: return CGRect(x: 0, y: 0, width: monthWidth, height: 46)
        case .twoOnThree: return CGRect(x: 0, y: 0, width: monthWidth, height: 27)
        case .threeOnFour: return CGRect(x: 0, y: 0, width: monthWidth, height: 20)
        case .week: return CGRect(x: 0, y: 8, width: monthWidth, height: 20)
        }
    }
    
    func originForMonth(
        with monthIndex: Int,
        position: GridPostion,
        data: CalendarData,
        yearNumber: Int,
        showTitle: Bool,
        rectSize: CGSize,
        isPortrait: Bool,
        showDaysOut: Bool) -> CGPoint {
        let matrix = calendarType.matrix(isPortait: isPortrait)
        
        switch scrollDirection {
        case .horizonal:
            let itemsPerPage = matrix.columns * matrix.rows
            let page = (CGFloat(monthIndex) / CGFloat(itemsPerPage)).rounded(.down)
            return CGPoint(x: page * rectSize.width, y: 0)
            
        case .vertical:
            if calendarType == .oneOnOne && showDaysOut == false {
                var y: CGFloat = 0
                
                for monthData in data.months.enumerated() {
                    y += calendarType.monthVerticalInset
                    
                    if monthData.offset == monthIndex {
                        break
                    }
                    y += calendarType.monthSize(showTitle: showTitle, numberOfWeeks: monthData.element.numberOfWeeks).height
                }
                
                return CGPoint(x: 0, y: y)

            } else {
                let row = CGFloat(position.row)
                let yearOffset = CGFloat(yearNumber) * calendarType.yearHeaderHeight
                let y = (row * calendarType.monthSize(showTitle: showTitle).height) + (row * calendarType.monthVerticalInset) + yearOffset
                return CGPoint(x: 0, y: y)
            }
        }
    }
}

extension Grid {
    
    private func monthWidthInWeekView(for monthData: MonthData, monthIndex: Int, rectSize: CGSize) -> (width: CGFloat, x: CGFloat?) {
        var width: CGFloat = 0.0
        var firstMonthX: CGFloat? = nil

        for weekData in monthData.weeks.enumerated() {
            width += weekRectForWeekView(
                monthData: monthData,
                weekIndex: weekData.offset,
                screenWidth: rectSize.width,
                previousWeekEndX: 0
            ).width
        }
        
        if monthIndex == 0 {
            firstMonthX = rectSize.width - weekRectForWeekView(
                monthData: monthData,
                weekIndex: 0,
                screenWidth: rectSize.width,
                previousWeekEndX: 0
            ).width
        }
        
        return (width, firstMonthX)
    }
}
