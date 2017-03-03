//
//  DateTime.swift
//  Hitch
//
//  Created by Brandon Price on 2/2/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

//
//  DateTime.swift
//  Hitch
//
//  Created by Brandon Price on 2/2/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation

// Class for easily handling dates and times.
class DateTime {
    
    var month : Int = 0
    var day : Int = 0
    var year : Int = 0
    var hour : Int = 0
    var minute : Int = 0
    var weekDay : Int = 0
    var date : Date
    
    class func cal () -> Calendar {
        var cal = Calendar(identifier: Calendar.Identifier.gregorian)
        cal.timeZone = TimeZone.autoupdatingCurrent
        return cal
    }
    
    static let longMonths = DateFormatter().monthSymbols!
    static let shortMonths = DateFormatter().shortMonthSymbols!
    static let longWeekDays = DateFormatter().weekdaySymbols!
    static let shortWeekDays = DateFormatter().shortWeekdaySymbols!
    static let shortestWeekDays = DateFormatter().veryShortWeekdaySymbols
    static let currentDateTime = DateTime(date: Date())
    
    // String initializer.
    init (format: String, dateString: String) {
        
        // Format it and then get components.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = (dateFormatter.date(from: dateString))!
        let components = DateTime.cal().dateComponents([.month,.day,.year,.hour,.minute,.weekday,.timeZone], from: date)
        
        // Set values to components.
        self.month = components.month!
        self.day = components.day!
        self.year = components.year!
        self.hour = components.hour!
        self.minute = components.minute!
        self.weekDay = components.weekday!
        self.date = date
    }
    
    // Date initializer.
    init (date: Date) {
        
        // Get components from date and set the values.
        let components = DateTime.cal().dateComponents([.month,.day,.year,.hour,.minute,.weekday], from: date)
        
        // Set values to components.
        self.month = components.month!
        self.day = components.day!
        self.year = components.year!
        self.hour = components.hour!
        self.minute = components.minute!
        self.weekDay = components.weekday!
        self.date = date
    }
    
