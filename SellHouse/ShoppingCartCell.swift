//
//  ShoppingCartCell.swift
//  Minifm
//
//  Created by Thomas on 7/4/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import Parse

class ShoppingCartCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var shopnameLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productDescriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var shippingMethodLabel: UILabel!
    @IBOutlet weak var totaldueLabel: UILabel!
    @IBOutlet weak var processCheckOutButton: UIButton!
    var currentShoppingObject : PFObject?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        processCheckOutButton.layer.masksToBounds = true
        processCheckOutButton.layer.borderColor = UIColor(hex6: 0xfa485b).cgColor
        processCheckOutButton.layer.borderWidth = 1
        processCheckOutButton.backgroundColor = UIColor.clear
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = 2
        avatarImageView.backgroundColor = UIColor.gray
        productImageView.backgroundColor = UIColor.gray
        shopnameLabel.text = ""
        productDescriptionLabel.text = ""
        priceLabel.text = ""
        totaldueLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bind(object : PFObject) {
        currentShoppingObject = object
        IndicatorManager.shared.startIndicatorAnimation(inview: self)
        let query = PFQuery(className: LISTING_CLASS_NAME)
        query.whereKey("objectId", equalTo: object[SHOPPING_CART_LISTING_ID])
        query.includeKey(LISTING_PRODUCT_OWNER)
        query.getFirstObjectInBackground { (object, error) in
            IndicatorManager.shared.stopIndicatorAnimation(inview: self)
            if object != nil {
                self.productDescriptionLabel.text = "\(object![LISTING_PRODUCT_TITLE] as? String ?? "") \(object![LISTING_PRODUCT_DESCRIPTION] ?? "")"
                self.priceLabel.text = "Price: $\(String(describing: object![LISTING_PRODUCT_LISTING_PRICE]!))"
                self.totaldueLabel.text = "$\(String(describing: object![LISTING_PRODUCT_LISTING_PRICE]!))"
                let file = object?["\(LISTING_PRODUCT_PHOTOS)_0"] as! PFFile
                file.getDataInBackground { (data, error) in
                    if data != nil {
                        let image = UIImage(data: data!)
                        self.productImageView.image = image
                    }
                }
                let owner = object?[LISTING_PRODUCT_OWNER] as! PFUser
                self.shopnameLabel.text = owner[USER_FULLNAME] as? String
                let fileAvatar = owner[USER_AVATAR] as? PFFile
                self.avatarImageView.image = nil
                if fileAvatar?.isDataAvailable == true {
                    fileAvatar?.getPathInBackground(block: { (path, error) in
                        let image = UIImage(contentsOfFile: path!)
                        self.avatarImageView.image = image
                    })
                } else {
                    fileAvatar?.getDataInBackground { (data, error) in
                        if let data = data {
                            let image = UIImage(data: data)
                            self.avatarImageView.image = image
                        }
                    }
                }


            }
        }
        
    }
    
    //MARK: Actions
    
    
    @IBAction func onProcessCheckoutClicked(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ProcessCheckout"), object: currentShoppingObject)
        
    }

    @IBAction func onRemoveItemClicked(_ sender: Any) {
        
        if let object = currentShoppingObject {
            object.deleteInBackground(block: { (success, error) in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RemovedItemInShoppingCart"), object: object)
            })
        }
    }
    
    @IBAction func onVisitShopClicked(_ sender: Any) {
        
    }
    
}
