//
//  ProfileViewDelegate.swift
//  Minifm
//
//  Created by Thomas on 7/9/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import RxSwift

class ProfileViewDelegate: NSObject, UICollectionViewDelegate {

    let cellSpacing : CGFloat = 1
    let rx_contentOffset = PublishSubject<CGPoint>()
    var viewModel : ProfileModel
    var clickedItemAtIndexPath : ((_ indexPath: NSIndexPath) -> Void)?
    
    init(viewModel : ProfileModel) {
        self.viewModel = viewModel
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //showFeedDetail
        clickedItemAtIndexPath?(indexPath as NSIndexPath)
    }

    
}

extension ProfileViewDelegate:  UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //print(#function)
        var width : CGFloat = 0.0
        var height : CGFloat = 0.0
        width = (collectionView.bounds.width / 3) - cellSpacing * 2
        height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset = CGFloat(cellSpacing)
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    @objc(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:) func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    @objc(collectionView:layout:minimumLineSpacingForSectionAtIndex:) func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, numberItemsPerLineForSectionAt section: Int) -> Int {
        return Int(3)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: RAMCollectionViewFlemishBondLayoutSwift, estimatedSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 253)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: RAMCollectionViewFlemishBondLayoutSwift, estimatedSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: RAMCollectionViewFlemishBondLayoutSwift, highlightedCellDirectionForGroup group: Int, atIndexPath indexPath: NSIndexPath) -> RAMCollectionViewFlemishBondLayoutGroupDirection {
        var direction: RAMCollectionViewFlemishBondLayoutGroupDirection
        if indexPath.row % 2 != 0 {
            direction = .Right
        } else {
            direction = .Left
        }
        return direction
    }
    
}
