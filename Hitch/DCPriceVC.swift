//
//  DCPriceVC.swift
//  Hitch
//
//  Created by Brandon Price on 2/8/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import UIKit

class DCPriceVC: UIViewController {

    @IBOutlet var priceLabel: UILabel!
    var currentPrice = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Slider changed.
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        currentPrice = Double(sender.value)
        let formattedPrice = getPriceString(price: currentPrice)
        priceLabel.text = formattedPrice
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
