//
//  PropertiesFound.swift
//  Minifm
//
//  Created by Thomas on 18/03/16.
//  Copyright © 2016 GF. All rights reserved.
//


import UIKit
import Parse


class PropertiesFound: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate
{
    
    @IBOutlet weak var propertiesCollView: UICollectionView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    
    // Vars
    var cityState = ""
    var types = ""
    var actions = ""
    var propertiesArray = [PFObject]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Properties Found"
        self.edgesForExtendedLayout = UIRectEdge()
        
        
        // Bar Button
        let butt = UIButton(type: UIButtonType.custom)
        butt.adjustsImageWhenHighlighted = false
        butt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        butt.setBackgroundImage(UIImage(named: "backButt"), for: UIControlState())
        butt.addTarget(self, action: #selector(backButt(_:)), for: UIControlEvents.touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: butt)
        
        queryProperties()
    }
    
    func backButt(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    // Query Properties
    func queryProperties() {
        propertiesArray.removeAll()
        showHUD()
        
        let query = PFQuery(className: PROP_CLASS_NAME)
        query.whereKey(PROP_ADDRESS_LOWERCASE, contains: cityState.lowercased())
        if types != "All Types"     {  query.whereKey(PROP_TYPE, equalTo: types)     }
        if actions != "All Actions" {  query.whereKey(PROP_ACTION, equalTo: actions) }
        
        // Query block
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.propertiesArray = objects!
                // Reload CollView
                self.propertiesCollView.reloadData()
                self.hideHUD()
                
                // Hide emptyLabel
                if self.propertiesArray.count == 0 { self.emptyLabel.isHidden = false }
                
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }}
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return propertiesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PropertyCell", for: indexPath) as! PropertyCell
        
        var propClass = PFObject(className: PROP_CLASS_NAME)
        propClass = propertiesArray[(indexPath as NSIndexPath).row]
        
        let imageFile = propClass[PROP_IMAGE] as? PFFile
        imageFile?.getDataInBackground { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.pImage.image = UIImage(data:imageData)
                }}}
        
        cell.typeActionLabel.text = "\(propClass[PROP_TYPE]!) - \(propClass[PROP_ACTION]!)"
        
        if propClass[PROP_TITLE] != nil { cell.pTitle.text = "\(propClass[PROP_TITLE]!)"
        } else { cell.pTitle.text = "N/A"  }
        
        if propClass[PROP_SQUARE_METERS] != nil { cell.pSquareMeters.text = "\(propClass[PROP_SQUARE_METERS]!)"
        } else { cell.pSquareMeters.text = "N/A"  }
        
        if propClass[PROP_DESCRIPTION] != nil { cell.pDescription.text = "\(propClass[PROP_DESCRIPTION]!)"
        } else { cell.pDescription.text = "N/A" }
        
        if propClass[PROP_PRICE] != nil { cell.pPrice.text = "\(propClass[PROP_PRICE]!)"
        } else { cell.pPrice.text = "N/A"  }
        
        cell.pShareButt.tag = (indexPath as NSIndexPath).row
        cell.pFavoriteButt.tag = (indexPath as NSIndexPath).row
        
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.size.width, height: 277)
    }
    
    
    // Show Properties
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var propClass = PFObject(className: PROP_CLASS_NAME)
        propClass = propertiesArray[(indexPath as NSIndexPath).row]
        
        let pdVC = storyboard?.instantiateViewController(withIdentifier: "PropertyDetails") as! PropertyDetails
        pdVC.propObj = propClass
        navigationController?.pushViewController(pdVC, animated: true)
        
    }
    
    
    
    // Share Button
    @IBAction func sharePropButt(_ sender: AnyObject) {
        let button = sender as! UIButton
        let indexP = IndexPath(item: button.tag, section: 0)
        let cell = propertiesCollView.cellForItem(at: indexP) as! PropertyCell
        let messageStr = "Check out \(cell.pTitle!.text!), found on #\(APP_NAME)"
        let img = cell.pImage.image!
        let shareItems = [messageStr, img] as [Any]
        
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            // iPad
            let popOver = UIPopoverController(contentViewController: activityViewController)
            popOver.present(from: CGRect.zero, in: self.view, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        } else {
            // iPhone
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    
    
    
    // Favorite Button
    @IBAction func favoriteButt(_ sender: AnyObject) {
        let button = sender as! UIButton
        
        // USER IS LOGGED IN
        if PFUser.current() != nil {
            let favClass = PFObject(className: FAV_CLASS_NAME)
            var propClass = PFObject(className: PROP_CLASS_NAME)
            propClass = propertiesArray[button.tag]
            let currentUser = PFUser.current()
            
            // Save PFUser as Pointer
            favClass[FAV_USER] = currentUser
            // save Property as Pointer
            favClass[FAV_PROPERTY] = propClass
            
            // Saving block
            favClass.saveInBackground { (success, error) -> Void in
                if error == nil {
                    self.simpleAlert("You've added this Property to your Favorites")
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                }}
            
            
            
            // USER IS NOT LOGGED IN
        } else {
            let alert = UIAlertView(title: APP_NAME,
                                    message: "You must login/sign up to favorite a property!",
                                    delegate: self,
                                    cancelButtonTitle: "Cancel",
                                    otherButtonTitles: "Login" )
            alert.show()
        }
    }
    
    // AlertView
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.buttonTitle(at: buttonIndex) == "Login" {
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
            present(loginVC, animated: true, completion: nil)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
