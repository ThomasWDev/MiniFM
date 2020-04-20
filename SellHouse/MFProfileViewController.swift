//
//  MFProfileViewController.swift
//  Minifm
//
//  Created by Thomas on 2/14/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import Parse

class MFProfileViewController: MFBaseViewController, FusumaDelegate {

    
    @IBOutlet weak var avatarImageView: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var localtionTextField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var editCoverView: UIView!
    @IBOutlet weak var editAvatarView: UIView!
    
    private var isEditCover = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func initializeStyle() {
        super.initializeStyle()
        coverImageView.image = nil
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(onSaveClicked(_:)))
        nameLabel.text = ""
        usernameTextField.setLeftPaddingPoints(8)
        firstNameTextField.setLeftPaddingPoints(8)
        emailTextField.setLeftPaddingPoints(8)
        lastNameTextField.setLeftPaddingPoints(8)
        localtionTextField.setLeftPaddingPoints(8)
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height/2
        editCoverView.layer.masksToBounds = true
        editCoverView.layer.cornerRadius = editCoverView.frame.height/2
        editAvatarView.layer.masksToBounds = true
        editAvatarView.layer.cornerRadius = editCoverView.frame.height/2
        let tapAvatar = UITapGestureRecognizer(target: self, action: #selector(onEditAvatarClicked))
        editAvatarView.addGestureRecognizer(tapAvatar)
        editAvatarView.isUserInteractionEnabled = true
        editAvatarView.tag = 2
        let tapCover = UITapGestureRecognizer(target: self, action: #selector(onEditCoverClicked))
        editCoverView.addGestureRecognizer(tapCover)
        editCoverView.isUserInteractionEnabled = true
        editCoverView.tag = 1
        usernameTextField.isEnabled = false
        bindProfile()
    }
    
    override func onBackClicked(sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fusumaImageSelected(_ image: UIImage) {
        
    }
    
    func fusumaDidSelected(controller: UIViewController, _ image: UIImage) {
        
        controller.dismiss(animated: true) {
            if self.isEditCover == true {
                self.coverImageView.image = image
            } else {
                self.avatarImageView.setBackgroundImage(image, for: .normal)
            }
        }
    }
    
    func fusumaClosed() {
        
    }
    
    func fusumaDismissedWithImage(_ image: UIImage) {
        
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
    }
    
    func fusumaCameraRollUnauthorized() {
        
    }
    
    //MARK: - Helper methods
    
    func bindProfile() {
        
        let currentUser = PFUser.current()
        usernameTextField.text = currentUser?.username
        emailTextField.text = currentUser?.email
        firstNameTextField.text = currentUser?[USER_FIRSTNAME] as? String
        lastNameTextField.text = currentUser?[USER_LASTNAME] as? String
        localtionTextField.text = currentUser?[USER_LOCATION] as? String
        bioTextView.text = currentUser?[USER_BIO] as? String
        
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
    
    func validate() -> Bool {
        if emailTextField.text == "" {
            simpleAlert("Please enter email.")
            return false
        } else if firstNameTextField.text == "" {
            simpleAlert("Please enter first name.")
            return false
        } else if lastNameTextField.text == "" {
            simpleAlert("Please enter last name.")
            return false
        }
        return true
    }
    
    //MARK: - Actions
    
    @IBAction func onSaveClicked(_ sender : Any) {
        
        if validate() == true {
            let currrentUser = PFUser.current()
            let avatarImage = avatarImageView.backgroundImage(for: .normal)
            if avatarImage != nil {
                let udidAvatar = NSUUID().uuidString.appending(".png")
                let fileAvatar = PFFile(name: udidAvatar, data: UIImageJPEGRepresentation(avatarImage!, 0.5)!)
                currrentUser?[USER_AVATAR] = fileAvatar
            }
            let coverImage = coverImageView.image
            if coverImage != nil {
                let udidCover = NSUUID().uuidString.appending(".png")
                let fileCover = PFFile(name: udidCover, data: UIImageJPEGRepresentation(coverImage!, 0.5)!)
                currrentUser?[USER_COVER] = fileCover
            }
            currrentUser?.email = emailTextField.text
            currrentUser?[USER_FIRSTNAME] = firstNameTextField.text
            currrentUser?[USER_LASTNAME] = lastNameTextField.text
            currrentUser?[USER_FULLNAME] = "\(firstNameTextField.text!) \(lastNameTextField.text!)"
            if bioTextView.text != "" {
                 currrentUser?[USER_BIO] = bioTextView.text
            }
            if localtionTextField.text != "" {
                currrentUser?[USER_LOCATION] = localtionTextField.text
            }
            IndicatorManager.shared.startIndicatorAnimation(inview: self.view)
            currrentUser?.saveInBackground(block: { (success, error) in
                IndicatorManager.shared.stopIndicatorAnimation(inview: self.view)
                if error == nil && success == true {
                    self.simpleAlert("Profile updated successfully.")
                } else {
                    self.simpleAlert("\(error?.localizedDescription)")
                }
            })
        }
    }
    
    func onEditCoverClicked() {
        isEditCover = true
        showCamera(animated: true)
    }
    
    func onEditAvatarClicked() {
        isEditCover = false
        showCamera(animated: true)
    }
    
    func showCamera (animated : Bool) {
        
        let cameraController : FusumaViewController = FusumaViewController(nibName: "FusumaViewController", bundle: nil)
        cameraController.delegate = self
        let nav = UINavigationController(rootViewController: cameraController)
        nav.isNavigationBarHidden = true
        self.present(nav, animated: animated, completion: nil)
        
    }

}
