//
//  MFLikersViewController.swift
//  Minifm
//
//  Created by Thomas on 3/1/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import Parse

class MFLikersViewController: UITableViewController {

    var gallerryObject : PFObject?
    fileprivate var likers = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        //left back
        let menuButton = Utils.createButtonWithIcon(icon: UIImage(named: "back_btn")!)
        menuButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        menuButton.addTarget(self, action: #selector(onBackClicked), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        self.tableView.tableFooterView = UIView()
        loadLikers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LikersCellId", for: indexPath) as! LikersCell
        cell.model = likers[indexPath.row]
        return cell
    }
    
    //MARK: - Actions
    
    func onBackClicked() {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: - Helper methods
    
    func loadLikers() {
        
        if let object = gallerryObject {
            self.likers.removeAll()
            IndicatorManager.shared.startIndicatorAnimation(inview: self.view)
            let favesObject = PFQuery(className: ACTIVITY_FAVES_CLASS_NAME)
            favesObject.includeKey(ACTIVITY_FAVES_BY_USER)
            favesObject.whereKey(ACTIVITY_FAVES_FOR_FEED, equalTo: object)
            favesObject.order(byAscending: "createdAt")
            favesObject.findObjectsInBackground(block: { (result, error) in
                IndicatorManager.shared.stopIndicatorAnimation(inview: self.view)
                if let arr = result {
                    if arr.count > 0 {
                        self.likers.append(contentsOf: arr)
                        self.tableView?.reloadData()
                    }
                }
            })
        }
    }
    
}
