//
//  HitchedDrive.swift
//  Hitch
//
//  Created by Brandon Price on 2/20/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation

typealias HitchedDrives = [Int:[String:Any]]

func createNewHitchedDrives () -> HitchedDrives {
    
    return Dictionary<Int,Dictionary<String,Any>>()
}

/*
 
 Type Format:
 
 [
    driveID:  [     "driver"    :   User
                    "drive"     :   Drive
                    "hitches"   :   [   hitchID       :   [     "hitch" :   hitch
                                                                hitchHiker"    :   User]
                                    ]
 ]

*/
