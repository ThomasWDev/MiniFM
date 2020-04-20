//
//  Signup.swift
//  Minifm
//
//  Created by Thomas on 18/03/16.
//  Copyright © 2016 GF. All rights reserved.
//


import UIKit
import Parse

class Signup: MFBaseViewController, UITextFieldDelegate {
    
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var logo: UIImageView!
    @IBOutlet weak var signupOutlet: UIButton!
    
    @IBOutlet weak var contView: UIView!
    
    
    // Hide Status Bar
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 750)
        navigationController?.isNavigationBarHidden = true
    }
    
    // Back Button
    @IBAction func dismissButt(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    // Dismiss Keyboard
    @IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
        usernameTxt.resignFirstResponder()
        fullnameTxt.resignFirstResponder()
        passwordTxt.resignFirstResponder()
        emailTxt.resignFirstResponder()
    }
    
    
    // SignUp Button
    @IBAction func signupButt(_ sender: AnyObject) {
        showHUD()
        
        let userForSignUp = PFUser()
        userForSignUp.username = usernameTxt.text
        userForSignUp[USER_FULLNAME] = fullnameTxt.text
        userForSignUp.password = passwordTxt.text
        userForSignUp.email = emailTxt.text
        
        // Signup block
        userForSignUp.signUpInBackground { (succeeded, error) -> Void in
            if error == nil {
                self.dismiss(animated: true, completion: nil)
                self.hideHUD()
                
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }}
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == usernameTxt {   fullnameTxt.becomeFirstResponder()  }
        if textField == fullnameTxt {  passwordTxt.becomeFirstResponder()  }
        if textField == passwordTxt {   emailTxt.becomeFirstResponder()   }
        if textField == emailTxt {   emailTxt.resignFirstResponder()   }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
