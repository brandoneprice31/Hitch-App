//
//  MainNavCells.swift
//  Hitch
//
//  Created by Brandon Price on 2/15/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation
import UIKit

class MainVCDriveCell : UITableViewCell {
    
    @IBOutlet var startTimeLabel: UILabel!
    @IBOutlet var endTimeLabel: UILabel!
    @IBOutlet var startPlaceLabel: UILabel!
    @IBOutlet var endPlaceLabel: UILabel!
    @IBOutlet var box2: UILabel!
    @IBOutlet var isAHikerLabel: UILabel!
    
    func configure (drive: Drive) {
        
        // Configure times.
        startTimeLabel.text = drive.startDateTime.time()
        endTimeLabel.text = drive.endDateTime.time()
        
        // Configure Places.
        startPlaceLabel.text = drive.start.title
        endPlaceLabel.text = drive.end.title
        
        // Configure Box
        box2.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4.0)
        
        // Configure hiker label.
        if drive.pickingUpHiker {
            isAHikerLabel.text = "Hitchhiker:"
        } else {
            isAHikerLabel.text = "No hitchhiker"
            isAHikerLabel.adjustsFontSizeToFitWidth = true
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class MainVCHitchCell : UITableViewCell {
    
    @IBOutlet var pickUpTimeLabel: UILabel!
    @IBOutlet var dropOffTimeLabel: UILabel!
    @IBOutlet var pickUpPlaceLabel: UILabel!
    @IBOutlet var dropOffPlaceLabel: UILabel!
    @IBOutlet var driverNameLabel: UILabel!
    @IBOutlet var box2: UILabel!
    
    func configure (hitch: Hitch) {
        
        pickUpTimeLabel.text = hitch.pickUpDateTime.time()
        dropOffTimeLabel.text = hitch.dropOffDateTime.time()
        pickUpPlaceLabel.text = hitch.pickUpPlace.title
        dropOffPlaceLabel.text = hitch.dropOffPlace.title
        driverNameLabel.text = hitch.driver!.firstName + " " + hitch.driver!.lastName
        
        // Configure Box
        box2.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class MainVCHitchedDriveCell: UITableViewCell {
    
    @IBOutlet var startTimeLabel: UILabel!
    @IBOutlet var pickUpTimeLabel: UILabel!
    @IBOutlet var dropOffTimeLabel: UILabel!
    @IBOutlet var endTimeLabel: UILabel!
    @IBOutlet var startPlaceLabel: UILabel!
    @IBOutlet var pickUpPlaceLabel: UILabel!
    @IBOutlet var dropOffPlaceLabel: UILabel!
    @IBOutlet var endPlaceLabel: UILabel!
    @IBOutlet var hitchHikerLabel: UILabel!
    @IBOutlet var box4: UILabel!
    
    func configure (drive: Drive) {
        
        // Configure Box
        box4.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4.0)
        
        startTimeLabel.text = drive.startDateTime.time()
        pickUpTimeLabel.text = drive.pickUpTime?.time()
        dropOffTimeLabel.text = drive.dropOffTime?.time()
        endTimeLabel.text = drive.endDateTime.time()
        
        startPlaceLabel.text = drive.start.title
        pickUpPlaceLabel.text = drive.pickUpLocation?.title
        dropOffPlaceLabel.text = drive.dropOffLocation?.title
        endPlaceLabel.text = drive.end.title
        
        hitchHikerLabel.text = drive.hikerFirstName! + " " + drive.hikerLastName!
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}

// Day Cell.
class MainVCDayCell : UITableViewCell {
    
    @IBOutlet var weekDayLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    func configure (weekDay : String, date: String) {
        weekDayLabel.text = weekDay
        dateLabel.text = date
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// City Cell.
class MainVCCityCell : UITableViewCell {
    
    @IBOutlet var cityImageView: UIImageView!
    @IBOutlet var cityTitle: UILabel!
    
    func configure (cityImageName: String) {
        
        var cityName = cityImageName.components(separatedBy: " ")[0]
        cityName = cityName.replacingOccurrences(of: "-", with: " ")
        
        cityTitle.text = cityName
        cityImageView.image = UIImage(named: cityImageName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
