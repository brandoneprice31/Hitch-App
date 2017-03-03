//
//  DCTimeVC.swift
//  Hitch
//
//  Created by Brandon Price on 2/8/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import UIKit

class DCTimeVC: UIViewController {

    var defaultTime : Date? = nil
    @IBOutlet var timePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        timePicker.setValue(navyColor, forKey: "textColor")
        if defaultTime != nil {
            timePicker.date = defaultTime!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Function that returns the minutes and hours.
    func getTime () -> (Int,Int) {
        let dateTime = DateTime(date: timePicker.date)
        return (dateTime.minute, dateTime.hour)
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
