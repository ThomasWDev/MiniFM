//
//  ProfileHeaderView.swift
//  Minifm
//
//  Created by Thomas on 7/9/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import Parse

class ProfileHeaderView: UICollectionReusableView {
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!
    var isMyProfile = false
    var otherUser: PFObject?
 
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height/2
        avatarImageView.backgroundColor = UIColor.gray
        settingsButton.layer.masksToBounds = true
        settingsButton.layer.cornerRadius = 4
        buttons[0] .setTitleColor(UIColor.red, for: .normal)
        nameLabel.text = ""
        settingsButton.isHidden = true
        coverImageView.backgroundColor = UIColor.lightGray
    }
    
    func bind() {
        var currentUser : PFObject?
        if isMyProfile == true || PFUser.current()?.objectId ==  otherUser?.objectId  {
            settingsButton.isHidden = false
            currentUser = PFUser.current()
        } else {
            settingsButton.isHidden = true
            currentUser = otherUser
        }
        var name = ""
        if let firstname = currentUser?[USER_FIRSTNAME] as? String {
            name = firstname
        }
        if let lastname = currentUser?[USER_LASTNAME] as? String {
            name = "\(name) \(lastname)"
        }
        nameLabel.text = name
        
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
                self.avatarImageView.image = image
            }
        }
    }
    
    @IBAction func onButtonClicked(_ sender: UIButton) {
        if sender == buttons[0] { //Listing
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ButtonClicked"), object: "0")
        } else if sender == buttons[1] { //Faves
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ButtonClicked"), object: "1")
        } else { //Gallery
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ButtonClicked"), object: "2")
        }
        for button in buttons {
            if button == sender {
                button.setTitleColor(UIColor.red, for: .normal)
            } else {
                button.setTitleColor(UIColor(hex6: 0x646464), for: .normal)
            }
        }
    }
    
    @IBAction func onSettingsClicked(_ sender: Any) {
        let profileController = STORYBOARDS.SIGNIN_STORYBOARD.instantiateViewController(withIdentifier: "MFProfileViewControllerId") as! MFProfileViewController
        let controller = UIApplication.shared.keyWindow?.topViewController()
        if (controller?.isKind(of: UINavigationController.classForCoder()))! {
            (controller as! UINavigationController).pushViewController(profileController, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: profileController)
            controller?.present(nav, animated: true, completion: nil)
        }
        
    }
    
    
}
