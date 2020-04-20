//
//  MFInboxViewController.swift
//  Minifm
//
//  Created by Thomas on 7/10/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit

class MFInboxViewController: MFBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func initializeStyle() {
        title = "Inbox"
        let menuButton = Utils.createButtonWithIcon(icon: UIImage(named: "ic_menu")!)
        menuButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        menuButton.addTarget(self, action: #selector(onMenuClicked(_:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
    }
    
    //MARK: Actions
    
    @IBAction override func onMenuClicked(_ sender: Any) {
        slideMenuController()?.openLeft()
    }

}
