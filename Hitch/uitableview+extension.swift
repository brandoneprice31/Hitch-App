//
//  uitableview+extension.swift
//  Hitch
//
//  Created by Brandon Price on 2/12/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    func indexPathsForRowsInSection(_ section: Int) -> [IndexPath] {
        let numberOfRows = self.numberOfRows(inSection: section)
        return (0..<numberOfRows).map{IndexPath(row: $0, section: section)}
    }
    
}
