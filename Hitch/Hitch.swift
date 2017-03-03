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
    
    var driveID : Int
    var drive : Drive? = nil
    var user : User
    var driver : User? = nil
    var pickUpPlace : Place
    var dropOffPlace : Place
    var pickUpDateTime : DateTime
    var dropOffDateTime : DateTime
    var repeatedWeekDays : [Int]
    var accepted : Bool
    var polylines : [MGLPolyline]
    
    // Casual init.
    init (driveID: Int, user: User, driver: User?, pickUpPlace: Place, dropOffPlace: Place, pickUpDateTime: DateTime, dropOffDateTime: DateTime, repeatedWeekDays: [Int], accepted: Bool, polylines: [MGLPolyline]) {
        
        self.driveID = driveID
        self.user = user
        self.driver = driver
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
        let pickUpPlace = Place(title: json["pick_up_title"] as? String, subtitle: json["pick_up_sub_title"] as? String, coordinate: CLLocationCoordinate2D(latitude: json["pick_up_lat"] as! Double, longitude: json["pick_up_long"] as! Double))
        let dropOffPlace = Place(title: json["drop_off_title"] as? String, subtitle: json["drop_off_sub_title"] as? String, coordinate: CLLocationCoordinate2D(latitude: json["drop_off_lat"] as! Double, longitude: json["drop_off_long"] as! Double))
        
        // Load datetimes.
        let pickUpDateTime = DateTime.loadFromJSONRep(jsonRep: json["pick_up_date_time"] as! String)
        let dropOffDateTime = DateTime.loadFromJSONRep(jsonRep: json["drop_off_date_time"] as! String)
        
        // Occurrence stuff.
        let repeatedWeekDays = json["repeated_week_days"] as! [Int]
        let accept = json["accepted"] as! Bool
        
        // Load Polylines.
        var polylines = [MGLPolyline]()
        if json.index(forKey: "start_to_pick_up_polyline") != nil {
            for polylineStringData in [json["start_to_pick_up_polyline"], json["pick_up_to_drop_off_polyline"], json["drop_off_to_end_polyline"]] {
                let polylineData = NSData(base64Encoded: polylineStringData as! String, options: NSData.Base64DecodingOptions(rawValue: UInt(0))) as! Data
                polylines.append(Mapping.loadPolyLineFromGEOJSON(polyLineData: polylineData)!)
            }
        }
        
        // User and drive info.
        let userJson = json["user"] as! [String: Any]
        let user = User(id: userJson["id"] as! Int, firstName: userJson["first_name"] as! String, lastName: userJson["last_name"] as! String, email: userJson["email"] as! String, token: "", profileImage: nil)
        
        let driveJson = json["drive"] as! [String : Any]
        let driveID = driveJson["id"] as! Int
        let driverJson = driveJson["user"] as! [String : Any]
        let driver = User(id: driverJson["id"] as! Int, firstName: driverJson["first_name"] as! String, lastName: driverJson["last_name"] as! String, email: driverJson["email"] as! String, token: "", profileImage: nil)
        
        // Build hitch and return it.
        let hitch = Hitch(driveID: driveID, user: user, driver: driver, pickUpPlace: pickUpPlace, dropOffPlace: dropOffPlace, pickUpDateTime: pickUpDateTime, dropOffDateTime: dropOffDateTime, repeatedWeekDays: repeatedWeekDays, accepted: accept, polylines: polylines)
        
        hitch.drive = Drive.loadFromJSON(json: driveJson)!
        
        return hitch
    }
    
    // SaveToJSON
    func getJSON () -> [String:Any] {
        
        var json : [String: Any] = ["pick_up_title" : self.pickUpPlace.title!]
        json["pick_up_sub_title"] = self.pickUpPlace.subtitle
        json["pick_up_lat"] = self.pickUpPlace.coordinate?.latitude
        json["pick_up_long"] = self.pickUpPlace.coordinate?.longitude
        json["drop_off_title"] = self.dropOffPlace.title!
        json["drop_off_sub_title"] = self.dropOffPlace.subtitle
        json["drop_off_lat"] = self.dropOffPlace.coordinate?.latitude
        json["drop_off_long"] = self.dropOffPlace.coordinate?.longitude
        json["pick_up_date_time"] = self.pickUpDateTime.getJSONRepresentation()
        json["drop_off_date_time"] = self.dropOffDateTime.getJSONRepresentation()
        json["repeated_week_days"] = self.repeatedWeekDays
        json["start_to_pick_up_polyline"] = self.polylines[0].geoJSONData(usingEncoding: 1).base64EncodedString()
        json["pick_up_to_drop_off_polyline"] = self.polylines[1].geoJSONData(usingEncoding: 1).base64EncodedString()
        json["drop_off_to_end_polyline"] = self.polylines[2].geoJSONData(usingEncoding: 1).base64EncodedString()
        json["user"] = self.user.id
        json["drive_id"] = self.driveID
        json["accepted"] = self.accepted
        
        return json
    }
    
    // Get drive from hitch.
    func getDrive () -> Drive? {
        
        if self.drive == nil {
            return nil
        }
        
        let drive = Drive(driverFirstName: self.drive!.firstName, driverLastName: self.drive!.lastName, driverID: self.drive!.driverID, start: self.drive!.start, end: self.drive!.end, startDateTime: self.drive!.startDateTime, endDateTime: self.drive!.endDateTime, repeatWeekDays: self.drive!.repeatWeekDays, polyLine: self.drive!.polyLine, orRoute: nil)
        
        drive.configureOptionalProperties(driveID: self.drive!.id, pickingUpHiker: true, pickUpLocation: self.pickUpPlace, dropOffLocation: self.dropOffPlace, pickUpTime: self.pickUpDateTime, dropOffTime: self.dropOffDateTime, pickUpPolylines: self.polylines, hikerID: self.user.id, hikerFirstName: self.user.firstName, hikerLastName: self.user.lastName, extraTimePrice: 0.0, canceledDates: self.drive!.canceledDates, hitchedStartDateTime: self.drive!.hitchedStartDateTime)
        
        return drive
    }
}
