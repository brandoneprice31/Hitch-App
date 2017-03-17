//
//  DriveHitchInfoCells.swift
//  Hitch
//
//  Created by Brandon Price on 3/16/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation
import UIKit
import Mapbox


// Map Cell.
class DHI_MapCell : UITableViewCell {
    
    @IBOutlet var mapView: MGLMapView!
    
    func configure (drive: Drive, hitch: Hitch?) {
        
        Mapping.DrawDriveOnMapView(mapView: mapView, drive: drive, hitch: hitch)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


// Occurrence Cell.
class DHI_OccurrenceCell : UITableViewCell {
    
    @IBOutlet var weekDaysView: WeekDaysView!
    @IBOutlet var adHocDateTimeLabel: UILabel!
    
    func configure (repeatedWeekdays: [Int], adHocDateTime: DateTime?) {
        
        if repeatedWeekdays == [] {
            // Ad hoc.
            weekDaysView.alpha = 0.0
            adHocDateTimeLabel.alpha = 1.0
            adHocDateTimeLabel.text = adHocDateTime!.fullDate()
            
        } else {
            // Repeated.
            weekDaysView.alpha = 1.0
            adHocDateTimeLabel.alpha = 0.0
            weekDaysView.configure(selectedDays: repeatedWeekdays, disabledDays: WeekDaysView.getDisabledDays(notDisabledDays: repeatedWeekdays), touchesAllowed: false)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


// Information Cell.
class DHI_HitchedDriveInformationCell : UITableViewCell {
    
    @IBOutlet var startTimeLabel: UILabel!
    @IBOutlet var pickUpTimeLabel: UILabel!
    @IBOutlet var dropOffTimeLabel: UILabel!
    @IBOutlet var endTimeLabel: UILabel!
    @IBOutlet var startPlaceLabel: UILabel!
    @IBOutlet var pickUpPlaceLabel: UILabel!
    @IBOutlet var dropOffPlaceLabel: UILabel!
    @IBOutlet var endPlaceLabel: UILabel!
    
    
    func configure (startPlace: Place, startDateTime: DateTime, pickUpPlace: Place, pickUpDateTime: DateTime, dropOffPlace: Place, dropOffDateTime: DateTime, endPlace: Place, endDateTime: DateTime) {
        
        // Times.
        startTimeLabel.text = startDateTime.time()
        pickUpTimeLabel.text = pickUpDateTime.time()
        dropOffTimeLabel.text = dropOffDateTime.time()
        endTimeLabel.text = endDateTime.time()
        
        // Places.
        startPlaceLabel.text = startPlace.title
        pickUpPlaceLabel.text = pickUpPlace.title
        dropOffPlaceLabel.text = dropOffPlace.title
        endPlaceLabel.text = endPlace.title
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


// Normal Information Cell.
class DHI_NormalInformationCell : UITableViewCell {
    
    @IBOutlet var startTimeLabel: UILabel!
    @IBOutlet var endTimeLabel: UILabel!
    @IBOutlet var startPlaceLabel: UILabel!
    @IBOutlet var endPlaceLabel: UILabel!
    
    
    
    func configure (startPlace: Place, startDateTime: DateTime, endPlace: Place, endDateTime: DateTime) {
        
        // Times.
        startTimeLabel.text = startDateTime.time()
        endTimeLabel.text = endDateTime.time()
        
        // Places.
        startPlaceLabel.text = startPlace.title
        endPlaceLabel.text = endPlace.title
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


// Price Cell.
class DHI_PriceCell : UITableViewCell {
    
    func configure (basePrice: Double, extraPrice: Double) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


// Hitchhiker Cell.
class DHI_HitchhikerCell : UITableViewCell {
    
    @IBOutlet var profilePic: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var rating: UIImageView!
    
    func configure (hitchHiker: User) {
        
        // Hitchhiker info.
        profilePic.image = hitchHiker.getProfileImage()
        profilePic.layer.cornerRadius = profilePic.frame.size.height / 2.0
        nameLabel.text = hitchHiker.firstName + " " + hitchHiker.lastName
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


// Title Cell.
class DHI_TitleCell : UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    
    func configure (title: String) {
        titleLabel.text = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


// Accept decline cell.
class DHI_AcceptDeclineCell : UITableViewCell {
    
    var hitchIndex : Int!
    var vc : DriveHitchInfoVC!
    
    func configure (hitchIndex: Int, vc: DriveHitchInfoVC) {
        self.hitchIndex = hitchIndex
        self.vc = vc
    }
    @IBAction func acceptButtonClicked(_ sender: Any) {
        vc.hitchAccepted(hitchIndex: hitchIndex)
    }
    
    @IBAction func declineButtonClicked(_ sender: Any) {
        vc.hitchDeclined(hitchIndex: hitchIndex)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
