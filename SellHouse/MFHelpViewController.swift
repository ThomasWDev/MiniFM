//
//  MFHelpViewController.swift
//  Minifm
//
//  Created by Thomas on 2/14/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit

class MFHelpViewController: UITableViewController {

    fileprivate var currentSelectIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeStyle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination
        if controller.isKind(of: MFAboutViewController.classForCoder()) {
            (segue.destination as! MFAboutViewController).index = currentSelectIndex
        }
     }
 

    func initializeStyle() {
        title = "Help"
        tableView.tableFooterView = UIView()
        let menuButton = Utils.createButtonWithIcon(icon: UIImage(named: "ic_menu")!)
        menuButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        menuButton.addTarget(self, action: #selector(onMenuClicked(_:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        self.tableView.dataSource = self
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 5 {
            self.performSegue(withIdentifier: "SeguePdfId", sender: nil)
        } else {
            currentSelectIndex = indexPath.row
            self.performSegue(withIdentifier: "SegueAboutId", sender: nil)
        }
    }
    
    @IBAction func onMenuClicked(_ sender: Any) {
        slideMenuController()?.openLeft()
    }

    
}
