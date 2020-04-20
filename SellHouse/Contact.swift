//
//  Contact.swift
//  Minifm
//
//  Created by Thomas on 18/03/16.
//  Copyright © 2016 GF. All rights reserved.
//


import UIKit
import MessageUI


class Contact: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate
{

    @IBOutlet var views: [UIView]!
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var fullnameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var messageTxt: UITextView!
    
    @IBOutlet weak var contView: UIView!
    
    
override func viewDidLoad() {
        super.viewDidLoad()

    
    
    
    
    
    for aView in views {
        aView.layer.cornerRadius = 0
    }
    
    containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: 680)
}

 
// iOS Mail Controller
@IBAction func openMailVC(_ sender: AnyObject) {
    let mailComposer = MFMailComposeViewController()
    mailComposer.mailComposeDelegate = self
    mailComposer.setToRecipients([MY_CONTACT_EMAIL])
    mailComposer.setSubject("Contact from \(fullnameTxt.text!)")
    mailComposer.setMessageBody("\(messageTxt.text!)<br><br><br>Reply to: \(emailTxt.text!)<br>", isHTML: true)
    
    if MFMailComposeViewController.canSendMail() {
        present(mailComposer, animated: true, completion: nil)
        
    } else { simpleAlert("Your device cannot send emails. Please configure your emailinto Settings > Mail, Contacts, Calendars.") }
}

    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        var outputMessage = ""
        switch result.rawValue {
            case MFMailComposeResult.cancelled.rawValue: outputMessage = "Mail cancelled"
            case MFMailComposeResult.saved.rawValue: outputMessage = "Mail saved"
            case MFMailComposeResult.sent.rawValue: outputMessage = "Mail sent"
            case MFMailComposeResult.failed.rawValue: outputMessage = "Something went wrong with sending Mail, try again later."
        default: break }
    
    simpleAlert(outputMessage)
    dismiss(animated: false, completion: nil)
}
    
    
    
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == fullnameTxt  { emailTxt.becomeFirstResponder()   }
    if textField == emailTxt     { messageTxt.becomeFirstResponder() }
    
return true
}
    
func dismissKeyboard() {
    fullnameTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
    messageTxt.resignFirstResponder()
}
    
@IBAction func tapToDismisskeyb(_ sender: UITapGestureRecognizer) {
    dismissKeyboard()
}
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
