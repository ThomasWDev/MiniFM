//
//  MatchesViewDelegate.swift
//  Minifm
//
//  Created by Thomas on 1/7/17.
//  Copyright © 2017 TBL tech nerds. All rights reserved.
//

import UIKit

class GalleryViewDelegate: NSObject, UITableViewDelegate {

    var clickedItemAtIndexPath : ((_ indexPath: NSIndexPath) -> Void)?
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        clickedItemAtIndexPath?(indexPath as NSIndexPath)
    }
    
}
