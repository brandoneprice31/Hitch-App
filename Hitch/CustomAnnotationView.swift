//
//  CustomAnnotationView.swift
//  Hitch
//
//  Created by Brandon Price on 2/1/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import UIKit
import Mapbox

/* MGLAnnotationView subclass
class CustomAnnotationView: MGLAnnotationImage {
    
    var imageLayer : CALayer = CALayer()
    var isStart = Bool()
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        self.backgroundColor = UIColor.clear
        
        // Force the annotation view to maintain a constant size when the map is tilted.
        scalesWithViewingDistance = false
        
        // Add pop view.
        let image : UIImage
        if self.isStart {
            image = UIImage(named: "green-pin")!
        } else {
            image = UIImage(named: "red-pin")!
        }
        
        imageLayer.contents = image.cgImage
        imageLayer.bounds.size = self.frame.size
        //imageLayer.bounds.origin = CGPoint(x: imageLayer.bounds.width / 2.0, y: imageLayer.bounds.height / 2.0)
        layer.addSublayer(imageLayer)
    }
}*/
  
