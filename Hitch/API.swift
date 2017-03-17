//
//  Authentication.swift
//  Hitch
//
//  Created by Brandon Price on 1/29/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import CoreLocation

class API {
    
    // ROOT URL
    //static let rootURLString : String = "http://127.0.0.1:8000/app/"
    static let rootURLString : String = "https://sheltered-citadel-17296.herokuapp.com/app/"
    
    
    
    
    
    /* Function for checking if a user exists already:
     * returns Success, Error
     */
    class func checkIfUserExists (email: String, completionHandler: @escaping (URLResponse, Bool) -> Void) {
        
        // Create json object.
        let json : [String : String] = ["email" : email]
        
        // Perform request.
        API.performRequest(requestType: "POST", urlPath: "users/check/", json: json, token: nil, completionHandler: {
            (response, _) in
            
            switch response.statusCode {
            case 409:
                completionHandler(URLResponse.Success, true)
            case 404:
                completionHandler(URLResponse.Success, false)
            default:
                completionHandler(URLResponse.Error, false)
            }
        })
    }
    
    
    
    /* Logs the user in and gets his info:
     * returns success, wrongcredentials
     */
    class func loginUserWithCredentials (email: String, password: String, completionHandler: @escaping (URLResponse, User?) -> Void) {
        
        // Create json.
        let json: [String: String] = ["email" : email,
                                      "password" : password]
        
        // Perform request.
        API.performRequest(requestType: "POST", urlPath: "users/login/", json: json, token: nil, completionHandler: {
            (response, json) in
            
            switch response.statusCode {
            case 202:
                var decodedImage : UIImage? = nil
                
                let json_user_data = json as! [String: Any]
                
                if json_user_data.keys.contains("profile_image") {
                    let decodedData = NSData(base64Encoded: json_user_data["profile_image"] as! String, options: NSData.Base64DecodingOptions(rawValue: 0))
                    
                    decodedImage = UIImage(data: decodedData! as Data)
                }
                
                let user = User(id: json_user_data["id"] as! Int, firstName: (json_user_data["first_name"] as? String)!, lastName: (json_user_data["last_name"] as? String)!, email: json_user_data["email"] as! String, token: (json_user_data["token"]
                    as? String)!, profileImage: decodedImage)
                
                // Login the user.
                User.loginUser(user: user)
                completionHandler(URLResponse.Success, user)

            default:
                 completionHandler(URLResponse.WrongCredentials, nil)
            }
        })
    }
    
    
    /* Function that updates the user in the data base:
     * returns success, error
     */
    class func updateUser (token: String, user: User, fields: [String],completionHandler: @escaping (URLResponse) -> Void) {
        
        // Get json.
        let json : [String : Any] = user.getJSON(fields: fields)
        
        // Perform API request.
        API.performRequest(requestType: "POST", urlPath: "users/update/", json: json, token: token, completionHandler: {
            (response, _) in
            
            switch response.statusCode {
            case 200:
                completionHandler(URLResponse.Success)
            default:
                completionHandler(URLResponse.Error)
            }
        })
    }
    
    
    /* Function that logs out the user in the data base:
     * returns success, error
     */
    class func logOutUser (token: String, completionHandler: @escaping (URLResponse) -> Void) {
        
        // Send request.
        API.performRequest(requestType: "GET", urlPath: "users/log-out/", json: nil, token: token, completionHandler: {
            (response, json) in
            
            switch response.statusCode {
            case 200:
                User.logOutCurrentUser()
                completionHandler(URLResponse.Success)
            default:
                completionHandler(URLResponse.Error)
            }
        })
    }
    

    
    /* Function that is supposed to create a user in the data base:
     * returns success, wrongcredentials
     */
    class func createUserWithCredentials(email: String, password: String, firstName: String, lastName: String, profileImage: UIImage?, completionHandler: @escaping (URLResponse, User?) -> Void) {
        
        // Create json object.
        var json: [String: Any] = ["email" : email,
                                   "password" : password,
                                   "first_name": firstName,
                                   "last_name" : lastName]
        
        // Send profile image data.
        if profileImage != nil {
            
            let imageData = UIImagePNGRepresentation(profileImage!)
            let profile_image_data = imageData?.base64EncodedString()
            json["profile_image"] = profile_image_data!
        }
        
        // Perform request.
        API.performRequest(requestType: "POST", urlPath: "users/create/", json: json, token: nil, completionHandler: {
            (response, json) in
            
            switch response.statusCode {
            case 201:
                // Build user object.
                var user : User? = nil
                
                if json != nil {
                    
                    let json_user_data = json as! [String: Any]
                    user = User.loadFromJSON(json: json_user_data)
                }
                
                completionHandler(URLResponse.Success, user)
            default:
                completionHandler(URLResponse.WrongCredentials, nil)
            }
        })
    }
    
    
    
    /* Function that is supposed to delete a user in the data base:
     * returns success, error
     */
    class func deleteUser (token: String, completionHandler: @escaping (URLResponse) -> Void) {
        
        API.performRequest(requestType: "DELETE", urlPath: "users/delete/", json: nil, token: token, completionHandler: {
            (response, _) in
            
            if response.statusCode != 204 {
                completionHandler(URLResponse.Error)
                
            } else {
                User.logOutCurrentUser()
                completionHandler(URLResponse.Success)
            }
        })
    }
    
    
    
    
    /* Function that gets all of the user's drive objects:
     * returns Success, Error
     */
    class func getUsersDrives (token: String, completionHandler: @escaping (URLResponse, [Drive]?) -> Void) {
        