    init (month: Int, day: Int, year: Int, hour: Int, minute: Int) {
        
        var monthString = String(month)
        var dayString = String(day)
        let yearString = String(year)
        var hourString = String(hour)
        var minuteString = String(minute)
        
        if month < 10 {
            monthString = "0" + monthString
        }
        
        if day < 10 {
            dayString = "0" + dayString
        }
        
        if hour < 10 {
            hourString = "0" + hourString
        }
        
        if minute < 10 {
            minuteString = "0" + minuteString
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let date = (dateFormatter.date(from: dayString+"-"+monthString+"-"+yearString+" "+hourString+":"+minuteString))!
        let components = DateTime.cal().dateComponents([.month,.day,.year,.hour,.minute,.weekday], from: date)
        
        // Set values to components.
        self.month = components.month!
        self.day = components.day!
        self.year = components.year!
        self.hour = components.hour!
        self.minute = components.minute!
        self.weekDay = components.weekday!
        self.date = date
    }
    
    init () {
        self.date = Date()
    }
    
    func storeDate () {
        
        var monthString = String(month)
        var dayString = String(day)
        let yearString = String(year)
        var hourString = String(hour)
        var minuteString = String(minute)
        
        if month < 10 {
            monthString = "0" + monthString
        }
        
        if day < 10 {
            dayString = "0" + dayString
        }
        
        if hour < 10 {
            hourString = "0" + hourString
        }
        
        if minute < 10 {
            minuteString = "0" + minuteString
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        var dateString = dayString + "-"
        dateString += monthString
        dateString += "-"
        dateString += yearString
        dateString += " "
        dateString += hourString
        dateString += ":"
        dateString += minuteString
        let date = (dateFormatter.date(from: dateString))!
        
        self.date = date
    }
    
    // For uploading to back end.
    func getJSONRepresentation () -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let dateString = dateFormatter.string(from: self.date)
        
        print(dateString)
        let result = dateString.replacingOccurrences(of: " ", with: "T") + ":00Z"
        
        return result
    }
    
    // Load from JSON representation.
    class func loadFromJSONRep (jsonRep : String) -> DateTime {
        
        let utcDateFormatter = DateFormatter()
        utcDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        utcDateFormatter.timeZone = TimeZone(identifier: "UTC")
        let utcDate = utcDateFormatter.date(from: jsonRep.replacingOccurrences(of: "T", with: " ").replacingOccurrences(of: "Z", with: ""))
        
        return DateTime(date: utcDate!)
    }
    
    // Get string representations functions.
    func shortMonth () -> String {
        return DateTime.shortMonths[month-1]
    }
    
    func longMonth () -> String {
        return DateTime.longMonths[month-1]
    }
    
    func shortWeekDay () -> String {
        return DateTime.shortWeekDays[weekDay-1]
    }
    
    func longWeekDay () -> String {
        return DateTime.longWeekDays[weekDay-1]
    }
    
    func time () -> String {
        
        var amPm = "am"
        var minute = "00"
        var hour = "1"
        
        // Configure hour.
        if self.hour > 12 {
            amPm = "pm"
            hour = String(self.hour - 12)
            
        } else if self.hour == 12 {
            amPm = "pm"
            hour = String(self.hour)
        } else if self.hour == 0 {
            hour = "12"
            amPm = "am"
        } else {
            amPm = "am"
            hour = String(self.hour)
        }
        
        // Configure minutes.
        if self.minute < 10 {
            minute = "0" + String(self.minute)
        } else {
            minute = String(self.minute)
        }
        
        return hour + ":" + minute + " " + amPm
    }
    
    func abbreviatedDate () -> String {
        return String(month) + "/" + String(day) + "/" + String(year)
    }
    
    func fullDate () -> String {
        return longMonth() + " " + String(day) + ", " + String(year)
    }
    
    // Calculation functions.
    func isDaysAheadOf (dateTime2: DateTime) -> Bool {
        return (self.year > dateTime2.year) || (self.year == dateTime2.year && self.month > dateTime2.month) || (self.year == dateTime2.year && self.month == dateTime2.month && self.day > dateTime2.day)
    }
    
    func isSameDayAs (dateTime2: DateTime) -> Bool {
        
        return (self.year == dateTime2.year && self.month == dateTime2.month && self.day == dateTime2.day)
    }
    
    func isDaysBehindOf (dateTime2: DateTime) -> Bool {
        
        return !(self.isSameDayAs(dateTime2: dateTime2) || self.isDaysAheadOf(dateTime2: dateTime2))
    }
    
    // Use to add time to get a new datetime.
    func add (years: Int, months: Int, days: Int, hours: Int, minutes: Int) -> DateTime {
        
        let date1 = DateTime.cal().date(byAdding: .hour, value: hours, to: self.date)
        let date2 = DateTime.cal().date(byAdding: .minute, value: minutes, to: date1!)
        let date3 = DateTime.cal().date(byAdding: .day, value: days, to: date2!)
        let date4 = DateTime.cal().date(byAdding: .month, value: months, to: date3!)
        let date5 = DateTime.cal().date(byAdding: .year, value: years, to: date4!)
        
        return DateTime(date: date5!)
    }
    
    // Add time interval
    func addTimeInterval (timeInteral: TimeInterval) -> DateTime {
        
        let seconds = Int(timeInteral)
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: seconds)
        return self.add(years: 0, months: 0, days: 0, hours: h, minutes: m + Int(Double(s)/60.0))
    }
    
    func subtractTimeInterval (timeInteral: TimeInterval) -> DateTime {
        
        let seconds = Int(timeInteral)
        let (h,m,s) = secondsToHoursMinutesSeconds(seconds: seconds)
        let resultDateTime = self.add(years: 0, months: 0, days: 0, hours: -h, minutes: -m - Int(Double(s)/60.0))
        
        return resultDateTime
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    // Use to jump to next occurring week day.
    func nextOccurrenceOf (weekDay: Int) -> DateTime {
        
        var daysAhead : Int = 0
        
        for n in Array(1...7) {
            
            if (self.weekDay + n) % 7 == weekDay {
                daysAhead = n + 1
                break
            }
        }
        
        return self.add(years: 0, months: 0, days: daysAhead, hours: 0, minutes: 0)
    }
    
    // Calculate interval.
    class func timeBetween (dateTime1: DateTime, dateTime2: DateTime) -> TimeInterval {
        return abs(dateTime1.date.timeIntervalSince(dateTime2.date))
    }
    
    func startOfMonth() -> DateTime {
        return DateTime(date: Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self.date)))!)
    }
    
    func endOfMonth() -> DateTime {
        return DateTime(date: Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth().date)!)
    }
}

/*
let dateTime = DateTime(format: "dd/MM/yyyy HH:mm", dateString: "13/11/1994 14:59")
dateTime.time()
 */


