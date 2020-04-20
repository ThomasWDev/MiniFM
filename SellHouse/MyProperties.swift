//
//  MyProperties.swift
//  Minifm
//
//  Created by Thomas on 18/03/16.
//  Copyright © 2016 GF. All rights reserved.
//


import UIKit
import Parse



class MyPropCell: UITableViewCell {
    @IBOutlet weak var pImage: UIImageView!
    @IBOutlet weak var pTitleLabel: UILabel!
    @IBOutlet weak var pPriceLabel: UILabel!
}


class MyProperties: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet weak var myPropTableView: UITableView!
    
    var myPropArray = [PFObject]()
    var favArray = [PFObject]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        queryMyProperties()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "My Properties"
        
        // Back Button
        let butt = UIButton(type: UIButtonType.custom)
        butt.adjustsImageWhenHighlighted = false
        butt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        butt.setBackgroundImage(UIImage(named: "backButt"), for: UIControlState())
        butt.addTarget(self, action: #selector(backButt(_:)), for: UIControlEvents.touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: butt)
        
        // Add New Button
        let npButt = UIButton(type: UIButtonType.custom)
        npButt.adjustsImageWhenHighlighted = false
        npButt.frame = CGRect(x: 0, y: 0, width: 74, height: 44)
        npButt.addTarget(self, action: #selector(newPropButt(_:)), for: UIControlEvents.touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: npButt)
        npButt.setTitle("ADD NEW", for: UIControlState())
        npButt.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        npButt.titleLabel?.textColor = UIColor.white
        
    }
    
    func backButt(_ sender:UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    // Query Properties
    func queryMyProperties() {
        showHUD()
        myPropArray.removeAll()
        
        let query = PFQuery(className: PROP_CLASS_NAME)
        query.whereKey(PROP_SELLER_POINTER, equalTo: PFUser.current()!)
        
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.myPropArray = objects!
                
                // Reload a TableView)
                self.myPropTableView.reloadData()
                self.hideHUD()
                
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }}
    }
    
    
    // TableView Delegates
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myPropArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPropCell", for: indexPath) as! MyPropCell
        
        var propClass = PFObject(className: PROP_CLASS_NAME)
        propClass = myPropArray[(indexPath as NSIndexPath).row]
        
        if propClass[PROP_TITLE] != nil { cell.pTitleLabel.text = "\(propClass[PROP_TITLE]!)"
        } else { cell.pTitleLabel.text = "N/A"  }
        
        if propClass[PROP_PRICE] != nil { cell.pPriceLabel.text = "\(propClass[PROP_PRICE]!)"
        } else { cell.pPriceLabel.text = "N/A" }
        
        let imageFile = propClass[PROP_IMAGE] as? PFFile
        imageFile?.getDataInBackground { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.pImage.image = UIImage(data:imageData)
                } } }
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    
    // Edit Property
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var propClass = PFObject(className: PROP_CLASS_NAME)
        propClass = myPropArray[(indexPath as NSIndexPath).row]
        
        let epVC = storyboard?.instantiateViewController(withIdentifier: "EditProperty") as! EditProperty
        epVC.myPropObj = propClass
        navigationController?.pushViewController(epVC, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            
            var propClass = PFObject(className: PROP_CLASS_NAME)
            propClass = myPropArray[(indexPath as NSIndexPath).row]
            
            self.favArray.removeAll()
            let query = PFQuery(className: FAV_CLASS_NAME)
            query.whereKey(FAV_PROPERTY, equalTo: propClass)
            query.findObjectsInBackground { (objects, error)-> Void in
                if error == nil {
                    self.favArray = objects!
                    
                    if self.favArray.count > 0 {
                        for i in 0..<self.favArray.count {
                            DispatchQueue.main.async(execute: {
                                var favClass = PFObject(className: FAV_CLASS_NAME)
                                favClass = self.favArray[i]
                                favClass.deleteInBackground {(success, error) -> Void in
                                    if error == nil {
                                        print("FAVORITE DELETED")
                                    }}
                            })
                        }
                    }
                    
                }}
            
            
            propClass.deleteInBackground {(success, error) -> Void in
                if error == nil {
                    self.myPropArray.remove(at: (indexPath as NSIndexPath).row)
                    tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                    self.myPropTableView.reloadData()
                    
                    self.simpleAlert("Property successfully deleted")
                     _ = self.navigationController?.popViewController(animated: true)
                    
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                }}
            
            
        }
    }
    
    
    // Add New Button
    func newPropButt(_ sender:UIButton) {
        let epVC = storyboard?.instantiateViewController(withIdentifier: "EditProperty") as! EditProperty
        navigationController?.pushViewController(epVC, animated: true)    
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
