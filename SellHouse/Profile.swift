//
//  Profile.swift
//  Minifm
//
//  Created by Thomas on 18/03/16.
//  Copyright © 2016 GF. All rights reserved.
//


import UIKit
import Parse


class Profile: UIViewController, UITextFieldDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var centralView: UIView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var fullNameTxt: UITextField!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var telTxt: UITextField!
    @IBOutlet weak var mobileTxt: UITextField!
    @IBOutlet weak var facebookTxt: UITextField!
    @IBOutlet weak var twitterTxt: UITextField!
    @IBOutlet var buttons: [UIButton]!
    
    @IBOutlet weak var contView: UIView!
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    
    
    
        self.title = "Profile"
        
        // Logout Button
        let butt = UIButton(type: UIButtonType.custom)
        butt.adjustsImageWhenHighlighted = false
        butt.frame = CGRect(x: 0, y: 0, width: 70, height: 44)
        butt.setTitle("LOGOUT", for: UIControlState())
        butt.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        butt.addTarget(self, action: #selector(logout(_:)), for: UIControlEvents.touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: butt)
        
        // Back Button
        let backButt = UIButton(type: UIButtonType.custom)
        backButt.adjustsImageWhenHighlighted = false
        backButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        backButt.setBackgroundImage(UIImage(named: "backButt"), for: UIControlState())
        backButt.addTarget(self, action: #selector(backButton(_:)), for: UIControlEvents.touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButt)
        
        avatarImage.layer.cornerRadius = avatarImage.bounds.size.width/2
        
        
        // ScrollView
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 700)
        
        showUserDetails()
    }
    
    
    // Back Button
    func backButton(_ sender:UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    // User Details
    func showUserDetails() {
        let user = PFUser.current()!
        
        if user[USER_FULLNAME] != nil { fullNameTxt.text = "\(user[USER_FULLNAME]!)"
        } else { fullNameTxt.text = ""  }
        
        usernameTxt.text = "\(user[USER_USERNAME]!)"
        emailTxt.text = "\(user[USER_EMAIL]!)"
        
        if user[USER_TEL] != nil { telTxt.text = "\(user[USER_TEL]!)"
        } else { telTxt.text = ""  }
        
        if user[USER_MOBILE] != nil {  mobileTxt.text = "\(user[USER_MOBILE]!)"
        } else { mobileTxt.text = ""  }
        
        
        if user[USER_FACEBOOK] != nil { facebookTxt.text = "\(user[USER_FACEBOOK]!)"
        } else { facebookTxt.text = ""  }
        
        if user[USER_TWITTER] != nil {  twitterTxt.text = "\(user[USER_TWITTER]!)"
        } else { twitterTxt.text = ""  }
        
        let imageFile = user[USER_AVATAR] as? PFFile
        imageFile?.getDataInBackground { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.avatarImage.image = UIImage(data:imageData)
                }}}
    }
    
    
    // Avatar Button
    @IBAction func selectAvatarButt(_ sender: AnyObject) {
        let alert = UIAlertView(title: APP_NAME,
                                message: "Select source",
                                delegate: self,
                                cancelButtonTitle: "Cancel",
                                otherButtonTitles: "Camera",
                                "Photo Library"
        )
        alert.show()
    }

    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.buttonTitle(at: buttonIndex) == "Camera" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
            {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                imagePicker.allowsEditing = true
                present(imagePicker, animated: true, completion: nil)
            }
            
        } else if alertView.buttonTitle(at: buttonIndex) == "Photo Library" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                imagePicker.allowsEditing = true
                present(imagePicker, animated: true, completion: nil)
            }
        }
        
    }

    // ImagePicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            avatarImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // Update Profile Button
    @IBAction func updateProfileButt(_ sender: AnyObject) {
        showHUD()
        dismissKeyboard()
        
        let updatedUser = PFUser.current()
        updatedUser?.setObject(usernameTxt.text!, forKey: USER_USERNAME)
        updatedUser?.setObject(fullNameTxt.text!, forKey: USER_FULLNAME)
        updatedUser?.setObject(emailTxt.text!, forKey: USER_EMAIL)
        
        updatedUser?.setObject(telTxt.text!, forKey: USER_TEL)
        updatedUser?.setObject(mobileTxt.text!, forKey: USER_MOBILE)
        updatedUser?.setObject(facebookTxt.text!, forKey: USER_FACEBOOK)
        updatedUser?.setObject(twitterTxt.text!, forKey: USER_TWITTER)
        
        // Save Image (if exists)
        if avatarImage.image != nil {
            let imageData = UIImageJPEGRepresentation(avatarImage.image!, 0.5)
            let imageFile = PFFile(name:"avatar.jpg", data:imageData!)
            updatedUser?.setObject(imageFile!, forKey: USER_AVATAR)
        }
        
        
        // Saving block
        updatedUser!.saveInBackground { (success, error) -> Void in
            if error == nil {
                self.simpleAlert("Your Profile has been updated!")
                self.hideHUD()
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }}
        
    }
    
    
    // TextFields
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fullNameTxt { usernameTxt.becomeFirstResponder() }
        if textField == usernameTxt { emailTxt.becomeFirstResponder()    }
        if textField == emailTxt    { telTxt.becomeFirstResponder()      }
        if textField == telTxt      { mobileTxt.becomeFirstResponder()   }
        if textField == mobileTxt   { facebookTxt.becomeFirstResponder()    }
        if textField == facebookTxt { twitterTxt.becomeFirstResponder()  }
        if textField == twitterTxt  { twitterTxt.resignFirstResponder()  }
        
        return true
    }
    
    func dismissKeyboard() {
        fullNameTxt.resignFirstResponder()
        usernameTxt.resignFirstResponder()
        emailTxt.resignFirstResponder()
        telTxt.resignFirstResponder()
        mobileTxt.resignFirstResponder()
        facebookTxt.resignFirstResponder()
        twitterTxt.resignFirstResponder()
    }
    
    @IBAction func tapToDismissKeyb(_ sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }
    
    
    // My Properties
    @IBAction func myPropButt(_ sender: AnyObject) {
        let mpVC = storyboard?.instantiateViewController(withIdentifier: "MyProperties") as! MyProperties
        navigationController?.pushViewController(mpVC, animated: true)
    }
    
    
    // Logout Button
    func logout(_ sender:UIButton) {
        PFUser.logOutInBackground { (error) -> Void in
            if error == nil {
                _ = self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
