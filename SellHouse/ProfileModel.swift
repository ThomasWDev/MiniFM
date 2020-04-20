//
//  ProfileModel.swift
//  Minifm
//
//  Created by Thomas on 7/9/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import RxSwift
import Parse

class ProfileModel: NSObject {

    var rx_loading = Variable(false)
    var count : Int = 0
    var newItemsAdded : ((_ range: NSRange) -> Void)?
    var listings = [PFObject]()
    var isGallery = false
    
    func fetchMoreData(listingsType : Int, otherUser : PFObject? = nil) {
        
        self.listings.removeAll()
        if isGallery == true {
            if listingsType == 2 { //Gallery
                let query = PFQuery(className: ACTIVITY_FEED_CLASS_NAME)
                if otherUser != nil {
                    query.whereKey(ACTIVITY_FEED_BY_USER, equalTo: otherUser!)
                } else {
                    query.whereKey(ACTIVITY_FEED_BY_USER, equalTo: PFUser.current()!)
                }
                rx_loading.value = true
                query.findObjectsInBackground { (result, error) in
                    self.rx_loading.value = false
                    if let result = result {
                        if result.count > 0 {
                            self.listings.append(contentsOf: result)
                        }
                    }
                    self.count = self.listings.count
                    let range = NSRange.init(location: 0, length: self.listings.count)
                    self.newItemsAdded!(range)
                }
            } else {
                let query = PFQuery(className: ACTIVITY_FAVES_CLASS_NAME)
                if otherUser != nil {
                    query.whereKey(ACTIVITY_FAVES_BY_USER, equalTo: otherUser!)
                } else {
                    query.whereKey(ACTIVITY_FAVES_BY_USER, equalTo: PFUser.current()!)
                }
                
                query.includeKey(ACTIVITY_FAVES_FOR_FEED)
                rx_loading.value = true
                query.findObjectsInBackground { (result, error) in
                    self.rx_loading.value = false
                    if let result = result {
                        if result.count > 0 {
                            self.listings.append(contentsOf: result)
                        }
                        
                    }
                    self.count = self.listings.count
                    let range = NSRange.init(location: 0, length: self.listings.count)
                    self.newItemsAdded!(range)
                }
            }
            
        } else {
            let query = PFQuery(className: LISTING_CLASS_NAME)
            if otherUser != nil { //My listings
                query.whereKey(LISTING_PRODUCT_OWNER, equalTo: otherUser!)
            } else {
                query.whereKey(LISTING_PRODUCT_OWNER, equalTo: PFUser.current()!)
            }
            rx_loading.value = true
            query.findObjectsInBackground { (result, error) in
                self.rx_loading.value = false
                if let result = result {
                    if result.count > 0 {
                        self.listings.append(contentsOf: result)
                        
                    }
                }
                self.count = self.listings.count
                let range = NSRange.init(location: 0, length: self.listings.count)
                self.newItemsAdded!(range)
            }
        }
    }
    
}
