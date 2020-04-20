//
//  MFMainProfileViewController.swift
//  Minifm
//
//  Created by Thomas on 7/9/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import Parse

class MFMainProfileViewController: MFBaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate var  viewModel = ProfileModel()
    var collectionView_delegate : ProfileViewDelegate!
    var collectionView_datasource : ProfileViewDatasource!
    var isMyprofile = false
    var otherUser : PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(notification:)), name: NSNotification.Name(rawValue: "ButtonClicked"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func initializeStyle() {
        self.automaticallyAdjustsScrollViewInsets = false
        collectionView.contentInset.top = 64
        if otherUser != nil {
            title = "My Profile"
            if PFUser.current()?.objectId !=  otherUser?.objectId {
                title = "Other Profile"
            }
            super.initializeStyle()
        } else {
            title = "My Profile"
            let menuButton = Utils.createButtonWithIcon(icon: UIImage(named: "ic_menu")!)
            menuButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
            menuButton.addTarget(self, action: #selector(onMenuClicked(_:)), for: .touchUpInside)
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        }
        
        self.collectionView.layoutIfNeeded()
        self.collectionView_datasource = ProfileViewDatasource(viewModel: viewModel)
        self.collectionView_datasource.isMyprofile = isMyprofile
        collectionView_datasource.otherUser = otherUser
        self.collectionView_delegate = ProfileViewDelegate(viewModel: viewModel)
        self.collectionView.scrollsToTop = false
        self.collectionView.delegate = collectionView_delegate
        self.collectionView.dataSource = collectionView_datasource
        viewModel.fetchMoreData(listingsType: 0, otherUser: otherUser)
        viewModel.newItemsAdded = { [weak self] (range) in
            
            guard let weakself = self else { return }
            
            weakself.collectionView?.reloadData()
        }
        

    }
    
    func refresh(notification : Notification) {
        let type = notification.object as! String
        if type == "0" {
            viewModel.isGallery = false
            viewModel.fetchMoreData(listingsType: 0, otherUser: otherUser)
        } else if type == "1" {
            viewModel.isGallery = true
            viewModel.fetchMoreData(listingsType: 1, otherUser: otherUser)
        } else {
            viewModel.isGallery = true
            viewModel.fetchMoreData(listingsType: 2, otherUser: otherUser)
        }
    }
    

}
