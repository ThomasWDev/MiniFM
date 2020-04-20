//
//  MFLeftMenuViewController.swift
//  Minifm
//
//  Created by Thomas on 2/10/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import Parse

class MFLeftMenuViewController: MFBaseViewController {

    
    @IBOutlet weak var shoppingCartCountLabel: UIButton!
    @IBOutlet weak var shoppingCartView: UIView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeStyle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bindProfile()
        countShoppingCart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Helper methods
    
    override func initializeStyle() {
        coverImageView.backgroundColor = UIColor.lightGray
        coverImageView.image = nil
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height/2
        let tap = UITapGestureRecognizer(target: self, action: #selector(onEditProfile(_:)))
        coverImageView.addGestureRecognizer(tap)
        coverImageView.isUserInteractionEnabled = true
        avatarImageView.addTarget(self, action: #selector(onEditProfile(_:)), for: .touchUpInside)
        //Setup touch event for Shopping cart view
        let shopTap = UITapGestureRecognizer(target: self, action: #selector(onShoppingView(_:)))
        shoppingCartView.addGestureRecognizer(shopTap)
        shoppingCartView.isUserInteractionEnabled = true
    }
    
    func bindProfile() {
        let currentUser = PFUser.current()
        nameLabel.text = currentUser?[USER_FULLNAME] as? String
        let file = currentUser?[USER_COVER] as? PFFile
        file?.getDataInBackground { (data, error) in
            if let data = data {
                let image = UIImage(data: data)
                self.coverImageView.image = image
            }
        }
        let fileAvatar = currentUser?[USER_AVATAR] as? PFFile
        fileAvatar?.getDataInBackground { (data, error) in
            if let data = data {
                let image = UIImage(data: data)
                self.avatarImageView.setBackgroundImage(image, for: .normal)
            }
        }
    }
    
    func countShoppingCart() {
        let query = PFQuery(className: SHOPPING_CART_CLASS_NAME)
        query.whereKey(SHOPPING_CART_OF_USER_ID, equalTo: PFUser.current()!.objectId!)
        query.countObjectsInBackground { (count, error) in
            if error == nil {
                self.shoppingCartCountLabel.setTitle("Cart (\(count))", for: .normal)
            }
        }
    }
    
    //MARK: - Actions
    
    @IBAction func onEditProfile(_ sender : Any) {
        let profileController = STORYBOARDS.SIGNIN_STORYBOARD.instantiateViewController(withIdentifier: "MFMainProfileViewController") as! MFMainProfileViewController
        profileController.isMyprofile = true
        (slideMenuController()?.mainViewController as! UINavigationController).pushViewController(profileController, animated: true)
        slideMenuController()?.closeLeft()
    }
    
    @IBAction func onShoppingView(_ sender : Any) {
        
        let shoppingController = STORYBOARDS.FEED_STORYBOARD.instantiateViewController(withIdentifier: "MFShoppingCartViewController") as! MFShoppingCartViewController
        
        (slideMenuController()?.mainViewController as! UINavigationController).pushViewController(shoppingController, animated: true)
        slideMenuController()?.closeLeft()
        
    }
    
    
    @IBAction func onMenuItemClicked(_ sender : UIButton) {
        if sender.tag == 1 {
            sellController()
        } else if sender.tag == 2 {
            shopController()
        } else if sender.tag == 3 {
            galleryController()
        } else if sender.tag == 5 {
            friendController()
        } else if sender.tag == 6 {
            helpController()
        } else {
            //inboxController()
            helpController()
        }
        
    }

}
