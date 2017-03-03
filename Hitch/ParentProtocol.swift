//
//  ParentProtocol.swift
//  Hitch
//
//  Created by Brandon Price on 1/15/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation

// Protocol for parent classes that want methods to be called from a child.
protocol ParentProtocol : class
{
    func method(args: [Any])
}
