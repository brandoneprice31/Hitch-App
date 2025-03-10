//
//  CustomTableViewCells.swift
//  Hitch
//
//  Created by Brandon Price on 2/2/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation
import UIKit


// For Hiking results page.
class HikeTBVCell : UITableViewCell {
    
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var profPic: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var nonRepeatingDateLabel: UILabel!
    @IBOutlet var weekDaysView: WeekDaysView!
    
    // Function for configuring the cell.
    func configureCell (drive: Drive) {
        
        // Set the pick up time label
        self.timeLabel.text = "*" + drive.estimagedPickUpDateTime!.time() + "*"

        // Configure the collapsed weekdaysview by first filtering to get the disabled days.
        let disabledDays = WeekDaysView.getDisabledDays(notDisabledDays: drive.repeatedWeekDays)
        weekDaysView.configure(selectedDays: drive.repeatedWeekDays, disabledDays: disabledDays, touchesAllowed: false)
        
        // Configure Profile Pic and name.
        profPic.layer.cornerRadius = profPic.frame.size.width / 2.0
        profPic.clipsToBounds = true
        profPic.contentMode =   .scaleAspectFill
        
        profPic.image = drive.driver.getProfileImage()

        nameLabel.text = drive.driver.firstName
        
        // If we repeat then configure the weekDaysView and make it editable.  Otherwise we make it alpha 0.0.
        if drive.repeatedWeekDays != [] {
            
            weekDaysView.alpha = 1.0
            nonRepeatingDateLabel.alpha = 0.0
            
        } else {
            
            weekDaysView.alpha = 0.0
            nonRepeatingDateLabel.alpha = 1.0
            nonRepeatingDateLabel.text = "No Repeat"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class ExpandedHikeCellSchedule : UITableViewCell {
    
    @IBOutlet var startTime: UILabel!
    @IBOutlet var pickUpTime: UILabel!
    @IBOutlet var dropOffTime: UILabel!
    @IBOutlet var endTime: UILabel!
    @IBOutlet var startLocation: UILabel!
    @IBOutlet var pickUpLocation: UILabel!
    @IBOutlet var dropOffLocation: UILabel!
    @IBOutlet var endLocation: UILabel!
    @IBOutlet var lastBox: UILabel!
    
    func configure (drive: Drive, hitch: Hitch) {
        
        // Configure times.
        startTime.text = hitch.adjustedStartDateTime.time()
        pickUpTime.text = hitch.pickUpDateTime.time()
        dropOffTime.text = hitch.dropOffDateTime.time()
        endTime.text = drive.endDateTime.time()
        
        // COnfigure Locations.
        startLocation.text = drive.start.title
        pickUpLocation.text = hitch.pickUpPlace.title
        dropOffLocation.text = hitch.dropOffPlace.title
        endLocation.text = drive.end.title
        
        // Configure last box.
        lastBox.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class ExpandedHikeCellButton : UITableViewCell {
    
    @IBOutlet var occurrenceLabel: UILabel!
    @IBOutlet var weekDaysView: WeekDaysView!
    @IBOutlet var nonRepeatingLabel: UILabel!
    @IBOutlet var hitchButton: UIButton!
    
    func configure (drive: Drive, yesButtonMethod: Selector?, vc: UIViewController) {
        
        if drive.repeatedWeekDays == [] {
            // No repeating.
            weekDaysView.alpha = 0.0
            occurrenceLabel.text = "This ride only occurs on"
            nonRepeatingLabel.alpha = 1.0
            nonRepeatingLabel.text = drive.startDateTime.fullDate()
            
        } else {
            
            // Yes repeating.
            weekDaysView.alpha = 1.0
            occurrenceLabel.text = "Tap days to repeat weekly"
            let disabledDays = WeekDaysView.getDisabledDays(notDisabledDays: drive.repeatedWeekDays)
            weekDaysView.configure(selectedDays: [], disabledDays: disabledDays, touchesAllowed: true)
            nonRepeatingLabel.alpha = 0.0
        }
        
        // Configure Hitch Button.
        if yesButtonMethod != nil {
            hitchButton.addTarget(vc, action: yesButtonMethod!, for: .touchUpInside)
        }
        hitchButton.imageView?.contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// For Hiking Results Page.
class DayTBVCell : UITableViewCell {
    
    @IBOutlet var weekDayLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    func configureCell (weekDay: String, date: String) {
        self.weekDayLabel.text = weekDay
        self.dateLabel.text = date
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

// For price cell.
class HikeSearchResultsPriceCell : UITableViewCell {
    
    @IBOutlet var basePriceLabel: UILabel!
    @IBOutlet var extraTravelTimeLabel: UILabel!
    @IBOutlet var totalPriceLabel: UILabel!
    
    // Configuration.
    func configure (basePrice : Double, extraTravelPrice : Double) {
        
        basePriceLabel.text = getPriceString(price: basePrice)
        extraTravelTimeLabel.text = getPriceString(price: extraTravelPrice)
        
        totalPriceLabel.text = getPriceString(price: basePrice + extraTravelPrice)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
