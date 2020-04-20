//
//  MFResetPasswordViewController.swift
//  Minifm
//
//  Created by Thomas on 2/10/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import Parse
import TPKeyboardAvoiding

class MFResetPasswordViewController: MFBaseViewController {

    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var newpasswordTextField: UITextField!
    @IBOutlet weak var reNewPasswordTextField: UITextField!
    
    var email : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.contentSize = CGSize(width: 0, height: scrollView.contentSize.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func initializeStyle() {
        super.initializeStyle()
        scrollView.contentSize = CGSize(width: 0, height: scrollView.contentSize.height)
    }

    //MARK: - Actions
    
    @IBAction func onResetClicked(_ sender: Any) {
        
        if validate() == true {
            showHUD()
            view.endEditing(true)
            let queryUser = PFUser.query()
            queryUser?.whereKey("email", equalTo: email!)
            queryUser?.getFirstObjectInBackground(block: { (object, error) in
                if error == nil && object != nil {
                    let user = object as! PFUser
                    user.password = self.newpasswordTextField.text
                    user.saveInBackground(block: { (success, error) in
                        self.hideHUD()
                        if error == nil && success == true {
                            PFUser.logOut()
                            self.navigationController!.popToRootViewController(animated: true)
                            self.simpleAlert("Your password was reset successfully!")
                        } else {
                            self.simpleAlert((error?.localizedDescription)!)
                        }
                    })
                } else {
                    self.simpleAlert("An error occurred. Please try later.")
                }
                
            })
            
        }
    }
    
    //MARK: - Helper methods
    
    func validate() -> Bool {
        if newpasswordTextField.text == "" {
            simpleAlert("Please enter new password.")
            return false
        } else if newpasswordTextField.text != reNewPasswordTextField.text {
            simpleAlert("Confirm password doesn't match new password.")
            return false
        }
        return true
    }

}
