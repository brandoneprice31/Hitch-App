//
//  HikingSearchMapVC.swift
//  Hitch
//
//  Created by Brandon Price on 2/7/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import UIKit
import MapKit
import Mapbox

class HikingSearchMapVC: UIViewController, MGLMapViewDelegate {
    
    var startLocation : Place!
    var endLocation : Place!
    var route : MKRoute!
    
    @IBOutlet var startLocationButton: UIButton!
    @IBOutlet var endLocationButton: UIButton!
    @IBOutlet var mapView: MGLMapView!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var box2: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Configure box2
        box2.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4.0)
        
        // Configure start and end location labels.
        startLocationButton.setTitle(startLocation.subtitle, for: .normal)
        startLocationButton.contentVerticalAlignment = .bottom
        //startLocationButton.titleLabel?.adjustsFontSizeToFitWidth = true
        let starttextRange = NSMakeRange(0, (startLocation.subtitle?.characters.count)!)
        let startattributedText = NSMutableAttributedString(string: startLocation.subtitle!)
        startattributedText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: starttextRange)
        startLocationButton.titleLabel?.attributedText = startattributedText
        startLocationButton.titleLabel?.minimumScaleFactor = 0.75
        
        endLocationButton.setTitle(endLocation.subtitle, for: .normal)
        endLocationButton.contentVerticalAlignment = .bottom
        //endLocationButton.titleLabel?.adjustsFontSizeToFitWidth = true
        let endtextRange = NSMakeRange(0, (endLocation.subtitle?.characters.count)!)
        let endattributedText = NSMutableAttributedString(string: endLocation.subtitle!)
        endattributedText.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.styleSingle.rawValue, range: endtextRange)
        endLocationButton.titleLabel?.attributedText = endattributedText
        endLocationButton.titleLabel?.minimumScaleFactor = 0.75
        
        // Configure the map.
        configureMapView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Function that configures the map.
    func configureMapView() {
        
        // Draw on map.
        Mapping.DrawDriveOnMapView(mapView: mapView, drive: Drive(driverFirstName: "", driverLastName: "", driverID: 0, start: startLocation, end: endLocation, startDateTime: DateTime(), endDateTime: DateTime(), repeatWeekDays: [], polyLine: nil, orRoute: route))
        
        // Configure the search button.
        searchButton.layer.borderColor = navyColor.cgColor
        searchButton.layer.borderWidth = 1.0
        searchButton.layer.cornerRadius = 5.0
    }
    
    @IBAction func startLocationClicked(_ sender: Any) {
        
        // Push search vc for start.
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "LocationSearchVC") as! LocationSearchVC
        nextVC.locationType = "Start"
        nextVC.nextVC = "mapView"
        nextVC.endLocation = endLocation
        nextVC.isHiking = true
        
        // Transition to search vc for start location.
        let transition: CATransition = Design.moveUpTransition()
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(nextVC, animated: false)
        
    }
    
    @IBAction func endLocationClicked(_ sender: Any) {
        
        // Push search vc for end.
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "LocationSearchVC") as! LocationSearchVC
        nextVC.locationType = "End"
        nextVC.nextVC = "mapView"
        nextVC.startLocation = startLocation
        nextVC.isHiking = true
        
        // Transition to search vc for start location.
        let transition: CATransition = Design.moveUpTransition()
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(nextVC, animated: false)
    }
    
    @IBAction func searchButtonClicked(_ sender: Any) {
        
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "HikeSearchResultsVC") as! HikeSearchResultsVC
        
        // Set the Annotations.
        nextVC.startLocation = self.startLocation
        nextVC.endLocation = self.endLocation
        
        // For debugging.
        nextVC.route = self.route
        
        let transition: CATransition = Design.moveUpTransition()
        self.navigationController?.view.layer.add(transition, forKey: nil)
        self.navigationController?.pushViewController(nextVC, animated: false)
        
    }

    @IBAction func backButtonClicked(_ sender: Any) {
        let transition: CATransition = Design.moveDownTransition()
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
