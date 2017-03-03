//
//  SettingsVC.swift
//  Hitch
//
//  Created by Brandon Price on 2/4/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    // Sections.
    var sections = ["Account", "Information", " "]
    
    // Rows in each section.
    var accountRows = ["Edit Profile","Payment"]
    var informationRows = ["Help / Contact","Feedback","User Agreement"]
    var logoutSignOutRows = ["Logout", "Delete Account"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.sectionHeaderHeight = 0.0
        tableView.sectionFooterHeight = 0.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // Number of sections in table view.
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    // Number of rows in each section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sections[section] == "Account" {
            return accountRows.count
        } else if sections[section] == "Information" {
            return informationRows.count
        } else {
            return logoutSignOutRows.count
        }
    }
    
    // Section titles in tableview.
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.red
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = navyColor
        header.contentView.backgroundColor = lightGreyColor
    }
    
    // Cell for row in tableview.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = (tableView.dequeueReusableCell(withIdentifier: "basicCell"))!
        
        if sections[indexPath.section] == "Account" {
            
            cell.textLabel?.text = accountRows[indexPath.row]
            
        } else if sections[indexPath.section] == "Information" {
            
            cell.textLabel?.text = informationRows[indexPath.row]
            
        } else {
            
            cell.textLabel?.text = logoutSignOutRows[indexPath.row]
        }
        
        return cell
    }
    
    // Did select row in tableview.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if sections[indexPath.section] == "Account" {
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        } else if sections[indexPath.section] == "Information" {
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        } else {
            // log out / sign out section
            
            if logoutSignOutRows[indexPath.row] == "Logout" {
                // Warn the user before logging out.
                self.presentOkayCancelAlertView(title: "Logout", message: "Are you sure you want to logout?",
                                                okayHandler: {UIAlertAction -> Void in
                         
                    // Log the user out and present the sign up nav.
                    self.pauseViewWithAnimation(view: self.view, animationName: "spinner", text: "Logging you out...")
                    API.logOutUser(token: (User.getCurrentUser()?.token)!, completionHandler: {
                        (response) in
                        
                        DispatchQueue.main.sync() {
                            self.unPauseViewAndRemoveAnimation(view: self.view)
                            if response == URLResponse.Error {
                                self.presentNormalAlertView(title: "Error", message: "Check your internet connection")
                                self.tableView.deselectRow(at: indexPath, animated: true)
                            } else {
                                // Transition to sing up nav.
                                let transition: CATransition = Design.moveDownTransition()
                                self.navigationController?.view.layer.add(transition, forKey: nil)
                                let nav = self.storyboard?.instantiateViewController(withIdentifier: "SignUpNav")
                                self.present(nav!, animated: false, completion: nil)
                            }
                        }
                    })
                }                               , cancelHandler: {UIAlertAction -> Void in
                    
                    // Simply deselect the row.
                    tableView.deselectRow(at: indexPath, animated: true)
                    
                })
            } else {
                // Delete account row.  Warn user.
                self.presentOkayCancelAlertView(title: "Delete Account", message: "Are you sure you want to delete your account?",
                                                okayHandler: {UIAlertAction -> Void in
                                                    
                                                    // Log the user out and present the sign up nav.
                                                    CoreDataAuthentication.deleteCurrentUserAccount()
                                                    let transition: CATransition = Design.moveDownTransition()
                                                    self.navigationController?.view.layer.add(transition, forKey: nil)
                                                    let nav = self.storyboard?.instantiateViewController(withIdentifier: "SignUpNav")
                                                    self.present(nav!, animated: false, completion: nil)
                                                    
                }                               , cancelHandler: {UIAlertAction -> Void in
                    
                    // Simply deselect the row.
                    tableView.deselectRow(at: indexPath, animated: true)
                    
                })

            }
        }
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        
        let transition: CATransition = Design.slidePushFromLeftTransition()
        self.navigationController?.view.layer.add(transition, forKey: nil)
        _ = self.navigationController?.popViewController(animated: false)
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
