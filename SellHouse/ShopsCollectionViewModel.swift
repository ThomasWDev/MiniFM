//
//  ShopsCollectionViewModel.swift
//  Minifm
//
//  Created by Thomas on 2/27/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import RxSwift
import Parse

class ShopsCollectionViewModel: NSObject {
    
    var rx_loading = Variable(false)
    var count : Int = 0
    var newItemsAdded : ((_ range: NSRange) -> Void)?
    var listings = [PFObject]()
    
    func fetchMoreData(isFollowing : Bool) {
        
        self.listings.removeAll()
        if isFollowing == true {
            let query = PFQuery(className: LISTING_CLASS_NAME)
            query.whereKey(LISTING_PRODUCT_OWNER, equalTo: PFUser.current()!)
            rx_loading.value = true
            query.findObjectsInBackground { (result, error) in
                self.rx_loading.value = false
                if let result = result {
                    if result.count > 0 {
                        self.listings.append(contentsOf: result)
                        self.count = self.listings.count
                        let range = NSRange.init(location: 0, length: self.listings.count)
                        self.newItemsAdded!(range)
                    }
                }
            }
        } else {
            let query = PFQuery(className: LISTING_CLASS_NAME)
            rx_loading.value = true
            query.findObjectsInBackground { (result, error) in
                self.rx_loading.value = false
                if let result = result {
                    if result.count > 0 {
                        self.listings.append(contentsOf: result)
                        self.count = self.listings.count
                        let range = NSRange.init(location: 0, length: self.listings.count)
                        self.newItemsAdded!(range)
                    }
                }
            }

        }
        
    }
    
}
