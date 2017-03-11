//
//  ProfileVC.swift
//  Hitch
//
//  Created by Brandon Price on 3/10/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    var user : User!
    var allCells : [String]!
    var amEditing : Bool = false
    var profileImageChanged : UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.configureTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // Configure table view.
    func configureTableView () {
        allCells = ["SeparatorCell 12", "ProfileImageCell", "SeparatorCell 12", "UserInformationCell"]
        
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let components = allCells[indexPath.row].components(separatedBy: " ")
        
        if components[0] == "ProfileImageCell" {
            return 200.0
        } else if components[0] == "UserInformationCell" {
            return 90.0
        } else {
            let height = Float(components[1])
            return CGFloat(height!)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let components = allCells[indexPath.row].components(separatedBy: " ")
        
        if components[0] == "ProfileImageCell" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileImageCell") as! ProfileImageCell
            cell.configure(user: self.user, amEditing: self.amEditing, buttonClickedSelector: #selector(ProfileVC.profileImageButtonClicked), vc: self)
            return cell
            
        } else if components[0] == "UserInformationCell" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserInformationCell") as! UserInformationCell
            cell.configure(user: self.user, amEditing: self.amEditing)
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WhiteSeparatorCell")
            return cell!
        }
    }
    
    func profileImageButtonClicked () {
        // Load camera vc.
        let cameraVC = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
        cameraVC.nextVC = "ProfileVC"
        
        self.navigationController?.pushViewController(cameraVC, animated: true)
    }
    
    @IBAction func editSaveButtonClicked(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "edit" {
            // Change edit label to save and reload tableview.
            sender.setTitle("save", for: .normal)
            self.amEditing = true
            self.configureTableView()
            
        } else {
            // Change save label to edit and reload tableview.
            let informationCell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! UserInformationCell
            let newUser = User(id: user.id, firstName: informationCell.firstNameTF.text!, lastName: informationCell.lastNameTF.text!, email: user.email, token: user.token, profileImage: self.profileImageChanged == nil ? self.user.profileImage : self.profileImageChanged)
            
            var fields = ["first_name", "last_name"]
            if profileImageChanged != nil {
                fields.append("profile_image")
            }
            self.pauseViewWithAnimation(view: self.view, animationName: "spinner", text: "Saving...")
            API.updateUser(token: user.token, user: newUser, fields: fields, completionHandler: {
                (response) in
                DispatchQueue.main.sync() {
                    self.unPauseViewAndRemoveAnimation(view: self.view)
                    if response == URLResponse.Error {
                        self.presentNormalAlertView(title: "Error", message: "Check your internt connection.")
                        sender.setTitle("edit", for: .normal)
                        self.amEditing = false
                        self.configureTableView()
                    } else {
                        User.loginUser(user: newUser)
                        self.user = User.getCurrentUser()
                        sender.setTitle("edit", for: .normal)
                        self.amEditing = false
                        self.configureTableView()
                    }
                }
            })
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        
        let transition: CATransition = Design.slidePushFromRightTransition()
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
