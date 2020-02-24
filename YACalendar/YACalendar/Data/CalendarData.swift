//
//  CalendarData.swift
//  YALCalendar
//
//  Created by Vodolazkyi Anton on 1/31/20.
//  Copyright © 2020 yalantis. All rights reserved.
//

import Foundation

public class CalendarData {
    
    var months: [MonthData] = []
    
    var allDays: [DayData] {
        months
        .flatMap { $0.weeks }
        .flatMap { $0.days }
    }
    
    let calendar: Calendar

    private let startDate: Date
    private let endDate: Date
    
    public init(
        calendar: Calendar = .current,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) {
        self.calendar = calendar
        self.startDate = startDate ?? calendar.date(byAdding: .year, value: -1, to: Date())!
        self.endDate = endDate ?? calendar.date(byAdding: .year, value: 1, to: Date())!
        
        initialize()
    }
    
    func day(with date: Date) -> DayData? {
        return allDays
            .filter { $0.canSelect }
            .first(where: { isDate(date, inSameDayAs: $0.date) == true })
    }
    
    func monthData(with date: Date) -> (offset: Int, element: MonthData)? {
        let dateComponents = calendar.dateComponents([.year, .month], from: date)
        return months.enumerated().first(where: { index, month in
            let components = calendar.dateComponents([.year, .month], from: month.startMonthDate)
            return components.year == dateComponents.year && components.month == dateComponents.month
        })
    }
    
    func setEvents(_ events: [CalendarEvent]) -> [DayData] {
        let days = allDays.filter { $0.canSelect }
        
        for day in days {
            day.events = events.filter { calendar.isDate(day.date, inSameDayAs: $0.startDate) || calendar.isDate(day.date, inSameDayAs: $0.endDate) }
        }
        
        return days
    }
    
    func isDate(_ date: Date, inSameDayAs: Date) -> Bool {
        return calendar.isDate(date, inSameDayAs: inSameDayAs)
    }
    
    private func initialize() {
        self.months = generateMonths(from: startDate, initialEndDate: endDate)
    }
    
    private func generateMonths(from initialStartDate: Date, initialEndDate: Date) -> [MonthData] {
        let startComponents = calendar.dateComponents([.year, .month], from: startDate)
        let endComponents = calendar.dateComponents([.year, .month], from: endDate)
        var startDate = calendar.date(from: startComponents)!
        let endDate = calendar.date(from: endComponents)!
        var yearNumber = 1
        var months = [MonthData]()
        
        repeat {
            let date = startDate
            let lastMonthDate = lastMonthDay(from: date)
            let monthWeeks = generateWeeks(from: date, lastMonthDate: lastMonthDate)

            let month = MonthData(
                startMonthDate: date,
                endMonthDate: lastMonthDate,
                weeks: monthWeeks,
                isFirstMonthInYear: calendar.component(.month, from: date) == 1 || calendar.compare(date, to: initialStartDate, toGranularity: .month) == .orderedSame,
                yearNumber: yearNumber,
                isCurrentMonth: calendar.compare(date, to: Date(), toGranularity: .month) == .orderedSame,
                isCurrentYear: calendar.compare(date, to: Date(), toGranularity: .year) == .orderedSame,
                numberOfWeeks: calendar.component(.weekOfMonth, from: lastMonthDate)
            )

            months.append(month)
            startDate = calendar.date(byAdding: .month, value: 1, to: date)!
            
            if calendar.compare(startDate, to: date, toGranularity: .year) == .orderedDescending {
                yearNumber += 1
            }
        } while !calendar.isDate(startDate, inSameDayAs: endDate)
        
        return months
    }
    
    private func generateWeeks(from monthStartDate: Date, lastMonthDate: Date) -> [WeekData] {
        var weeks = [WeekData]()
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: monthStartDate)
        var weekDay = calendar.date(from: components)!
        
        for _ in 0...5 {
            var days = [DayData]()
            for index in 0...6 {
                guard let dayInWeek = calendar.date(byAdding: .day, value: +index, to: weekDay) else { continue }
                let dayState = state(for: dayInWeek, lastMonthDate: lastMonthDate)
                let day = DayData(
                    date: dayInWeek,
                    inFuture: dayInWeek >= Date(),
                    state: dayState,
                    indicator: .none
                )
                days.append(day)
            }
            let week = WeekData(startWeekDate: weekDay, days: days)
            weeks.append(week)
            weekDay = calendar.date(byAdding: .weekOfYear, value: 1, to: weekDay)!
        }
        
        return weeks
    }
    
    private func lastMonthDay(from startMonthDay: Date) -> Date {
        return calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startMonthDay)!
    }
    
    private func state(for date: Date, lastMonthDate: Date) -> DayState {
        if !calendar.isDate(date, equalTo: lastMonthDate, toGranularity: .month) {
            return .out
        }
        
        if calendar.isDateInToday(date) {
            return .today
        }
        
        return .none
    }
}
