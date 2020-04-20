//
//  MFGalleryViewController.swift
//  Minifm
//
//  Created by Thomas on 2/10/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import RxSwift
//import RxCocoa
import PullToRefreshSwift
import UIScrollView_InfiniteScroll
import Parse

class MFGalleryViewController: MFBaseViewController {

    @IBOutlet weak var boundViewCamera: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var galleryDelegate = GalleryViewDelegate()
    private var galleryDataSource : GalleryViewDatasource!
    private var galleryViewModel = GalleryViewModel()
    
    private let disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        galleryViewModel.loadMoreFeeds()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    //MARK: - Actions
    
    @IBAction func onCameraClicked(_ sender: Any) {
        showCamera(animated: true)
    }
    
    //MARK: - Helper methods
    
    override func initializeStyle() {
        title = "Gallery"
        tableView.backgroundColor = UIColor.clear
        boundViewCamera.layer.masksToBounds = true
        boundViewCamera.layer.cornerRadius = boundViewCamera.frame.height/2
        boundViewCamera.layer.borderWidth = 3.0
        boundViewCamera.layer.borderColor = UIColor(red: 250/255.0, green: 72/255.0, blue: 91/255.0, alpha: 1.0).cgColor
        let menuButton = Utils.createButtonWithIcon(icon: UIImage(named: "ic_menu")!)
        menuButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        menuButton.addTarget(self, action: #selector(onMenuClicked(_:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        cameraButton.addTarget(self, action: #selector(onCameraClicked(_:)), for: .touchUpInside)
        galleryDataSource = GalleryViewDatasource(vModel: galleryViewModel)
        tableView.delegate = galleryDelegate
        tableView.dataSource = galleryDataSource
        self.galleryViewModel.newItemsAdded = { [weak self] (range)in
            guard let weakself = self else { return }
            //weakself.tableView.reloadData()
            if range.length == 0 {
                if range.location == 0 {
                    weakself.tableView.reloadData()
                }
                weakself.tableView.finishInfiniteScroll()
                return
            }
            var indexPaths : [IndexPath] = []
            
            for i in range.location..<range.location + range.length {
                let indexPath = IndexPath.init(row: i, section: 0)
                indexPaths.append(indexPath)
            }
            weakself.tableView.beginUpdates()
            weakself.tableView.insertRows(at: indexPaths, with: .bottom)
            weakself.tableView.endUpdates()
            weakself.tableView.finishInfiniteScroll()
        }
        galleryViewModel.rx_loading.asObservable().subscribe { (event) in
            guard let loading = event.element else {
                return
            }
            if loading == true {
                IndicatorManager.shared.startIndicatorAnimation(inview: self.view)
            } else {
                IndicatorManager.shared.stopIndicatorAnimation(inview: self.view)
            }
            
            }.addDisposableTo(disposeBag)
        //Load more
        tableView.addInfiniteScroll { (tableView) in
            self.galleryViewModel.loadMoreFeeds()
        }
        //Pull refresh
//        tableView.addPullRefresh {  [weak self] in
//            guard let strongSelf = self else { return }
//            strongSelf.galleryViewModel.pullRefresh()
//            strongSelf.tableView.stopPullRefreshEver()
//        }
        NotificationCenter.default.addObserver(self, selector: #selector(OpenProfile(notification:)), name: NSNotification.Name(rawValue: "OpenProfile"), object: nil)

    }
    
    func OpenProfile(notification : Notification) {
        let otherUser = notification.object as? PFObject
        let profileController = STORYBOARDS.SIGNIN_STORYBOARD.instantiateViewController(withIdentifier: "MFMainProfileViewController") as! MFMainProfileViewController
        profileController.otherUser = otherUser
        profileController.isMyprofile = false
        self.navigationController?.pushViewController(profileController, animated: true)
    }
    
    func showCamera (animated : Bool) {
        
        let cameraController : FusumaViewController = FusumaViewController(nibName: "FusumaViewController", bundle: nil)
        cameraController.delegate = self
        let nav = UINavigationController(rootViewController: cameraController)
        nav.isNavigationBarHidden = true
        self.present(nav, animated: animated, completion: nil)
        
    }
}

extension MFGalleryViewController : FusumaDelegate {
    
    func fusumaImageSelected(_ image: UIImage) {
        
    }
    
    func fusumaDidSelected(controller: UIViewController, _ image: UIImage) {
        
        controller.dismiss(animated: true) { 
            let addPostController = STORYBOARDS.FEED_STORYBOARD.instantiateViewController(withIdentifier: "MFAddPostViewControllerId") as! MFAddPostViewController
            addPostController.imageForPost = image
            self.navigationController?.pushViewController(addPostController, animated: true)
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
