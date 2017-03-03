//
//  ViewControllerWithSpinner.swift
//  Hitch
//
//  Created by Brandon Price on 1/13/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import UIKit

class UIViewControllerWithSpinner: UIViewController {

    var visualEffectView : UIVisualEffectView!
    var spinner: UIActivityIndicatorView!

    
    // Method that presents the spinner.
    func pauseForSpinner () {
        
        // Create visual effect view.
        self.visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
        visualEffectView.frame = self.view.bounds
        
        // Create spinner.
        self.spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        spinner.center = visualEffectView.center
        spinner.startAnimating()
        
        // Add views.
        visualEffectView.addSubview(spinner)
        self.view.addSubview(visualEffectView)
    }
    
    // Method that gets rid of spinner.
    func unPause () {
        
        // Add animation.
        UIView.animate(withDuration: 0.5,
                       animations: {
                        
                        self.visualEffectView.alpha = 0.0
                        self.spinner.stopAnimating()
                        
        }, completion: { (isCompleted: Bool) -> Void in
                        
                        // Remove from views.
                        self.visualEffectView.removeFromSuperview()
        })
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
