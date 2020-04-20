//
//  ProfileViewDatasource.swift
//  Minifm
//
//  Created by Thomas on 7/9/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import Parse

class ProfileViewDatasource: NSObject, UICollectionViewDataSource {

    var viewModel : ProfileModel
    var isMyprofile = false
    var otherUser : PFObject?
    
    init(viewModel : ProfileModel) {
        self.viewModel = viewModel
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ProfileCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCell", for: indexPath as IndexPath) as! ProfileCell
        let listingObject = viewModel.listings[indexPath.row]
        cell.isGallery = viewModel.isGallery
        cell.model = listingObject
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionElementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ProfileHeaderView", for: indexPath) as! ProfileHeaderView
            headerView.otherUser = otherUser
            headerView.isMyProfile = isMyprofile
            headerView.bind()
            return headerView
        default:
            
            return UICollectionReusableView()
        }
    }
    
}
