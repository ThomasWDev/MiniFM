//
//  MFCommentViewController.swift
//  Minifm
//
//  Created by Thomas on 3/1/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import AudioToolbox
import SlackTextViewController
import Parse
import ParseLiveQuery

class MFCommentViewController: SLKTextViewController {

    fileprivate var comments = [PFObject]()
    var gallerryObject : PFObject?
    //Comment
    fileprivate var subscriptionComment: Subscription<PFObject>?
    fileprivate var countComments = 0
    fileprivate var commentsQuery : PFQuery<PFObject>?
    fileprivate let liveQueryClient = ParseLiveQuery.Client()
    fileprivate var isSentByCurrentUser = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadComments()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return comments.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        let comment = comments[indexPath.row]
        cell.model = comment
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let commentObject = comments[indexPath.row]
        let  margin : CGFloat = 10.0
        var  height = margin
        let kContentLength = UIScreen.main.bounds.width - 64
        let contentHeight = CommentCell.attributeHeightForEntity(message: commentObject, width: CGFloat(kContentLength))
        if (contentHeight < 20) {
            height = height + 50
        } else {
            height = height + contentHeight + 40
        }
        return  height
        
    }
    
    override func didPressRightButton(_ sender: Any?) {
        
        if let object = gallerryObject {
            isSentByCurrentUser = true
            let commentObject = PFObject(className: COMMENT_CLASS_NAME)
            commentObject[COMMENT_CONTENT] = self.textInputbar.textView.text
            commentObject[COMMENT_BY_USER] = PFUser.current()
            commentObject[COMMENT_ACTIVITY_FEED_ID] = object.objectId
            commentObject[COMMENT_ACTIVITY_FEED] = object
            AudioServicesPlaySystemSound(1004)
            self.textInputbar.textView.text = ""
            self.comments.append(commentObject)
            let indexPath = IndexPath(item: self.comments.count - 1, section: 0)
            self.tableView?.beginUpdates()
            self.tableView?.insertRows(at: [indexPath], with: .bottom)
            self.tableView?.endUpdates()
            DispatchQueue.main.async(execute: {
                self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
            })
            commentObject.saveInBackground(block: { (success, error) in
                if success == true {
                    print("Success")
                }
            })
        }
        
        
    }
    
    deinit {
        print(#function)
        liveQueryClient.unsubscribe(commentsQuery!, handler: subscriptionComment!)
    }
    
    //MARK: - Actions
    
    func onBackClicked() {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: - Helper methods
    
    func initializeStyle() {
        self.navigationItem.hidesBackButton = true
        //left back
        let menuButton = Utils.createButtonWithIcon(icon: UIImage(named: "back_btn")!)
        menuButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        menuButton.addTarget(self, action: #selector(onBackClicked), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        //Text input
        self.textInputbar.autoHideRightButton = false
        textInputbar.backgroundColor = UIColor(colorLiteralRed: 237/255.0, green: 238/255.0, blue: 242/255.0, alpha: 1)
        self.textInputbar.textView.placeholder = "Type Message..."
        self.textInputbar.textView.keyboardType = UIKeyboardType.default
        self.tableView?.tableFooterView = UIView()
        self.tableView?.backgroundColor = UIColor.groupTableViewBackground
        self.isInverted = false
        self.shouldScrollToBottomAfterKeyboardShows = true
        self.tableView?.separatorStyle = .none
        //Register cell
        let cellNib = UINib(nibName: "CommentCell", bundle: nil)
        self.tableView?.register(cellNib, forCellReuseIdentifier: "CommentCell")
        commentsQuery = PFQuery(className: COMMENT_CLASS_NAME)
        commentsQuery?.includeKey(COMMENT_BY_USER)
        commentsQuery?.whereKey(COMMENT_ACTIVITY_FEED_ID, equalTo: gallerryObject!.objectId!)
        subscriptionComment = liveQueryClient.subscribe(commentsQuery!)
        _ = subscriptionComment?.handle(Event.created) { _ , object in
            print("Created")
            DispatchQueue.main.async(execute: {
                let userComment = object.object(forKey: COMMENT_BY_USER) as! NSDictionary
                let userObjectId = userComment.object(forKey: "objectId")
                let queryUser = PFUser.query()
                queryUser?.whereKey("objectId", equalTo: userObjectId!)
                queryUser?.getFirstObjectInBackground(block: { (object1, error) in
                    if let user = object1 {
                        if user.objectId != PFUser.current()?.objectId {
                            let commentObject = PFObject(className: COMMENT_CLASS_NAME)
                            commentObject.objectId = object.objectId
                            commentObject[COMMENT_BY_USER] = user
                            commentObject[COMMENT_CONTENT] = object.object(forKey: COMMENT_CONTENT)
                            self.comments.append(commentObject)
                            let indexPath = IndexPath(item: self.comments.count - 1, section: 0)
                            self.tableView?.beginUpdates()
                            self.tableView?.insertRows(at: [indexPath], with: .bottom)
                            self.tableView?.endUpdates()
                            self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        }
                    }
                })
                
            })
            
        }
        //Pedning for now
//        _ = subscriptionComment?.handle(Event.deleted) { _, object in
//            print("Deleted")
//            DispatchQueue.main.async(execute: {
//                if (object[COMMENT_BY_USER] as! PFUser).objectId != PFUser.current()?.objectId {
//                    var index = 0
//                    var found = false
//                    for item in self.comments {
//                        if item.objectId == object.objectId {
//                            found = true
//                            break;
//                        }
//                        index += 1
//                    }
//                    if found == true {
//                        self.comments.remove(at: index)
//                        let indexPath = IndexPath(item: index, section: 0)
//                        self.tableView?.beginUpdates()
//                        self.tableView?.deleteRows(at: [indexPath], with: .fade)
//                        self.tableView?.endUpdates()
//                    }
//                }
//            })
//        }
    }
    
    func loadComments() {
        self.comments.removeAll()
        IndicatorManager.shared.startIndicatorAnimation(inview: self.view)
        if let object = gallerryObject {
            let commentsObject = PFQuery(className: COMMENT_CLASS_NAME)
            commentsObject.includeKey(COMMENT_BY_USER)
            commentsObject.whereKey(COMMENT_ACTIVITY_FEED, equalTo: object)
            commentsObject.order(byAscending: "createdAt")
            commentsObject.findObjectsInBackground(block: { (result, error) in
                IndicatorManager.shared.stopIndicatorAnimation(inview: self.view)
                if let arr = result {
                    if arr.count > 0 {
                        self.comments.append(contentsOf: arr)
                        self.tableView?.reloadData()
                        let indexPath = IndexPath(item: self.comments.count - 1, section: 0)
                        DispatchQueue.main.async(execute: {
                            self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        })
                    }
                }
            })
        }
    }
    

}
