//
//  MFBaseViewController.swift
//  Minifm
//
//  Created by Thomas on 2/9/17.
//  Copyright © 2017 GF. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

class MFBaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeStyle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func showMessage(message : String) {
        
        let alert = UIAlertController(title: "Minifm", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            print("OK clicked!!")
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Actions
    
    @IBAction func onBackClicked( sender : Any) {
    
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func onMenuClicked(_ sender: Any) {
        slideMenuController()?.openLeft()
    }
    
    //MARK: - Helper methods
    
    func initializeStyle() {
        self.navigationItem.hidesBackButton = true
        //left back
        let menuButton = Utils.createButtonWithIcon(icon: UIImage(named: "back_btn")!)
        menuButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        menuButton.addTarget(self, action: #selector(onBackClicked(sender:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
    }
    
    func switchToGallery() {
        SlideMenuOptions.leftViewWidth = UIScreen.main.bounds.width - 80
        SlideMenuOptions.contentViewScale = 1.0
        SlideMenuOptions.hideStatusBar = false
        let leftMenuController = STORYBOARDS.SIGNIN_STORYBOARD.instantiateViewController(withIdentifier: "MFLeftMenuViewControllerId")
        let galleryController = STORYBOARDS.FEED_STORYBOARD.instantiateViewController(withIdentifier: "NavGalleryId")
        let slideMenuController = SlideMenuController(mainViewController: galleryController, leftMenuViewController: leftMenuController)
        let window = UIApplication.shared.keyWindow
        window?.rootViewController = slideMenuController
        window?.makeKeyAndVisible()
    }
    
    func galleryController() {

        let galleryController = STORYBOARDS.FEED_STORYBOARD.instantiateViewController(withIdentifier: "NavGalleryId")
        slideMenuController()?.changeMainViewController(galleryController, close: true)
    }
    
    func shopController() {
        let shopController = STORYBOARDS.FEED_STORYBOARD.instantiateViewController(withIdentifier: "MFShopViewControllerId") as! MFShopViewController
        let nav = UINavigationController(rootViewController: shopController)
        slideMenuController()?.changeMainViewController(nav, close: true)
    }
    
    func sellController() {
        
        let sellController = STORYBOARDS.FEED_STORYBOARD.instantiateViewController(withIdentifier: "MFSellViewControllerId") as! MFSellViewController
        let nav = UINavigationController(rootViewController: sellController)
        let window = UIApplication.shared.keyWindow
        window?.topViewController()?.present(nav, animated: true, completion: nil)
        slideMenuController()?.closeLeft()
    }
    
    func helpController() {
        
        let helpController = STORYBOARDS.SIGNIN_STORYBOARD.instantiateViewController(withIdentifier: "MFHelpViewControllerId") as! MFHelpViewController
        let nav = UINavigationController(rootViewController: helpController)
        slideMenuController()?.changeMainViewController(nav, close: true)
    }
    
    func inboxController() {
        
        let inboxController = STORYBOARDS.SIGNIN_STORYBOARD.instantiateViewController(withIdentifier: "MFInboxViewController") as! MFInboxViewController
        let nav = UINavigationController(rootViewController: inboxController)
        slideMenuController()?.changeMainViewController(nav, close: true)
    }
    
    func friendController() {
        
        let friendController = STORYBOARDS.FEED_STORYBOARD.instantiateViewController(withIdentifier: "MFInviteFriendViewController") as! MFInviteFriendViewController
        let nav = UINavigationController(rootViewController: friendController)
        slideMenuController()?.changeMainViewController(nav, close: true)
    }

}
