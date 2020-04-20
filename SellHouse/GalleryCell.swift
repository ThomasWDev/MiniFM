//
//  GalleryCell.swift
//  Minifm
//
//  Created by Thomas on 2/11/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import Parse
import ParseLiveQuery
import IDMPhotoBrowser

class GalleryCell: UITableViewCell, IDMPhotoBrowserDelegate {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var prevImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeStampAgoLabel: UILabel!
    @IBOutlet weak var likeButton: UILabel!
    @IBOutlet weak var commentButton: UILabel!
    @IBOutlet weak var likeButton1: UIButton!
    @IBOutlet weak var commentButton1: UIButton!
    
    fileprivate var galleryObject : PFObject?
    fileprivate var lovedObject : PFObject?
    fileprivate var isLoved = false
    fileprivate let liveQueryClient = ParseLiveQuery.Client()
    fileprivate var subscription: Subscription<PFObject>?
    fileprivate var countFaves = 0
    fileprivate var faves : PFQuery<PFObject>?
    //Comment
    fileprivate var subscriptionComment: Subscription<PFObject>?
    fileprivate var countComments = 0
    fileprivate var commentsQuery : PFQuery<PFObject>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.text = ""
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = 2
        avatarImageView.image = nil
        avatarImageView.backgroundColor = UIColor.gray
        prevImageView.image = nil
        prevImageView.backgroundColor = UIColor.lightGray
        titleLabel.text = ""
        timeStampAgoLabel.text = ""
        likeButton.text = "Like(0)"
        commentButton.text = "Comments(0)"
        let tap = UITapGestureRecognizer(target: self, action: #selector(onOpenPhoto))
        prevImageView.addGestureRecognizer(tap)
        prevImageView.isUserInteractionEnabled = true
        let tapOpenProfile = UITapGestureRecognizer(target: self, action: #selector(onOpenProfile))
        avatarImageView.addGestureRecognizer(tapOpenProfile)
        avatarImageView.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var model : PFObject? {
        didSet {
            
            bind(model: model!)
        }
    }
    
    func bind( model : PFObject ) {
        galleryObject = model
        //Real time to tracking like and comment
        faves = PFQuery(className: ACTIVITY_FAVES_CLASS_NAME)
        faves?.whereKey(ACTIVITY_FAVES_FOR_FEED_ID, equalTo: galleryObject!.objectId!)
        subscription = liveQueryClient.subscribe(faves!)
        _ = subscription?.handle(Event.created) { _, object in
            print("Created")
            DispatchQueue.main.async(execute: { 
                self.countFaves += 1
                self.likeButton.text = "Like (\(self.countFaves))"
            })
            
        }
        _ = subscription?.handle(Event.deleted) { _, object in
            print("Deleted")
            DispatchQueue.main.async(execute: {
                self.countFaves -= 1
                self.likeButton.text = "Like (\(self.countFaves))"
            })
        }
        //Comments real time
        commentsQuery = PFQuery(className: COMMENT_CLASS_NAME)
        commentsQuery?.includeKey(COMMENT_BY_USER)
        commentsQuery?.whereKey(COMMENT_ACTIVITY_FEED_ID, equalTo: galleryObject!.objectId!)
        subscriptionComment = liveQueryClient.subscribe(commentsQuery!)
        _ = subscriptionComment?.handle(Event.created) { _, object in
            print("Created")
            DispatchQueue.main.async(execute: {
                self.countComments += 1
                self.commentButton.text = "Comments (\(self.countComments))"
            })
            
        }
        _ = subscriptionComment?.handle(Event.deleted) { _, object in
            print("Deleted")
            DispatchQueue.main.async(execute: {
                self.countComments -= 1
                self.commentButton.text = "Comments (\(self.countComments))"
            })
        }
        
        titleLabel.text = model[ACTIVITY_FEED_CAPTION] as! String?
        timeStampAgoLabel.text = "Posted \(model.createdAt!.timeAgo)"
        let file = model[ACTIVITY_FEED_FILE] as! PFFile
        self.prevImageView.image = nil
        if file.isDataAvailable == true {
            file.getPathInBackground(block: { (path, error) in
                let image = UIImage(contentsOfFile: path!)
                self.prevImageView.image = image
            })
        } else {
            file.getDataInBackground { (data, error) in
                if let data = data {
                    let image = UIImage(data: data)
                    self.prevImageView.image = image
                }
            }
        }
        let owner = model[ACTIVITY_FEED_BY_USER] as! PFUser
        nameLabel.text = owner[USER_FULLNAME] as? String
        let fileAvatar = owner[USER_AVATAR] as? PFFile
        self.avatarImageView.image = nil
        if fileAvatar?.isDataAvailable == true {
            fileAvatar?.getPathInBackground(block: { (path, error) in
                let image = UIImage(contentsOfFile: path!)
                self.avatarImageView.image = image
            })
        } else {
            fileAvatar?.getDataInBackground { (data, error) in
                if let data = data {
                    let image = UIImage(data: data)
                    self.avatarImageView.image = image
                }
            }
        }
        isLoved = false
        lovedObject = nil
        //Like
        likeButton.text = "Like (0)"
        self.likeButton1.setBackgroundImage(UIImage(named: "ic_love"), for: .normal)
        let fav = PFQuery(className: ACTIVITY_FAVES_CLASS_NAME)
        fav.includeKey(ACTIVITY_FAVES_BY_USER)
        fav.whereKey(ACTIVITY_FAVES_FOR_FEED, equalTo: galleryObject!)
        //Get first
        fav.findObjectsInBackground { (result, error) in
            
            if let arr = result {
                self.countFaves = arr.count
                self.likeButton.text = "Like (\(self.countFaves))"
                for item in arr {
                    if let userObject = item[ACTIVITY_FAVES_BY_USER] as? PFUser {
                        if userObject.objectId! == PFUser.current()?.objectId! {
                            self.lovedObject = item
                            self.isLoved = true
                            self.likeButton1.setBackgroundImage(UIImage(named: "ic_fav"), for: .normal)
                            return
                        }
                    }
                }
            }
        }
        //Comments
        commentButton.text = "Comments (0)"
        let comments = PFQuery(className: COMMENT_CLASS_NAME)
        comments.whereKey(COMMENT_ACTIVITY_FEED, equalTo: galleryObject!)
        //Get first
        comments.findObjectsInBackground { (result, error) in
            
            if let arr = result {
                self.countComments = arr.count
                self.commentButton.text = "Comments (\(self.countComments))"
            }
        }
    }
    
    deinit {
        print(#function)
        liveQueryClient.unsubscribe(faves!, handler: subscription!)
        liveQueryClient.unsubscribe(commentsQuery!, handler: subscriptionComment!)
    }
    
    //MARK: - Actions
    
    @IBAction func onLikeClicked(_ sender: Any) {
        if isLoved == true {
            if let object = lovedObject {
                object.deleteInBackground(block: { (success, error) in
                    if success == true && error == nil {
                        self.isLoved = false
                        self.likeButton1.setBackgroundImage(UIImage(named: "ic_love"), for: .normal)
                    }
                })
            }
        } else {
            let favesObject = PFObject(className: ACTIVITY_FAVES_CLASS_NAME)
            favesObject[ACTIVITY_FAVES_BY_USER] = PFUser.current()
            favesObject[ACTIVITY_FAVES_FOR_FEED] = galleryObject
            favesObject[ACTIVITY_FAVES_FOR_FEED_ID] = galleryObject?.objectId
            favesObject.saveInBackground { (success, error) in
                print("Added favourite!!!")
                if success == true && error == nil {
                    self.lovedObject = favesObject
                    self.isLoved = true
                    self.likeButton1.setBackgroundImage(UIImage(named: "ic_fav"), for: .normal)
                }
            }
        }
        
    }
    
    @IBAction func onCommentClicked(_ sender: Any) {
        showCommentController()
    }
    
    @IBAction func onLikeDetailClicked(_ sender: Any) {
        let window = UIApplication.shared.keyWindow
        let likersController = STORYBOARDS.FEED_STORYBOARD.instantiateViewController(withIdentifier: "MFLikersViewControllerId") as! MFLikersViewController
        likersController.gallerryObject = galleryObject
        let nav = UINavigationController(rootViewController: likersController)
        window?.topViewController()?.present(nav, animated: true, completion: nil)
    }
    
    @IBAction func onCommentDetailClicked(_ sender: Any) {
        showCommentController()
    }
    
    
    
    //MARK: Helper methods
    
    func showCommentController() {
        let commentViewController = MFCommentViewController(tableViewStyle: .plain)
        commentViewController.gallerryObject = galleryObject
        let window = UIApplication.shared.keyWindow
        let nav = UINavigationController(rootViewController: commentViewController)
        window?.topViewController()?.present(nav, animated: true, completion: nil)
    }
    
    func onOpenProfile() {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OpenProfile"), object: galleryObject?[ACTIVITY_FEED_BY_USER])
    }
    
    func onOpenPhoto() {
        if let image = prevImageView.image  {
            let window = UIApplication.shared.keyWindow
            var idmphotos : [IDMPhoto] = []
            let photo = IDMPhoto(image: image)
            if let object = galleryObject {
                photo?.caption = object[ACTIVITY_FEED_CAPTION] as! String!
            }
            idmphotos.append(photo!)
            let browser : IDMPhotoBrowser = IDMPhotoBrowser(photos: idmphotos)
            browser.delegate = self
            browser.displayActionButton = false
            browser.displayArrowButton = true
            browser.displayCounterLabel = true
            browser.usePopAnimation = true
            browser.setInitialPageIndex(0)
            browser.useWhiteBackgroundColor = false
            window?.topViewController()?.present(browser, animated: true, completion: nil)
        }
    }
    
}
