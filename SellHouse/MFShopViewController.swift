//
//  MFShopViewController.swift
//  Minifm
//
//  Created by Thomas on 2/27/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit

class MFShopViewController: MFBaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: RAMCollectionViewFlemishBondLayoutSwift!
    
    fileprivate var  viewModel = ShopsCollectionViewModel()
    var collectionView_delegate : ShopsCollectionViewDelegate!
    var collectionView_datasource : ShopsCollectionViewDatasource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func initializeStyle() {
        title = "Listings"
        self.automaticallyAdjustsScrollViewInsets = false
        let menuButton = Utils.createButtonWithIcon(icon: UIImage(named: "ic_menu")!)
        menuButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        menuButton.addTarget(self, action: #selector(onMenuClicked(_:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        self.collectionView.layoutIfNeeded()
        self.collectionView_datasource = ShopsCollectionViewDatasource(viewModel: viewModel)
        self.collectionView_delegate = ShopsCollectionViewDelegate(viewModel: viewModel)
        self.collectionView.scrollsToTop = false
        self.collectionView.delegate = collectionView_delegate
        self.collectionView.dataSource = collectionView_datasource
        viewModel.fetchMoreData(isFollowing: false)
        viewModel.newItemsAdded = { [weak self] (range) in
            
            guard let weakself = self else { return }
            
            weakself.collectionView?.reloadData()
        }
        
    }

    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 { //All
            viewModel.fetchMoreData(isFollowing: false)
        } else { //Following
            viewModel.fetchMoreData(isFollowing: true)
        }
        
    }
}
