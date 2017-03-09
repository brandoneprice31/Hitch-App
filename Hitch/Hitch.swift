//
//  Hitch.swift
//  Hitch
//
//  Created by Brandon Price on 3/1/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation
import UIKit
import Mapbox

class Hitch {
    
    var id : Int = 0
    var drive : Drive = Drive()
    var hitchHiker : User = User()
    var pickUpPlace : Place = Place()
    var dropOffPlace : Place = Place()
    var adjustedStartDateTime : DateTime = DateTime()
    var pickUpDateTime : DateTime = DateTime()
    var dropOffDateTime : DateTime = DateTime()
    var repeatedWeekDays : [Int] = [Int]()
    var accepted : Bool = Bool()
    var polylines : [MGLPolyline] = [MGLPolyline]()
    
    init () {
        
    }
    
    // Casual init.
    init (id : Int, drive: Drive, hitchHiker: User, adjustedStartDateTime : DateTime, pickUpPlace: Place, dropOffPlace: Place, pickUpDateTime: DateTime, dropOffDateTime: DateTime, repeatedWeekDays: [Int], accepted: Bool, polylines: [MGLPolyline]) {
        
        self.id = id
        self.drive = drive
        self.hitchHiker = hitchHiker
        self.adjustedStartDateTime = adjustedStartDateTime
        self.pickUpPlace = pickUpPlace
        self.dropOffPlace = dropOffPlace
        self.pickUpDateTime = pickUpDateTime
        self.dropOffDateTime = dropOffDateTime
        self.repeatedWeekDays = repeatedWeekDays
        self.accepted = accepted
        self.polylines = polylines
    }
    
    // Load hitch from json file.
    class func loadFromJSON (json: [String:Any]) -> Hitch {
        
        // Load the pick up and drop off places.
        let pickUpPlace = Place(title: (json["pick_up_title"] as? String)!, subtitle: (json["pick_up_sub_title"] as? String)!, coordinate: CLLocationCoordinate2D(latitude: json["pick_up_lat"] as! Double, longitude: json["pick_up_long"] as! Double))
        let dropOffPlace = Place(title: (json["drop_off_title"] as? String)!, subtitle: (json["drop_off_sub_title"] as? String)!, coordinate: CLLocationCoordinate2D(latitude: json["drop_off_lat"] as! Double, longitude: json["drop_off_long"] as! Double))
        
        // Load datetimes.
        let adjustedStartDateTime = DateTime.loadFromJSONRep(jsonRep: json["adjusted_start_date_time"] as! String)
        let pickUpDateTime = DateTime.loadFromJSONRep(jsonRep: json["pick_up_date_time"] as! String)
        let dropOffDateTime = DateTime.loadFromJSONRep(jsonRep: json["drop_off_date_time"] as! String)
        
        // Occurrence stuff.
        let repeatedWeekDays = json["repeated_week_days"] as! [Int]
        let accept = json["accepted"] as! Bool
        
        // Load Polylines.
        var polylines = [MGLPolyline]()
        if json.index(forKey: "start_to_pick_up_polyline") != nil {
            for polylineStringData in [json["start_to_pick_up_polyline"], json["pick_up_to_drop_off_polyline"], json["drop_off_to_end_polyline"]] {
                polylines.append(MGLPolyline.PolylineFromByteString(byteString: polylineStringData as! String))
            }
        }
        
        // User and drive info.
        let hitchHiker = User.loadFromJSON(json: json["hitch_hiker"] as! [String : Any])
        var drive = Drive()
        if json.index(forKey: "drive") != nil {
            drive = Drive.loadFromJSON(json: json["drive"] as! [String : Any])
        }
        
        let id = json["id"] as! Int
        
        // Build hitch and return it.
        let hitch = Hitch(id : id, drive: drive, hitchHiker: hitchHiker, adjustedStartDateTime: adjustedStartDateTime, pickUpPlace: pickUpPlace, dropOffPlace: dropOffPlace, pickUpDateTime: pickUpDateTime, dropOffDateTime: dropOffDateTime, repeatedWeekDays: repeatedWeekDays, accepted: accept, polylines: polylines)
        
        return hitch
    }
    
    // SaveToJSON
    func getJSON () -> [String:Any] {
        
        var json : [String: Any] = ["pick_up_title" : self.pickUpPlace.title]
        json["adjusted_start_date_time"] = self.adjustedStartDateTime.getJSONRepresentation()
        json["pick_up_sub_title"] = self.pickUpPlace.subtitle
        json["pick_up_lat"] = self.pickUpPlace.coordinate.latitude
        json["pick_up_long"] = self.pickUpPlace.coordinate.longitude
        json["drop_off_title"] = self.dropOffPlace.title
        json["drop_off_sub_title"] = self.dropOffPlace.subtitle
        json["drop_off_lat"] = self.dropOffPlace.coordinate.latitude
        json["drop_off_long"] = self.dropOffPlace.coordinate.longitude
        json["pick_up_date_time"] = self.pickUpDateTime.getJSONRepresentation()
        json["drop_off_date_time"] = self.dropOffDateTime.getJSONRepresentation()
        json["repeated_week_days"] = self.repeatedWeekDays
        json["start_to_pick_up_polyline"] = self.polylines[0].geoJSONData(usingEncoding: 1).base64EncodedString()
        json["pick_up_to_drop_off_polyline"] = self.polylines[1].geoJSONData(usingEncoding: 1).base64EncodedString()
        json["drop_off_to_end_polyline"] = self.polylines[2].geoJSONData(usingEncoding: 1).base64EncodedString()
        json["hitch_hiker_id"] = self.hitchHiker.id
        json["drive_id"] = self.drive.id
        json["accepted"] = self.accepted
        
        return json
    }
}
