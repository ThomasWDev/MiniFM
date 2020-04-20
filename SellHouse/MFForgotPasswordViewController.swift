//
//  MFForgotPasswordViewController.swift
//  Minifm
//
//  Created by Thomas on 2/10/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import Parse
import TPKeyboardAvoiding

class MFForgotPasswordViewController: MFBaseViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    
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
        emailTextField.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueResetId" {
            let resetController = segue.destination as! MFResetPasswordViewController
            resetController.email = emailTextField.text
        }
    }
    
    //MARK: - Actions
    
    @IBAction func onRecoverClicked(_ sender: Any) {
        if validate() == true {
            view.endEditing(true)
            showHUD()
            let queryUser = PFUser.query()
            queryUser?.whereKey("email", equalTo: emailTextField.text!)
            queryUser?.getFirstObjectInBackground(block: { (user, error) in
                self.hideHUD()
                if user != nil {
                    DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: "SegueResetId", sender: nil)
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        self.simpleAlert((error?.localizedDescription)!)
                    })
                }
            })
        }
    }
    
    //MARK: - Helper methods
    
    func validate() -> Bool {
        if emailTextField.text == "" {
            simpleAlert("Please enter email.")
            return false
        }
        return true
    }
    
}

extension MFForgotPasswordViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
}
