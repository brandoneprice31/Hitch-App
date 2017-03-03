//
//  DCOccurrenceVC.swift
//  Hitch
//
//  Created by Brandon Price on 2/8/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import UIKit

class DCOccurrenceVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var occurrenceLabel: UILabel!
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var weekDaysView: WeekDaysView!
    @IBOutlet var datePicker: UIPickerView!

    var currentDate = DateTime(date: Date())
    var pickerDate = DateTime(date: Date())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        weekDaysView.alpha = 1.0
        datePicker.alpha = 0.0
        weekDaysView.configure(selectedDays: [], disabledDays: [], touchesAllowed: true)
        
        // Configure DatePicker
        datePicker.selectRow(currentDate.month - 1, inComponent: 0, animated: false)
        datePicker.selectRow(currentDate.day - 1, inComponent: 1, animated: false)
        datePicker.selectRow(currentDate.year - 1 - 2017, inComponent: 2, animated: false)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segmentControlValueChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            // Yes
            UIView.animate(withDuration: 0.3, animations: {
                self.occurrenceLabel.text = "Which days of the week?"
                self.weekDaysView.alpha = 1.0
                self.datePicker.alpha = 0.0
            })
            
        } else {
            // No
            UIView.animate(withDuration: 0.3, animations: {
                self.occurrenceLabel.text = "Which day?"
                self.weekDaysView.alpha = 0.0
                self.datePicker.alpha = 1.0
            })
        }
        
    }
    
    // Components in Picker View.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    // Rows in Component of Picker.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            // Month
            return DateTime.longMonths.count
            
        } else if component == 1 {
            // Day
            let daysOfMonth = DateTime.cal().range(of: .day, in: .month, for: pickerDate.date)
            let arr = Array(daysOfMonth!.lowerBound...daysOfMonth!.upperBound-1)
            return arr.count
            
        } else {
            // Year
            return 150
        }
    }
    
    // View for row.
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = UILabel()
        
        var title = ""
        
        if component == 0 {
            // Month
            title = DateTime.shortMonths[row]
            
        } else if component == 1 {
            // Day
            let daysOfMonth = DateTime.cal().range(of: .day, in: .month, for: pickerDate.date)
            let arr = Array(daysOfMonth!.lowerBound...daysOfMonth!.upperBound-1)
            
            title = String(arr[row])
            
        } else {
            // Year
            title = Array(2017...2200).map({x -> String in return String(x)})[row]
        }
        
        label.text = title
        label.font = UIFont(name: "System", size: 17.0)
        label.textAlignment = .center
        label.textColor = navyColor
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateMonthInPicker()
        
        if component == 0 {
            // Change the days for a new month.
            pickerView.reloadComponent(1)
        }
    }
    
    // updateMonthInPicker
    func updateMonthInPicker () {
        
        let month = datePicker.selectedRow(inComponent: 0) + 1
        let day = 1
        let year = datePicker.selectedRow(inComponent: 2)
        
        
        var monthString = String(month)
        var dayString = String(day)
        let yearString = String(year + 2017)
        
        if month < 10 {
            monthString = "0" + monthString
        }
        
        if day < 10 {
            dayString = "0" + dayString
        }
        pickerDate = DateTime(format: "dd-MM-yyyy", dateString: dayString + "-" + monthString + "-" + yearString)
    }
    
    // Function for getting the selected date.
    func getSelectedDate () -> DateTime {
        
        let month = datePicker.selectedRow(inComponent: 0) + 1
        let day = datePicker.selectedRow(inComponent: 1) + 1
        let year = datePicker.selectedRow(inComponent: 2)
        
        
        var monthString = String(month)
        var dayString = String(day)
        let yearString = String(year + 2017)
        
        if month < 10 {
            monthString = "0" + monthString
        }
        
        if day < 10 {
            dayString = "0" + dayString
        }
    
        return DateTime(format: "dd-MM-yyyy", dateString: dayString + "-" + monthString + "-" + yearString)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
