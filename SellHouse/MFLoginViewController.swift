//
//  MFLoginViewController.swift
//  Minifm
//
//  Created by Thomas on 2/9/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtils


class MFLoginViewController: MFBaseViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if PFUser.current() != nil {
            switchToGallery()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func initializeStyle() {
        
    }
    
    //MARK - Actions
    
    @IBAction func onSignInClicked(_ sender: Any) {
        
        if validate() == true {
            
            self.view.endEditing(true)
            showHUD()
            PFUser.logInWithUsername(inBackground: usernameTextField.text!, password:passwordTextField.text!) { (user, error) -> Void in
                if user != nil {
                    self.hideHUD()
                    self.switchToGallery()
                } else {
                    self.simpleAlert(error!.localizedDescription)
                    self.hideHUD()
                }
            }
        }
    }
    
    @IBAction func onSignInByFacebookClicked(_ sender: Any) {
        self.view.endEditing(true)
        showHUD()
        PFFacebookUtils.logIn(withPermissions: ["public_profile", "email"]) { (user, error) in
            if user == nil {
                self.hideHUD()
                if error == nil {
                    self.simpleAlert("The user cancelled facebook login.")
                } else {
                    print(error?.localizedDescription)
                    self.simpleAlert("An error occurred. Please try later.")
                }
            } else {
                if user?.isNew == true {
                    let fbRequest = FBRequest.forMe()
                    fbRequest!.start(completionHandler: { ( _, result, error) in
                        if error == nil {
                            
                            if let data = result {
                                print("Stored FB user to Parse")
                                let userData = data as! NSDictionary
                                let currentUser = PFUser.current()
                                let email  = userData["email"] as? String
                                currentUser?.email =  email != nil ? email! : ""
                                currentUser?.saveInBackground()
                            }
                        }
                    })
                } else {
                    
                }
                self.hideHUD()
                self.switchToGallery()
            }
        }
    }
    
    //MARK: - Helper methods
    
    func validate() -> Bool {
        if usernameTextField.text == "" {
            self.simpleAlert("Please enter user name or email.")
            return false
        } else if passwordTextField.text == "" {
            self.simpleAlert("Please enter your password.")
            return false
        }
        return true
    }

}
