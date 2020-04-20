//
//  ShopsCollectionViewDatasource.swift
//  Minifm
//
//  Created by Thomas on 2/27/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import Parse

private let FeedCellReuseIdentifier = "FeedCollectionViewCell"

class ShopsCollectionViewDatasource: NSObject, UICollectionViewDataSource {
    
    var viewModel : ShopsCollectionViewModel
    
    init(viewModel : ShopsCollectionViewModel) {
        self.viewModel = viewModel
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ShopCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCellId", for: indexPath as IndexPath) as! ShopCell
        let listingObject = viewModel.listings[indexPath.row]
        cell.model = listingObject
        return cell
    }
    
}
