//
//  ProfileImage.swift
//  Hitch
//
//  Created by Brandon Price on 1/29/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation
import UIKit

class ProfileImage: UIImage {
    
    // Function which gives you a profile image from a saved image.
    class func get () -> UIImage {
        
        let userID = UserDefaults().object(forKey: "currentUserID") as? Int
        
        if userID == nil {
            fatalError("Can't fetch profile image: user is not logged in.")
        }
        
        // Load file path.
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = path.appendingPathComponent("\(userID!)_profile_pic.png")
        var image = UIImage(contentsOfFile: url.path)
        
        if image != nil {
            // If the image exists then re-orient it.
            image = UIImage(cgImage: (image?.cgImage!)!, scale: CGFloat(1.0), orientation: .right)
        } else {
            // Set the default.
            image = UIImage(named: "default-profile")
        }
        
        return image!
    }
}
