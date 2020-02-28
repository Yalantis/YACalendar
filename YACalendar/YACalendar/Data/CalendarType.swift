//
//  CalendarType.swift
//  YALCalendar
//
//  Created by Vodolazkyi Anton on 2/6/20.
//  Copyright © 2020 yalantis. All rights reserved.
//

import UIKit

fileprivate let isMaxScreen = UIScreen.main.bounds.width == 414
fileprivate let maxNumberOfWeeks = 6

public enum CalendarType {
    case oneOnOne, twoOnThree, threeOnFour
    
    func monthSize(showTitle: Bool, numberOfWeeks: Int = maxNumberOfWeeks) -> CGSize {
        var size: CGSize = .zero
        let titleInset = showTitle ? firstWeekTopInset : weekInset.top
        size.height += (titleInset + (CGFloat(numberOfWeeks) * (weekInset.top + weekHeight))) + weekInset.bottom
        
        switch self {
        case .oneOnOne where isMaxScreen: size.width = 366
        case .oneOnOne: size.width = 320
        case .twoOnThree: size.width = 164
        case .threeOnFour: size.width = 110
        }
        
        return size
    }
    
    var firstWeekTopInset: CGFloat {
        switch self {
        case .oneOnOne: return 46
        case .twoOnThree: return 29
        case .threeOnFour: return 22
        }
    }
    
    var monthVerticalInset: CGFloat {
        switch self {
        case .oneOnOne: return isMaxScreen ? 16 : 8
        case .twoOnThree: return 8
        case .threeOnFour: return 8
        }
    }
    
    var monthTitleInset: UIEdgeInsets {
        switch self {
        case .oneOnOne: return UIEdgeInsets(top: 6, left: 8, bottom: 17, right: 6)
        case .twoOnThree: return UIEdgeInsets(top: 4, left: 4, bottom: 2, right: 4)
        case .threeOnFour: return UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        }
    }
    
    var weekInset: UIEdgeInsets {
        switch self {
        case .oneOnOne where isMaxScreen: return UIEdgeInsets(top: 4, left: 8, bottom: 8, right: 8)
        case .oneOnOne: return UIEdgeInsets(top: 0, left: 6, bottom: 6, right: 6)
        case .twoOnThree: return UIEdgeInsets(top: 2, left: 4, bottom: 0, right: 4)
        case .threeOnFour: return UIEdgeInsets(top: 2, left: 4, bottom: 0, right: 4)
        }
    }
    
    var weekHeight: CGFloat {
        switch self {
        case .oneOnOne: return 44
        case .twoOnThree: return 22
        case .threeOnFour: return 14
        }
    }
    
    var yearHeaderHeight: CGFloat {
        switch self {
        case .oneOnOne: return 0
        case .twoOnThree: return 46
        case .threeOnFour: return 46
        }
    }
    
    var distanceBetweenDays: CGFloat {
        if self == .oneOnOne && isMaxScreen {
            return 7
        }
        return 0
    }
    
    func matrix(isPortait: Bool) -> (columns: Int, rows: Int) {
        switch self {
        case .oneOnOne: return (1, 1)
        case .twoOnThree where isPortait: return (2, 3)
        case .twoOnThree: return (3, 1)
        case .threeOnFour where isPortait: return (3, 4)
        case .threeOnFour: return (5, 1)
        }
    }
}
