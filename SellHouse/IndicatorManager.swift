//
//  IndicatorManager.swift
//  Minifm
//
//  Created by Thomas Woodfin on 11/2/16.
//  Copyright © 2016 Sprinklenet Labs. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import UIColor_Hex_Swift

class IndicatorManager: NSObject {

    static let shared = IndicatorManager()
    
    lazy var activityIndicatorView : NVActivityIndicatorView = {
        let frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let activityIndicatorView = NVActivityIndicatorView(frame: frame, type: .ballSpinFadeLoader, color: UIColor(hex6: 0xf05638), padding: 0)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()
    
    /* Discussion
     *
     * Show indicator view with an animation. Just use it for long tasks which take long times.
     * Remember that It will not allow user to interact while the indicator is showing.
     */
    
    func startIndicatorAnimation( inview : UIView) {
        inview.isUserInteractionEnabled = false
        inview.addSubview(activityIndicatorView)
        let horizontalConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: inview, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: inview, attribute: NSLayoutAttribute.centerY, multiplier: 0.8, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 24)
        let heightConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 24)
        inview.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        activityIndicatorView.startAnimating()
    }
    
    /* Discussion
     *
     * Stop animation of the indicator.
     */
    
    func stopIndicatorAnimation(inview : UIView) {
        if activityIndicatorView != nil {
            inview.isUserInteractionEnabled = true
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
        }
    }

    
}
