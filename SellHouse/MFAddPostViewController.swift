//
//  MFAddPostViewController.swift
//  Minifm
//
//  Created by Thomas on 2/11/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import Parse

class MFAddPostViewController: MFBaseViewController {

    
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var imageTitleLabel: UITextField!
    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    
    var imageForPost : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.contentSize = CGSize(width: 0, height: scrollView.contentSize.height)
    }
    
    override func initializeStyle() {
        title = "Add Post"
        imageTitleLabel.setLeftPaddingPoints(8)
        self.navigationItem.hidesBackButton = true
        if let image = imageForPost {
            previewImageView.image = image
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(onOpenOptionCamera))
        previewImageView.addGestureRecognizer(tap)
        previewImageView.isUserInteractionEnabled = true
    }
    
    //MARK: - Actions
    
    func showCamera (animated : Bool) {
        
        let cameraController : FusumaViewController = FusumaViewController(nibName: "FusumaViewController", bundle: nil)
        cameraController.delegate = self
        let nav = UINavigationController(rootViewController: cameraController)
        nav.isNavigationBarHidden = true
        self.present(nav, animated: animated, completion: nil)
        
    }
    
    func onOpenOptionCamera() {
        let actionController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionController.addAction(UIAlertAction(title: "Take Photo", style: .destructive, handler: { (_) in
            self.showCamera(animated: true)
        }))
        actionController.addAction(UIAlertAction(title: "Choose existing", style: .destructive, handler: { (_) in
            self.showCamera(animated: true)
        }))
        actionController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
        }))
        self.present(actionController, animated: true, completion: nil)
    }
    
    @IBAction func onCreatePostClicked(_ sender: Any) {
        
        if validate() == true {
            showHUD()
            let udid = NSUUID().uuidString.appending(".png")
            let file = PFFile(name: udid, data: UIImageJPEGRepresentation(imageForPost, 0.5)!)
            let postObject = PFObject(className: ACTIVITY_FEED_CLASS_NAME)
            postObject[ACTIVITY_FEED_FILE] = file
            postObject[ACTIVITY_FEED_CAPTION] = imageTitleLabel.text
            postObject[ACTIVITY_FEED_BY_USER] = PFUser.current()!
            postObject.saveInBackground(block: { (success, error) in
                self.hideHUD()
                if error == nil && success == true {
                    self.navigationController!.popViewController(animated: true)
                } else {
                    self.simpleAlert((error?.localizedDescription)!)
                }
            })
        }
    }
    
    @IBAction func onCancelClicked(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }
    

    //MARK: - Helper methods
    
    func validate() -> Bool {
        if imageTitleLabel.text == "" {
            simpleAlert("Please enter caption.")
            return false
        }
        return true
    }
}

extension MFAddPostViewController : FusumaDelegate {
    
    func fusumaImageSelected(_ image: UIImage) {
        
    }
    
    func fusumaDidSelected(controller: UIViewController, _ image: UIImage) {
        
        controller.dismiss(animated: true) {
            self.previewImageView.image = image
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
}

extension UITextField {
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
