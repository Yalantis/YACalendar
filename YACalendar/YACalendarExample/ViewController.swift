//
//  ViewController.swift
//  YACalendar
//
//  Created by Vodolazkyi Anton on 1/31/20.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

enum ViewType {
    case week, month, year
}

class ViewController: UIViewController {
    
    @IBOutlet private var calendarView: CalendarView!
    @IBOutlet private var yearBarButton: UIBarButtonItem!
    @IBOutlet private var yearLabel: UILabel!
    @IBOutlet private var calendarTrailingConstraint: NSLayoutConstraint!

    private var viewType: ViewType = .week
    private var settings = CalendarSettings()
    private let calendar = Calendar.current

    private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.calendarDelegate = self
        applySettings()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SettingsViewController {
            controller.settings = settings
            controller.applySettings = { [weak self] in
                self?.applySettings()
            }
        }
    }
    
    @IBAction func changeViewType(_ sender: UIBarButtonItem) {
        viewType = viewType == .month ? .year : .month
        applySettings()
    }
    
    private func updateCalendarSize() {
        calendarTrailingConstraint.constant = calendarView.isPortrait == false && viewType == .month ? view.frame.width / 2 : 0
        view.layoutIfNeeded()
    }
    
    private func applySettings() {
        calendarView.grid.scrollDirection = settings.scrollDirection
        calendarView.selectionType = settings.selectionType

        if #available(iOS 13.0, *) {
            yearBarButton.image = viewType == .month ? UIImage(systemName: "chevron.left") : nil
        }
        
        switch viewType {
        case .week:
            calendarView.grid.calendarType = .week
            calendarView.isPagingEnabled = true
            calendarView.config.month.showDaysOut = false
            calendarView.config.month.showTitle = false
            calendarView.config.daySymbols.height = 14
            calendarView.config.daySymbols.separatorColor = .clear

        case .month:
            calendarView.grid.calendarType = .oneOnOne
            calendarView.isPagingEnabled = settings.isPagingEnabled
            calendarView.config.month.showDaysOut = settings.showDaysOut

            let formetter = DateFormatter()
            formetter.dateFormat = "MMMM"
            calendarView.config.monthTitle.formatter = formetter
            calendarView.config.monthTitle.showSeparator = true
            
        case .year:
            calendarView.grid.calendarType = settings.gridType
            calendarView.isPagingEnabled = settings.isPagingEnabled
            calendarView.config.month.showDaysOut = settings.showDaysOut

            let formetter = DateFormatter()
            formetter.dateFormat = settings.gridType == .threeOnFour ? "MMM" : "MMMM"
            calendarView.config.monthTitle.formatter = formetter
            calendarView.config.monthTitle.showSeparator = false
        }
        updateCalendarSize()
        calendarView.data = CalendarData(calendar: calendar, startDate: settings.startDate, endDate: settings.endDate)
    }
}

extension ViewController: CalendarViewDelegate {
    
    func didSelectDate(_ date: Date) {
        if viewType == .year {
            viewType = .month
            calendarView.currentDate = date
            applySettings()
        }
    }
    
    func didSelectRange(_ startDate: Date, endDate: Date) {
        print("did select range \(startDate) - \(endDate)")
    }
    
    func didUpdateDisplayedDate(_ date: Date) {
        yearLabel.text = yearFormatter.string(from: date)
        yearLabel.isHidden = viewType == .year
    }
    
    func didChangeOrientation(_ isPortrait: Bool) {
        updateCalendarSize()
    }
}
 
