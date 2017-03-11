//
//  ProfileVCCells.swift
//  Hitch
//
//  Created by Brandon Price on 3/10/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation
import UIKit

class ProfileImageCell : UITableViewCell {
    
    @IBOutlet var profileImageButton: UIButton!
    var cameraImageView = UIImageView(image: UIImage(named: "camera"))
    
    // Configure the profile image.
    func configure (user : User, amEditing : Bool, buttonClickedSelector: Selector, vc: UIViewController) {
        profileImageButton.layer.cornerRadius = profileImageButton.frame.size.height / 2.0
        profileImageButton.layer.masksToBounds = true
        profileImageButton.layer.borderWidth = 0
        profileImageButton.setImage(user.getProfileImage(), for: .normal)
        profileImageButton.imageView?.contentMode = .scaleAspectFill
        profileImageButton.isUserInteractionEnabled = amEditing
        profileImageButton.addTarget(vc, action: buttonClickedSelector, for: .touchUpInside)
        
        if amEditing {
            
            if profileImageButton.subviews.contains(cameraImageView) {
                cameraImageView.alpha = 1.0
            } else {
                // Add camera if not already.
                let width = CGFloat(60.0)
                cameraImageView.frame = CGRect(x: profileImageButton.bounds.midX - width / 2.0, y: profileImageButton.bounds.height - 80.0, width: width, height: width)
                profileImageButton.addSubview(cameraImageView)
                cameraImageView.alpha = 1.0
            }
            
        } else {
            cameraImageView.alpha = 0.0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


class UserInformationCell : UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet var firstNameTF: UITextField!
    @IBOutlet var lastNameTF: UITextField!
    
    func configure (user : User, amEditing: Bool) {
        self.firstNameTF.text = user.firstName
        self.firstNameTF.isUserInteractionEnabled = amEditing
        self.firstNameTF.delegate = self
        self.lastNameTF.text = user.lastName
        self.lastNameTF.isUserInteractionEnabled = amEditing
        self.lastNameTF.delegate = self
        
        if amEditing {
            self.firstNameTF.textColor = UIColor.lightGray
            self.lastNameTF.textColor = UIColor.lightGray
        } else {
            self.firstNameTF.textColor = navyColor
            self.lastNameTF.textColor = navyColor
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
