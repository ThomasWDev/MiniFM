//
//  ShopCell.swift
//  Minifm
//
//  Created by Thomas on 2/28/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import Parse
import IDMPhotoBrowser

class ShopCell: UICollectionViewCell, IDMPhotoBrowserDelegate {
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addToCartLabel: UILabel!
    @IBOutlet weak var titleShopLabel: UILabel!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    fileprivate var listObject : PFObject?
    fileprivate var shoppingObject : PFObject?
    
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
        titleShopLabel.text = model[LISTING_PRODUCT_TITLE] as! String?
        priceLabel.text = "$\(model[LISTING_PRODUCT_LISTING_PRICE]!)"
        let file = model["\(LISTING_PRODUCT_PHOTOS)_0"] as! PFFile
        file.getDataInBackground { (data, error) in
            if data != nil {
                let image = UIImage(data: data!)
                self.imageView.image = image
            }
        }
        self.addToCartLabel.text = "Add to cart"
        IndicatorManager.shared.startIndicatorAnimation(inview: self)
        let query = PFQuery(className: SHOPPING_CART_CLASS_NAME)
        query.whereKey(SHOPPING_CART_LISTING_ID, equalTo: listObject!.objectId!)
        query.whereKey(SHOPPING_CART_OF_USER_ID, equalTo: PFUser.current()!.objectId!)
        query.getFirstObjectInBackground { (object, error) in
            IndicatorManager.shared.stopIndicatorAnimation(inview: self)
            if object != nil {
                self.addToCartLabel.text = "Added to cart"
                self.shoppingObject = object
            }
        }

    }
    
    @IBAction func onAddItemToShoppingClicked(_ sender: Any) {
        
        if self.addToCartLabel.text == "Added to cart" {
            if shoppingObject != nil {
                shoppingObject?.deleteInBackground(block: { (success, error) in
                    if success == true {
                        self.addToCartLabel.text = "Add to cart"
                    }
                })
            }
        } else {
            let shoppingCart = PFObject(className: SHOPPING_CART_CLASS_NAME)
            shoppingCart[SHOPPING_CART_LISTING_ID] = self.listObject?.objectId
            shoppingCart[SHOPPING_CART_OF_USER_ID] = PFUser.current()?.objectId
            shoppingCart[SHOPPING_CART_STATUS] = "Added"
            shoppingCart.saveInBackground { (success, error) in
                if success == true {
                    self.shoppingObject = shoppingCart
                    print("Successfully Added the item to shopping cart.")
                    self.addToCartLabel.text = "Added to cart"
                } else {
                    print("Added failure the item")
                }
            }
        }
        
    }
    
    
}