        // Perform request.
        API.performRequest(requestType: "GET", urlPath: "drives/", json: nil, token: token, completionHandler: {
            (response, jsonList) in
            
            switch response.statusCode {
            case 200:
                // Return drive objects.
                let json_drive_data = jsonList as! [[String: Any]]
                
                // Construct drive array.
                var driveList = [Drive]()
                for json in json_drive_data {
                    driveList.append(Drive.loadFromJSON(json: json))
                }
                
                // Return drive list.
                completionHandler(URLResponse.Success, driveList)
            default:
                // Return error.
                completionHandler(URLResponse.Error, nil)
            }
        })
    }
    
    
    
    /* Function that saves user's drive to back-end:
     * returns Success, Error
     */
    class func saveUsersDrive (token: String, drive: Drive, completionHandler: @escaping (URLResponse) -> Void) {
        
        let json = drive.getJSON()
        
        // Perform request.
        API.performRequest(requestType: "POST", urlPath: "drives/create/", json: json, token: token, completionHandler: {
            (response, _) in
            
            if response.statusCode != 201 {
                completionHandler(URLResponse.Error)
            } else {
                completionHandler(URLResponse.Success)
            }
        })
    }
    
    
    
    /* Function that pulls all of the user's hitches:
     * returns Success, Error
     */
    class func getUsersHitches(token: String, completionHandler: @escaping (URLResponse, [Hitch]?) -> Void) {
        
        // Perform request.
        API.performRequest(requestType: "GET", urlPath: "hitches/", json: nil, token: token, completionHandler: {
            (response, jsonList) in
            
            if response.statusCode != 200 {
                // Return error.
                completionHandler(URLResponse.Error, nil)
            } else {
                // Return drive objects.
                let json_hitch_data = jsonList as! [[String: Any]]
                
                // Construct drive array.
                var hitchList = [Hitch]()
                for json in json_hitch_data {
                    hitchList.append(Hitch.loadFromJSON(json: json))
                }
                
                // Return drive list.
                completionHandler(URLResponse.Success, hitchList)
            }
        })
    }
    
    
    
    
    /* Function that adds hitch to data base and send push notification to driver:
     * returns Success, Error
     */
    class func HitchOnToDrive(hitch: Hitch, completionHandler: @escaping (URLResponse) -> Void) {
        
        // Build json.
        let json : [String : Any] = hitch.getJSON()
        
        // Perform request.
        API.performRequest(requestType: "POST", urlPath: "hitches/create/", json: json, token: hitch.hitchHiker.token, completionHandler: {
            (response, json) in
            
            // Handle the response.
            if response.statusCode != 201 {
                completionHandler(URLResponse.Error)
            } else {
                completionHandler(URLResponse.Success)
            }
        })
    }
    
    
    
    
    /* Function that searches for drives that fits the hitch:
     * returns success, error
     */
    class func driveSearch (token: String, pickUpCoordinate: CLLocationCoordinate2D, dropOffCoordinate: CLLocationCoordinate2D, startDateTime: DateTime, endDateTime: DateTime, completionHandler: @escaping (URLResponse, [Drive]?) -> Void) {
        
        // Build json.
        let json : [String : Any] =     ["pick_up_lat"       : pickUpCoordinate.latitude,
                                         "pick_up_long"      : pickUpCoordinate.longitude,
                                         "drop_off_lat"      : dropOffCoordinate.latitude,
                                         "drop_off_long"     : dropOffCoordinate.longitude,
                                         "start_date_time"   : startDateTime.getJSONRepresentation(),
                                         "end_date_time"     : endDateTime.getJSONRepresentation()]
        
        API.performRequest(requestType: "POST", urlPath: "drives/search/", json: json, token: token, completionHandler: {
            (response, jsonList) in
            
            if response.statusCode != 200 {
                completionHandler(URLResponse.Error, nil)
            } else {
                
                let resultList = jsonList as! [[String:Any]]
                
                var driveList = [Drive]()
                for result in resultList {
                    driveList.append(Drive.loadFromJSON(json: result))
                }
                
                completionHandler(URLResponse.Success, driveList)
            }
        })
    }
    
    
    
    /* Function that hitches onto a drive:
     * returns success, error
     */
    
    class func acceptHitch (token: String, hitch: Hitch, drive: Drive, completionHandler: @escaping (URLResponse) -> Void) {
        
        // Build json.
        let json : [String : Any] =  ["hitch_id" : hitch.id,
                                      "drive_id" : drive.id]
        
        API.performRequest(requestType: "POST", urlPath: "drives/accept_hitch/", json: json, token: token, completionHandler: {
            (response, _) in
            
            if response.statusCode != 200 {
                completionHandler(URLResponse.Error)
            }
            
            completionHandler(URLResponse.Success)
        })
    }
    
    
    // HELPERS
    class func performRequest(requestType: String, urlPath: String, json: [String: Any]?, token: String?,completionHandler: @escaping (HTTPURLResponse, Any?) -> Void) {
        
        // Make url request.
        var request = URLRequest(url: URL(string: API.rootURLString + urlPath)!)
        request.httpMethod = requestType
        
        // If jason is not nil add it to the request.
        if json != nil {
            let jsonData = try? JSONSerialization.data(withJSONObject: json!)
            request.httpBody = jsonData
        }
        
        // If token is not nil, add it to the request.
        if token != nil {
            request.setValue("Token " + token!, forHTTPHeaderField: "Authorization")
        }
        
        // Perform request.
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) {
            
            (data, response, error) in
            
            // Handle errors.
            if (error != nil) {
                
                fatalError("\(error)")
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                
                var jsonResponse : Any?
                
                do {
                    jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                } catch {
                    jsonResponse = nil
                }
                
                completionHandler(httpResponse, jsonResponse)
            }
        }
        task.resume()

    }
    
}

enum URLResponse {
    case Success
    case WrongCredentials
    case Error
}
