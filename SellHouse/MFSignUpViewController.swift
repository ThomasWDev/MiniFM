//
//  MFSignUpViewController.swift
//  Minifm
//
//  Created by Thomas on 2/9/17.
//  Copyright © 2017 GF. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtils

class MFSignUpViewController: MFBaseViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Actions
    
    @IBAction func onSignUpClicked(_ sender: Any) {
        
        if validate() == true {
            showHUD()
            let userForSignUp = PFUser()
            userForSignUp.username = usernameTextField.text
            userForSignUp.password = passwordTextField.text
            userForSignUp.email = usernameTextField.text
            userForSignUp.signUpInBackground { (succeeded, error) -> Void in
                if error == nil {
                    self.dismiss(animated: true, completion: nil)
                    self.hideHUD()
                    self.navigationController!.popViewController(animated: true)
                    
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                    self.hideHUD()
                }
            }
        }
    }
    
    
    @IBAction func onSignUpByFacebookClicked(_ sender: Any) {
        
        self.view.endEditing(true)
        showHUD()
        PFFacebookUtils.logIn(withPermissions: ["public_profile", "email"]) { (user, error) in
            if user == nil {
                self.hideHUD()
                if error == nil {
                    self.simpleAlert("The user cancelled facebook login.")
                } else {
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
                self.switchToGallery()
                self.hideHUD()
            }
        }
        
    }
    
    
    @IBAction func onSignInClicked(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }
    
    //MARK: - Helper methods
    
    func validate() -> Bool {
        if usernameTextField.text == "" {
            self.simpleAlert("Please enter user name or email.")
            return false
        } else if passwordTextField.text == "" {
            self.simpleAlert("Please enter password.")
            return false
        }
        return true
    }
    

}
