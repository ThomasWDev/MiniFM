//
//  ShopsCollectionViewDelegate.swift
//  Minifm
//
//  Created by Thomas on 2/27/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import RxSwift

class ShopsCollectionViewDelegate: NSObject, UICollectionViewDelegate {
    
    let cellSpacing : CGFloat = 15
    let rx_contentOffset = PublishSubject<CGPoint>()
    var viewModel : ShopsCollectionViewModel
    var clickedItemAtIndexPath : ((_ indexPath: NSIndexPath) -> Void)?
    
    init(viewModel : ShopsCollectionViewModel) {
        self.viewModel = viewModel
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //showFeedDetail
        clickedItemAtIndexPath?(indexPath as NSIndexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        rx_contentOffset.onNext(scrollView.contentOffset)
    }
    
}

extension ShopsCollectionViewDelegate: RAMCollectionViewFlemishBondLayoutDelegate {
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: RAMCollectionViewFlemishBondLayoutSwift, estimatedSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
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
