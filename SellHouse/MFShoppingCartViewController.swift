//
//  MFShoppingCartViewController.swift
//  Minifm
//
//  Created by Thomas on 7/4/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import Parse

class MFShoppingCartViewController: MFBaseViewController {

    @IBOutlet weak var tableView: UITableView!
    var shoppingCarts = NSMutableArray()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(notification:)), name: NSNotification.Name(rawValue: "RemovedItemInShoppingCart"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkout(notification:)), name: NSNotification.Name(rawValue: "ProcessCheckout"), object: nil)
        fetchingShoppingCartItems()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func initializeStyle() {
        title = "Cart"
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        let menuButton = Utils.createButtonWithIcon(icon: UIImage(named: "ic_menu")!)
        menuButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        menuButton.addTarget(self, action: #selector(onMenuClicked(_:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
    }
    
    //MARK: Actions
    
    @IBAction override func onMenuClicked(_ sender: Any) {
        slideMenuController()?.openLeft()
    }
    
    //MARK: Helper methods
    
    func refresh(notification : Notification) {
        let object = notification.object as! PFObject
        if shoppingCarts.contains(object) {
            shoppingCarts.remove(object)
            tableView.reloadData()
        }
    }
    
    func checkout(notification : Notification) {
        let object = notification.object as! PFObject
        let checkoutController = STORYBOARDS.FEED_STORYBOARD.instantiateViewController(withIdentifier: "MFCheckoutViewController") as! MFCheckoutViewController
        checkoutController.checkoutItems.add(object)
        self.navigationController?.pushViewController(checkoutController, animated: true)
    }
    
    func fetchingShoppingCartItems() {
        self.shoppingCarts.removeAllObjects()
        IndicatorManager.shared.startIndicatorAnimation(inview: self.view)
        let query = PFQuery(className: SHOPPING_CART_CLASS_NAME)
        query.whereKey(SHOPPING_CART_OF_USER_ID, equalTo: PFUser.current()!.objectId!)
        query.findObjectsInBackground { (results, error) in
            IndicatorManager.shared.stopIndicatorAnimation(inview: self.view)
            if results != nil {
                self.shoppingCarts.addObjects(from: results!)
                self.tableView.reloadData()
            }
        }
    }

}

extension MFShoppingCartViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shoppingCarts.count == 0 {
            return 1
        }
        return shoppingCarts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if shoppingCarts.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "EmptyShoppingCartCell")!
        }
        let shoppingCartCell = tableView.dequeueReusableCell(withIdentifier: "ShoppingCartCell") as! ShoppingCartCell
        shoppingCartCell.bind(object: shoppingCarts[indexPath.row] as! PFObject)
        return shoppingCartCell
    }

}
