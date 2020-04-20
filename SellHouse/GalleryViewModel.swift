//
//  MatchesViewModel.swift
//  Minifm
//
//  Created by Thomas on 1/7/17.
//  Copyright © 2017 TBL tech nerds. All rights reserved.
//

import UIKit
import Parse
//import RxCocoa
import RxSwift

class GalleryViewModel: NSObject {

    private var feeds : [PFObject] = []
    let rx_loading : Variable<Bool?> = Variable(false)
    var newItemsAdded : ((_ range: NSRange) -> Void)?
    private let numberFeedsPerPage = 20
    
    var count : Int {
        get {
            return feeds.count
        }
    }
    
    func viewModel( at index : Int) -> PFObject {
        return feeds[index]
    }
    
    func numberOfItem() -> Int {
        return feeds.count
    }
    
    func getFeeds() {
        feeds.removeAll()
        rx_loading.value = true
        let queryPost = PFQuery(className: ACTIVITY_FEED_CLASS_NAME)
        queryPost.limit = numberFeedsPerPage
        queryPost.includeKey(ACTIVITY_FEED_BY_USER)
        //queryPost.whereKey(ACTIVITY_FEED_BY_USER, equalTo: PFUser.current()!)
        queryPost.findObjectsInBackground(block: { (result, error) in
            self.rx_loading.value = false
            if let data = result {
                self.feeds.append(contentsOf: data)
                self.newItemsAdded?(NSRange(location: (self.feeds.count - data.count), length: data.count))
            }
            
        })
        
    }
    
    func loadMoreFeeds(){
        
        let queryPost = PFQuery(className: ACTIVITY_FEED_CLASS_NAME)
        queryPost.skip = self.feeds.count
        queryPost.limit = numberFeedsPerPage
        queryPost.includeKey(ACTIVITY_FEED_BY_USER)
        //queryPost.whereKey(ACTIVITY_FEED_BY_USER, equalTo: PFUser.current()!)
        queryPost.findObjectsInBackground(block: { (result, error) in
            if let data = result {
                self.feeds.append(contentsOf: data)
                self.newItemsAdded?(NSRange(location: (self.feeds.count - data.count), length: data.count))
            }
            
        })
    }
    
    func pullRefresh() {
        if rx_loading.value == true {
            return
        }
        feeds.removeAll()
        self.newItemsAdded?(NSRange(location: 0, length: 0))
        rx_loading.value = true
        let queryPost = PFQuery(className: ACTIVITY_FEED_CLASS_NAME)
        queryPost.limit = numberFeedsPerPage
        queryPost.includeKey(ACTIVITY_FEED_BY_USER)
        //queryPost.whereKey(ACTIVITY_FEED_BY_USER, equalTo: PFUser.current()!)
        queryPost.findObjectsInBackground(block: { (result, error) in
            self.rx_loading.value = false
            if let data = result {
                self.feeds.append(contentsOf: data)
                self.newItemsAdded?(NSRange(location: (self.feeds.count - data.count), length: data.count))
            }
            
        })
    }

}
