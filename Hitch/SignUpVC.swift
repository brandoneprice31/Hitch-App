//
//  SignUpVC.swift
//  Hitch
//
//  Created by Brandon Price on 1/24/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import UIKit
import CoreData

class SignUpVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - IB Outlets

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmationTF: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var nextButton: UIButton!
    
    // MARK: - Methods.
    
    // View Did Load.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        nextButton.layer.cornerRadius = 5.0
        
    }
    
    // Did Receive Memory Warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Cellphone TF is changed.
    
    /*
    @IBAction func cellPhoneChanged(_ sender: Any) {
        
        // Make sure the field isn't empty.
        if cellphoneTF.text != nil || cellphoneTF.text != "" {
            
            let text = cellphoneTF.text!
            
            // Count how many digits there are.
            let digitsOnly = text.replacingOccurrences(of: "\\D", with: "", options: .regularExpression, range: text.startIndex..<text.endIndex)
            let numDigits = digitsOnly.characters.count
            
            // Get the correctly formatted string given the number of digits.
            if 3 < numDigits && numDigits < 8 {
                
                // Correct format: 123-XXXX
                var formatted = digitsOnly.substring(to: digitsOnly.index(digitsOnly.startIndex, offsetBy: 3))
                formatted = formatted + "-"
                formatted = formatted + digitsOnly.substring(from: digitsOnly.index(digitsOnly.startIndex, offsetBy: 3))
                cellphoneTF.text = formatted
                
            } else if 8 <= numDigits && numDigits < 11 {
                
                // Correct format: (234)-567-8XXX
                var formatted = "(" + digitsOnly.substring(to: digitsOnly.index(digitsOnly.startIndex, offsetBy: 3)) + ")-"
                formatted = formatted + digitsOnly.substring(with: digitsOnly.index(digitsOnly.startIndex, offsetBy: 3)..<digitsOnly.index(digitsOnly.startIndex, offsetBy: 6)) + "-"
                formatted = formatted + digitsOnly.substring(from: digitsOnly.index(digitsOnly.startIndex, offsetBy: 6))
                cellphoneTF.text = formatted
                
            } else if numDigits >= 11 {
                
                // Correct format: 1-(234)-567-8910
                var formatted = digitsOnly.substring(to: digitsOnly.index(digitsOnly.startIndex, offsetBy: 1)) + "-"
                print(formatted)
                formatted = formatted + "(" + digitsOnly.substring(with: digitsOnly.index(digitsOnly.startIndex, offsetBy: 1)..<digitsOnly.index(digitsOnly.startIndex, offsetBy: 4)) + ")-"
                print(formatted)
                formatted = formatted + digitsOnly.substring(with: digitsOnly.index(digitsOnly.startIndex, offsetBy: 4)..<digitsOnly.index(digitsOnly.startIndex, offsetBy: 7)) + "-"
                print(formatted)
                formatted = formatted + digitsOnly.substring(with: digitsOnly.index(digitsOnly.startIndex, offsetBy: 7)..<digitsOnly.index(digitsOnly.startIndex, offsetBy: 11))
                print(formatted)
                cellphoneTF.text = formatted
            }
        }
    }*/
    
    // Next button clicked.
    @IBAction func nextButtonClicked(_ sender: Any) {
        
        // Check to see if any fields are empty.
        if (emailTF.text == nil || emailTF.text == "") ||
           (passwordTF.text == nil || passwordTF.text == "") ||
            (confirmationTF.text == nil || confirmationTF.text == "") {
            
            // Alert the user that not all of the fields are entered.
            self.presentNormalAlertView(title: "Empty Fields", message: "Please enter an email, cell-phone number, and a password.")
            
        } else {
            
            // Check to see if the password doesn't match the password confirmation.
            if (passwordTF.text != confirmationTF.text) {
                
                // Alert the user that the passwords don't match.
                self.presentNormalAlertView(title: "Passwords Do Not Match", message: "The password and the confirmation are not the same.")
                
            } else {
                
                // Check to see if user already exists.
                self.pauseViewWithAnimation(view: self.view, animationName: "spinner", text: "Checking for unique user...")
                API.checkIfUserExists(email: emailTF.text!, completionHandler: {
                    (response, userExists) in
                    
                    DispatchQueue.main.sync() {
                        // place code for main thread here
                        self.unPauseViewAndRemoveAnimation(view: self.view)
                        
                        if response == URLResponse.Error {
                            self.presentNormalAlertView(title: "Error", message: "Check your internet connection.")
                        }
                        
                        if userExists {
                            // If the user exists already then we need to alert them.
                            self.presentNormalAlertView(title: "User Already Exists", message: "This email is already taken.")
                            
                        } else {
                            // Present the signupVC and send it the entered in email and password.
                            self.gotoPInfo()
                        }
                    }
                })
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Goto PInforVC.
    func gotoPInfo () {
        let personalInfoSignUpVC : PersonalInfoSignUpVC = self.storyboard?.instantiateViewController(withIdentifier: "PInfoVC") as! PersonalInfoSignUpVC
        personalInfoSignUpVC.email = self.emailTF.text!
        personalInfoSignUpVC.password = self.passwordTF.text!
        self.navigationController?.pushViewController(personalInfoSignUpVC, animated: true)
    }
    
    // Login Button clicked.
    @IBAction func loginButtonClicked(_ sender: Any) {
        
        // Present the loginVC.
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

