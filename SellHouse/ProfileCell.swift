//
//  ProfileCell.swift
//  Minifm
//
//  Created by Thomas on 7/10/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import Parse
import IDMPhotoBrowser

class ProfileCell: UICollectionViewCell, IDMPhotoBrowserDelegate {

    @IBOutlet weak var imageView: UIImageView!
    fileprivate var listObject : PFObject?
    var isGallery = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(onOpenPhoto))
        imageView.addGestureRecognizer(tap)
        imageView.isUserInteractionEnabled = true
    }

    func onOpenPhoto() {
        if let image = imageView.image  {
            let window = UIApplication.shared.keyWindow
            var idmphotos : [IDMPhoto] = []
            let photo = IDMPhoto(image: image)
            if let object = listObject {
                photo?.caption = object[LISTING_PRODUCT_TITLE] as! String!
            }
            idmphotos.append(photo!)
            let browser : IDMPhotoBrowser = IDMPhotoBrowser(photos: idmphotos)
            browser.delegate = self
            browser.displayActionButton = false
            browser.displayArrowButton = true
            browser.displayCounterLabel = true
            browser.usePopAnimation = true
            browser.setInitialPageIndex(0)
            browser.useWhiteBackgroundColor = false
            window?.topViewController()?.present(browser, animated: true, completion: nil)
        }
    }
    
    var model : PFObject? {
        didSet {
            
            bind(model: model!)
        }
    }
    
    func bind( model : PFObject ) {
        listObject = model
        if listObject?.parseClassName == ACTIVITY_FAVES_CLASS_NAME {
            let feedObject = listObject?[ACTIVITY_FAVES_FOR_FEED] as? PFObject
            let file = feedObject?[ACTIVITY_FEED_FILE] as! PFFile
            self.imageView.image = nil
            if file.isDataAvailable == true {
                file.getPathInBackground(block: { (path, error) in
                    let image = UIImage(contentsOfFile: path!)
                    self.imageView.image = image
                })
            } else {
                file.getDataInBackground { (data, error) in
                    if let data = data {
                        let image = UIImage(data: data)
                        self.imageView.image = image
                    }
                }
            }
        } else {
            if isGallery == true {
                let file = listObject?[ACTIVITY_FEED_FILE] as! PFFile
                self.imageView.image = nil
                if file.isDataAvailable == true {
                    file.getPathInBackground(block: { (path, error) in
                        let image = UIImage(contentsOfFile: path!)
                        self.imageView.image = image
                    })
                } else {
                    file.getDataInBackground { (data, error) in
                        if let data = data {
                            let image = UIImage(data: data)
                            self.imageView.image = image
                        }
                    }
                }
            } else {
                let file = model["\(LISTING_PRODUCT_PHOTOS)_0"] as! PFFile
                file.getDataInBackground { (data, error) in
                    if data != nil {
                        let image = UIImage(data: data!)
                        self.imageView.image = image
                    }
                }
            }
        }
        
    }


}
