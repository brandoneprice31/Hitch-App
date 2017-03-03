//
//  LoginVC.swift
//  Hitch
//
//  Created by Brandon Price on 1/24/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import UIKit

class PersonalInfoSignUpVC: UIViewController, UITextFieldDelegate {
    
    // Properties
    var email = String()
    var password = String()
    var profileImage : UIImage? = nil
    
    // MARK: - IB Outlets.
    @IBOutlet weak var firstnameTF: UITextField!
    @IBOutlet weak var lastnameTF: UITextField!
    @IBOutlet var datePicker: UIPickerView!
    @IBOutlet var genderSegmentControl: UISegmentedControl!
    @IBOutlet var birthdayView: UIView!
    @IBOutlet var genderView: UIView!
    @IBOutlet var signUpButton: UIButton!
    @IBOutlet var profileImageButton: UIButton!
    
    // MARK: - Methods.
    
    // View Did Load.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        profileImageButton.layer.cornerRadius = profileImageButton.frame.size.height / 2.0
        profileImageButton.layer.masksToBounds = true
        profileImageButton.layer.borderWidth = 0
        signUpButton.layer.cornerRadius = 5.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Display profile pic if it exists.
        self.profileImageButton.setImage(profileImage == nil ? UIImage(named: "default-profile") : profileImage , for: .normal)
        self.profileImageButton.imageView?.contentMode = .scaleAspectFill
    }
    
    // Did Receive Memory Warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ProfileImage clicked.
    @IBAction func profileImageButtonClicked(_ sender: Any) {
        
        // Present the CameraVC.
        let cameraVC : UIViewController = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
        self.navigationController?.pushViewController(cameraVC, animated: true)
    }
    
    // Return button clicked.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Depending on which textfield it is, we should do different things.
        if textField.restorationIdentifier == "firstnameTF" {
            
            // Resign firstnameTF and goto lastnameTF.
            firstnameTF.resignFirstResponder()
            lastnameTF.becomeFirstResponder()
            
        } else {
            
            // Resign lastnameTF.
            lastnameTF.resignFirstResponder()
        }
        
        return true
    }
    
    /*
    // Number of rows in picker view.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0{
            // Month component.
            return self.months.count
        } else {
            // Year component
            return self.years.count
        }
    }
    
    // Number of components in picker view.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    //  Width of componentes in picker view.
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if component == 0 {
            // Month component.
            return 50.0
        } else {
            // Year component
            return 100.0
        }
    }
    
    // Labels of picker view.
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        // Create a picker view with standard font color and size.
        let pickerLabel = UILabel()
        pickerLabel.textColor = UIColor.black
        pickerLabel.font = UIFont.systemFont(ofSize: 14.0)
        pickerLabel.textAlignment = NSTextAlignment.center
        
        if component == 0 {
            // Month component.
            pickerLabel.text = self.months[row]
        } else {
            // Year component.
            pickerLabel.text = String(self.years[self.years.count - row - 1])
        }
        
        return pickerLabel
    }*/
    
    // Signup button Clicked.
    @IBAction func signUpButtonClicked(_ sender: Any) {
        
        // If either TF is empty then alert the user otherwise check to see if the user's credentials are in our database.
        if (firstnameTF.text == nil || firstnameTF.text == "") ||
           (lastnameTF.text == nil || lastnameTF.text == "") {
            
            // Alert the user that they need to provide a first and last name.
            self.presentNormalAlertView(title: "Empty Fields", message: "Please enter a first name and a last name.")
            
        } else {
            
            // Save the user.
            self.pauseViewWithAnimation(view: self.view, animationName: "spinner", text: "Creating Hitch account...")
            API.createUserWithCredentials(email: self.email, password: self.password, firstName: firstnameTF.text!, lastName: lastnameTF.text!, profileImage: self.profileImage, completionHandler: {
                (response, user) in
                
                DispatchQueue.main.sync() {
                    self.unPauseViewAndRemoveAnimation(view: self.view)
                    
                    if response == URLResponse.Success {
                        
                        // Set the current user.
                        User.loginUser(user: user!)
                        
                        // Goto main nav.
                        self.gotoMainVC()
                    } else {
                        // If something doesn't work then warn the user.
                        self.presentNormalAlertView(title: "Error", message: "Something didn't work.  Are you connected to the internet?")
                    }
                }
            })
        }
    }
    
    // Goto MainMenuVC
    func gotoMainVC () {
        // Present the MainMenuVC.
        let mainNav = (self.storyboard?.instantiateViewController(withIdentifier: "MainNav"))!
        mainNav.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        self.present(mainNav, animated: true, completion: nil)
    }
    
    // Back Button Clicked.
    @IBAction func backButtonClicked(_ sender: Any) {
        
        // Present the signupvc.
        let _ = self.navigationController?.popViewController(animated: true)
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
