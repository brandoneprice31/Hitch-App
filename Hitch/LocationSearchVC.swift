//
//  LocationSearchVC.swift
//  Hitch
//
//  Created by Brandon Price on 1/31/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Mapbox

class LocationSearchVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, MKLocalSearchCompleterDelegate {

    var locationType = String()
    var nextVC = String()
    var isHiking = Bool()
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    let locMan: CLLocationManager = AppDelegate().locMan
    var startLocation : Place!
    var endLocation : Place!
    var directions : MKDirections!
    var isDrivingDrive : Drive? = nil
    
    @IBOutlet var topView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Configure the title.
        titleLabel.text = locationType + " Location"
        
        // Configure the image.
        if isHiking {
            imageView.image = UIImage(named: "hitch-logo")
        } else {
            imageView.image = UIImage(named: "car")
        }
        
        // Search Completer configuration.
        self.searchCompleter.delegate = self
        self.searchCompleter.region = MKCoordinateRegion(center: (locMan.location!).coordinate, span: MKCoordinateSpan(latitudeDelta: 3.0, longitudeDelta: 3.0))
        
        // Make searchTF first responder.
        searchTF.becomeFirstResponder()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // Textfield returned.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //gotoNextVC()
        return false
    }
    
    // Editing changed in textfield.
    @IBAction func searchTFEditingChanged(_ sender: UITextField) {
        
        if searchTF.text == nil || searchTF.text! == "" {
            // reload table if it's empty.
            tableView.reloadData()
        } else {
            // Update the search completer.
            self.searchCompleter.queryFragment = sender.text!
        }
    }
    
    // MKLocalSearchCompleter updated search results.
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        
        // Get the search results and reload table.
        self.searchResults = Array(completer.results.prefix(7))
        self.tableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle the errors.
    }
    
    // Number of sections in tableview.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Number of rows in tableview.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchTF.text == nil || searchTF.text! == "" {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    // Cell Height.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchTF.text == nil || searchTF.text! == "" {
            return 30.0
        } else {
            return 45.0
        }
    }
    
    // Cell for row in tableview.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchTF.text == nil || searchTF.text! == "" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "InstructionsCell")
            
            if searchCompleter.isSearching {
                
                cell?.textLabel?.text = "Searching..."

            } else {
                cell?.textLabel!.text = "Start typing to search for a location"
            }
            
            
            return cell!

        } else {
            let searchResult = searchResults[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell")
            cell?.textLabel?.text = searchResult.title
            cell?.detailTextLabel?.text = searchResult.subtitle
            return cell!
        }
    }
    
    // Did select row.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchTF.text != nil && searchTF.text! != "" {
            
            // Place selected title into searchTF and clear selection for going backwards purposes.
            searchTF.text = searchResults[indexPath.row].title
            tableView.deselectRow(at: indexPath, animated: false)
            
            // Check to see if this is a valid
            searchForPlace(completion: searchResults[indexPath.row])
        }
    }
    
    // Helper that sees what the coordinates are for this place.
    func searchForPlace (completion: MKLocalSearchCompletion) {
        
        // Send a search request.
        let searchRequest = MKLocalSearchRequest(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        
        self.pauseEverythingWithoutSpinner()
        
        // Start search.
        search.start { (response, error) in
            
            self.unPauseEverythingWithoutSpinner()
            
            if error != nil {
                
                // Handle the error.
                print(error.debugDescription)
                
            } else {
                
                if response != nil {
                    
                    // Get the mapItem.
                    let location: MKMapItem = response!.mapItems[0]
                    
                    self.gotoNextVC(result: location, completion: completion)
                    
                } else {
                    print("response is empty")
                }
            }
        }
    }
    
    // Helper function for going to next vc.
    func gotoNextVC (result: MKMapItem, completion: MKLocalSearchCompletion) {
        
        // Set the start and end location.
        if locationType == "Start" {
            
            startLocation = Place(title: completion.title, subtitle: completion.subtitle, coordinate: result.placemark.coordinate)

        } else {
            
            endLocation = Place(title: completion.title, subtitle: completion.subtitle, coordinate: result.placemark.coordinate)
        }
        
        if nextVC == "End" {
            
            // If we're on start then go to an end location search.
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "LocationSearchVC") as! LocationSearchVC
            nextVC.nextVC = "mapView"
            nextVC.locationType = "End"
            nextVC.isHiking = self.isHiking
            nextVC.startLocation = startLocation
            let transition: CATransition = Design.moveUpTransition()
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.pushViewController(nextVC, animated: false)
            
        } else {
            
            // If we're hiking then we goto HikeSearchResults VC.
            if isHiking {
                
                calculateRoute(start: self.startLocation, end: self.endLocation, endTime: nil, nextVC: "HikingSearchMapVC")
                
            } else {
                
                if isDrivingDrive == nil {
                    // Goto Drive Create VC.
                    // Instantiate the vc.
                    let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "DriveCreateVC") as! DriveCreateVC
                    
                    // Send nextVC appropriate data.
                    nextVC.startLocation = self.startLocation
                    nextVC.endLocation = self.endLocation
                    
                    // Perform transition.
                    let transition: CATransition = Design.moveUpTransition()
                    self.navigationController?.view.layer.add(transition, forKey: nil)
                    self.navigationController?.pushViewController(nextVC, animated: false)
                    
                } else {
                    
                    // Calculate new route.
                    calculateRoute(start: self.startLocation, end: self.endLocation, endTime: self.isDrivingDrive?.endDateTime.date, nextVC: "DriveDetailsVC")
                    
                }
            }
        }
    }
    
    func calculateRoute (start: Place, end: Place, endTime: Date?, nextVC: String) {
        
        // Create directions request.
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start.coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end.coordinate))
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        
        if endTime != nil {
            request.arrivalDate = endTime!
        }
        
        // Perform directions request.
        directions = MKDirections(request: request)
        
        self.pauseViewWithAnimation(view: self.view, animationName: "spinner", text: "Calculating route...")
        
        directions.calculate(completionHandler: {
            
            (response, error) in
            
            self.unPauseViewAndRemoveAnimation(view: self.view)
            
            if error != nil {
                // Handle the error.
                fatalError("\(error)")
            }
            
            if let routeResponse = response?.routes {
                
                // Handle the response.
                let route = routeResponse.first
                
                if nextVC == "HikingSearchMapVC" {
                    
                    // Delete any current HikeSearchResultsVCs.
                    for vc in (self.navigationController?.viewControllers)! {
                        
                        let resultsVC = vc as? HikeSearchResultsVC
                        if resultsVC != nil {
                            resultsVC?.removeFromParentViewController()
                        }
                    }
                    
                    // Instantiate HikingSearchMapVC
                    let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "HikingSearchMapVC") as! HikingSearchMapVC
                    
                    // Send nextVC appropriate data.
                    nextVC.startLocation = self.startLocation
                    nextVC.endLocation = self.endLocation
                    nextVC.route = route
                    
                    // Perform transition.
                    let transition: CATransition = Design.moveDownTransition()
                    self.navigationController?.view.layer.add(transition, forKey: nil)
                    self.navigationController?.pushViewController(nextVC, animated: false)
                    
                    // Delete any current LocationSearchVCs.
                    for vc in (self.navigationController?.viewControllers)! {
                        
                        let searchVC = vc as? LocationSearchVC
                        if searchVC != nil {
                            searchVC?.removeFromParentViewController()
                        }
                    }
                    
                } else if nextVC == "DriveDetailsVC" {
                    
                    // Go to DriveDetailsVC.
                    let driveDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "DriveDetailsVC") as! DriveDetailsVC
                    
                    if self.locationType == "Start" {
                        self.isDrivingDrive?.start = self.startLocation
                    } else {
                        self.isDrivingDrive?.end = self.endLocation
                    }
                    
                    self.isDrivingDrive?.startDateTime = (self.isDrivingDrive?.endDateTime.subtractTimeInterval(timeInteral: (route?.expectedTravelTime)!))!
                    self.isDrivingDrive?.polyline = MGLPolyline.MKPolylineToMGLPolyine(mkPolyline: (route?.polyline)!)
                    driveDetailsVC.drive = self.isDrivingDrive
                    
                    // Perform transition.
                    let transition: CATransition = Design.moveUpTransition()
                    self.navigationController?.view.layer.add(transition, forKey: nil)
                    self.navigationController?.pushViewController(driveDetailsVC, animated: false)
                    
                    // Pop all vc's except the main and driveDetailsVC.
                    for vc in (self.navigationController?.viewControllers)! {
                        
                        let mainVC = vc as? MainVC
                        let orDriveDetailsVC = vc as? DriveDetailsVC
                        
                        if mainVC == nil && orDriveDetailsVC == nil {
                            // Pop it.
                            self.navigationController?.viewControllers.remove(at: (self.navigationController?.viewControllers.index(of: vc))!)
                        }
                    }
                    
                }
            }
            
        })
        
    }

    // Back button clicked.
    @IBAction func backButtonClicked(_ sender: Any) {
        
        // Simply pop the current vc.
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
