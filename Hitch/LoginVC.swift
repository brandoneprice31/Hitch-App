//
//  LoginVC.swift
//  Hitch
//
//  Created by Brandon Price on 1/24/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import UIKit

class LoginVC: UIViewController, UITextFieldDelegate {

    // MARK: - IB Outlets.
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    
    // MARK: - Methods.
    
    // View Did Load.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.        
        loginButton.layer.cornerRadius = 5.0
    }

    // Did Receive Memory Warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // loginButton Clicked.
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        
        // If either TF is empty then alert the user otherwise check to see if the user's credentials are in our database.
        if (emailTF.text == nil || emailTF.text == "") ||
           (passwordTF.text == nil || passwordTF.text == "") {
            
            // Alert the user that they need to provide an email and a password.
            self.presentNormalAlertView(title: "Empty Fields", message: "Please enter an email and a password.")
            
        } else {
            
            // Try logging in the user user core data.
            //let sessionStatus = CoreDataAuthentication.loginUserWithInfo(email: self.emailTF.text!, password: self.passwordTF.text!)
            
            // Login the user.
            self.pauseViewWithAnimation(view: self.view, animationName: "spinner", text: "Logging you in...")
            API.loginUserWithCredentials(email: self.emailTF.text!, password: self.passwordTF.text!, completionHandler: {
                (response, user) in
                DispatchQueue.main.sync() {
                    self.unPauseViewAndRemoveAnimation(view: self.view)
                
                    if response == URLResponse.WrongCredentials {
                        // Wrong credentials so alert the user.
                        self.presentNormalAlertView(title: "Account Doesn't Exist", message: "Did you enter the wrong email or password?")
                    } else {
                    
                        // Success so present main nav and store user in app delegate.
                        let mainNav = (self.storyboard?.instantiateViewController(withIdentifier: "MainNav"))!
                        mainNav.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        self.present(mainNav, animated: true, completion: nil)
                    }
                }
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // signupButton clicked.
    @IBAction func signupButtonClicked(_ sender: UIButton) {
        
        // Present the signupVC and send it the entered in email and password.
        let signupVC : SignUpVC = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(signupVC, animated: true)
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
