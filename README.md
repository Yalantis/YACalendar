## About ![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg)

iOS Calendar with support of year and month view and vertical and horizontal scroll.

## Features
|         | YALCalendar  |
----------|-----------------
✅ | Year view with 2 or 3 columns and month view
✅ | Vertical and horizontal scroll
✅ | Portrait and landscape support
✅ | Paging 
✅ | First weekday Monday or Sunday 
✅ | Show days out 
✅ | One, many or range of days selection
✅ | Ability to disable specific days
✅ | Event indicators

## Example project

Take a look at the example project over [here](Example/)

## Usage

### Adding YALCalendar to your project
#### CocoaPods
Add ```pod 'YACalendar'``` to your Podfile and then make sure to ```import YACalendar``` in your code.

### Creating calendar and providing it with data.

1. Create a calendar view instance and add it to view hierarchy.

```swift
let calendarView = CalendarView(frame: frame)
view.addSubview(calendarView)

```
***NOTE:*** You can use interface builder for creating calendar view. For example check [here](Example/).

2. Create calendar.
If you want to change first day of the week you should change ```firstWeekday``` property.

```swift
let calendar = Calendar.current
calendar.firstWeekday = 2 // 1 - Sunday, 2 - Monday

```

3. Specify calendar grid type and scroll direction.

```swift
calendarView.grid.calendarType = .oneOnOne
calendarView.grid.scrollDirection = .vertical

```

4. Create calendar data object which is an object that contains calendar, start date and end date. Set it to ```data``` property of calendar view. All days will be displayed according to specified calendar and within range of start and end date.

```swift
calendarView.data = CalendarData(calendar: calendar, startDate: startDate, endDate: endDate)

```
***NOTE:*** After setting ```data``` property calendar will be redrawn.

## Examples

### Month view
Month view with vertical and horizontal scroll direction.
<p>
<img src="readme_images/month_view.png" width="30%" height="auto">
</p>

```swift
let calendarView = CalendarView(frame: frame)
calendarView.grid.calendarType = .onOnOne
calendarView.data = CalendarData()

```

### Year view 3 on 4 grid
Year view with 3 on 4 grid for portrait orientation and 5 on 2 for landscape.
<p>
<img src="readme_images/year_view_3_on_4.png" width="30%" height="auto"> <img src="readme_images/year_view_3_on_4_horizontal.png" width="60%" height="auto" hspace="20" align="top">
</p>

```swift
var calendarView = CalendarView(frame: frame)
calendarView.grid.calendarType = .threeOnFour
calendarView.data = CalendarData()

```
    
### Year view 2 on 3 grid
Year view with 2 on 3 grid for portrait orientation and 3 on 1 for landscape.
<p>
<img src="readme_images/year_view_2_on_3.png" width="30%" height="auto"> <img src="readme_images/year_view_2_on_3_horizontal.png" width="60%" height="auto" hspace="20" align="top">
</p>

```swift
let calendarView = CalendarView(frame: frame)
calendarView.grid.calendarType = .twoOnThree
calendarView.data = CalendarData()

```

## Customization

These settings can be set directly on the `CalendarView`.

#### Calendar Properties
| Property                                                | Description                                                                                                                                                                                                                                                                                            |
|---------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **currentDate**: Bool                                  | The date to which calendar should scroll  |
| **selectionType**: SelectionType                       | Type of day selection. Possible values ***one, many, range**<p><img src="readme_images/one_selection.png" width="30%" height="auto"><img src="readme_images/many_selection.png" width="30%" height="auto"><img src="readme_images/range_selection.png" width="30%" height="auto"></p>| 

#### Calendar Methods
| Method                                                | Description                                                                                                                                                                                                                                                                                            |
|---------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **func scroll(to date: Date)**                          | Scroll to month with specified date.  |
| **func selectDay(with date: Date)**                          | Select/deselect day with specified date. Use this method for single selection.  |
| **func selectDays(with dates: [Date])**                      | Select days with specified dates. Use this method for multi selection.  |
| **func selectRange(with startDay: Date, endDate: Date)**     | Select range of days within start and end dates. Use this method for range selection. |
| **func setEvents(_ events: [CalendarEvent])**                | Set events to days with date specified in event. |
| **func disableDays(with dates: [Date])**                     | Disable days with specified dates. |

#### Changing look of the day, month, month header, day symbols or year header
If you want change the font, color or other ui properties of one of the element you must override corresponding element config.

For example: 
To change text color of the day:
1. Inherit DayConfig and override method.

```swift
class MyDayConfig: DayConfig {
    
    override func textColor(for state: DayState, indicator: DayIndicator) -> UIColor {
        return .black
    }
}
```

2. Set config to calendar.
```swift 
calendarView.config.day = MyDayConfig()

```

#### Grid Properties

You can set these settings by calling calendar.grid

| Property                                                | Description                                                                                                                                                                                                                                                                                            |
|---------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **calendarType**: CalendarType                         | Grid representation of months. Possible values ***oneOnOne, twoOnThree, threeOnFour**|
| **scrollDirection**: ScrollDirection                   | Vertical or horizonal scroll direction.| 

## Release Notes

Version 1.0
* Release version.


## Requirements

* Swift 5.0
* Xcode 11.2
* iOS 10.0+

## Installation

#### [CocoaPods](http://cocoapods.org)

```ruby
use_frameworks!

pod 'YACalendar'

```

## License

`YACalendar` is released under an MIT License. See `LICENSE` for details.
