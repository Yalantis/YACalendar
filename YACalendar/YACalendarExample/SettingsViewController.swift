//
//  SettingsViewController.swift
//  YACalendar
//
//  Created by Vodolazkyi Anton on 2/3/20.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit
import YACalendar

class CalendarSettings {
    var gridType: CalendarType = .threeOnFour
    var scrollDirection: ScrollDirection = .vertical
    var startDate = Calendar.current.date(byAdding: .year, value: -3, to: Date())!
    var endDate = Calendar.current.date(byAdding: .year, value: 3, to: Date())!
    var isPagingEnabled: Bool = false
    var showDaysOut: Bool = true
    var selectionType: SelectionType = .range
}


class SettingsViewController: UIViewController {
    
    @IBOutlet private var directionControl: UISegmentedControl!
    @IBOutlet private var matrixControl: UISegmentedControl!
    @IBOutlet private var startDateField: UITextField!
    @IBOutlet private var endDateField: UITextField!
    @IBOutlet private var daysOutSwitch: UISwitch!
    @IBOutlet private var pagingSwitch: UISwitch!
    @IBOutlet private var selectionTypeControl: UISegmentedControl!

    var settings: CalendarSettings!
    var applySettings: (() -> Void)?
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/yyyy"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
                
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        matrixControl.selectedSegmentIndex = settings.gridType.index
        directionControl.selectedSegmentIndex = settings.scrollDirection == .vertical ? 0 : 1
        startDateField.text = dateFormatter.string(from: settings.startDate)
        endDateField.text = dateFormatter.string(from: settings.endDate)
        daysOutSwitch.isOn = settings.showDaysOut
        pagingSwitch.isOn = settings.isPagingEnabled
        selectionTypeControl.selectedSegmentIndex = settings.selectionType.index
    }
    
    @IBAction private func applyChanges() {
        settings.scrollDirection = directionControl.selectedSegmentIndex == 0 ? .vertical : .horizonal
        settings.startDate = dateFormatter.date(from: startDateField.text!)!
        settings.endDate = dateFormatter.date(from: endDateField.text!)!
        settings.showDaysOut = daysOutSwitch.isOn
        settings.isPagingEnabled = pagingSwitch.isOn
        settings.gridType = CalendarType(index: matrixControl.selectedSegmentIndex)
        settings.selectionType = SelectionType(index: selectionTypeControl.selectedSegmentIndex)
        
        applySettings?()
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension CalendarType {

    init(index: Int) {
        switch index {
        case 0: self = .twoOnThree
        case 1: self = .threeOnFour
        default: self = .oneOnOne
        }
    }
    
    var index: Int {
        switch self {
        case .oneOnOne: return 2
        case .twoOnThree: return 0
        case .threeOnFour: return 1
        }
    }
}

extension SelectionType {

    init(index: Int) {
        switch index {
        case 0: self = .one
        case 1: self = .many
        default: self = .range
        }
    }
    
    var index: Int {
        switch self {
        case .one: return 0
        case .many: return 1
        case .range: return 2
        }
    }
}

