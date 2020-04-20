//
//  Login.swift
//  Minifm
//
//  Created by Thomas on 18/03/16.
//  Copyright © 2016 GF. All rights reserved.
//



import Parse
import UIKit


class Login: UIViewController, UITextFieldDelegate, UIAlertViewDelegate
{
    
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var logo: UIImageView!
    @IBOutlet weak var loginOutlet: UIButton!
    
    @IBOutlet weak var contView: UIView!
    
    
override var prefersStatusBarHidden : Bool {
    return true
}
    
    
override func viewWillAppear(_ animated: Bool) {
    if PFUser.current() != nil {
        dismiss(animated: true, completion: nil)
    }
}
    
    
   
override func viewDidLoad() {
        super.viewDidLoad()
    
    
        
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 550)
    navigationController?.isNavigationBarHidden = true
        
}
    
    
    
// Login Button
@IBAction func loginButt(_ sender: AnyObject) {
    passwordTxt.resignFirstResponder()
    showHUD()
    
    PFUser.logInWithUsername(inBackground: usernameTxt.text!, password:passwordTxt.text!) { (user, error) -> Void in
        if user != nil {
            self.dismiss(animated: true, completion: nil)
            self.hideHUD()
                
        } else {
            let alert = UIAlertView(title: APP_NAME,
            message: "\(error!.localizedDescription)",
            delegate: self,
            cancelButtonTitle: "Retry",
            otherButtonTitles: "Sign Up")
            alert.show()
            self.hideHUD()
    }}
    
}

    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
    if alertView.buttonTitle(at: buttonIndex) == "Sign Up" {
        signupButt(self)
    }
        
    if alertView.buttonTitle(at: buttonIndex) == "Reset Password" {
        PFUser.requestPasswordResetForEmail(inBackground: "\(alertView.textField(at: 0)!.text!)")
        showNotifAlert()
    }
}
    

    
// SignUp Button
@IBAction func signupButt(_ sender: AnyObject) {
    let signupVC = self.storyboard?.instantiateViewController(withIdentifier: "Signup") as! Signup
    present(signupVC, animated: true, completion: nil)
}
    
    
    
    

// Forgot Password
@IBAction func forgotPasswButt(_ sender: AnyObject) {
    let alert = UIAlertView(title: APP_NAME,
        message: "Type the email address you used to register.",
        delegate: self,
        cancelButtonTitle: "Cancel",
        otherButtonTitles: "Reset Password")
        alert.alertViewStyle = UIAlertViewStyle.plainTextInput
        alert.show()
}

    func showNotifAlert() {
    simpleAlert("You will receive an email with a link to reset your password")
}
    
    
    
    
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == usernameTxt { passwordTxt.becomeFirstResponder() }
    if textField == passwordTxt { passwordTxt.resignFirstResponder() }
return true
}
    
    
// Tap to Dismiss Keyboard
@IBAction func tapToDismissKeyboard(_ sender: UITapGestureRecognizer) {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
}
    
    
    
@IBAction func dismissButt(_ sender: AnyObject) {
    dismiss(animated: true, completion: nil)
}
    
    

    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
