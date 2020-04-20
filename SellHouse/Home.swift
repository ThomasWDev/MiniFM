//
//  Home.swift
//  Minifm
//
//  Created by Thomas on 18/03/16.
//  Copyright © 2016 GF. All rights reserved.
//


import UIKit
import Parse
import GoogleMobileAds
import AudioToolbox



class PropertyCell: UICollectionViewCell {
    @IBOutlet weak var pImage: UIImageView!
    @IBOutlet weak var pTitle: UILabel!
    @IBOutlet weak var pSquareMeters: UILabel!
    @IBOutlet weak var pDescription: UILabel!
    @IBOutlet weak var pPrice: UILabel!
    @IBOutlet weak var typeActionLabel: UILabel!
    @IBOutlet weak var pShareButt: UIButton!
    @IBOutlet weak var pFavoriteButt: UIButton!
    @IBOutlet weak var pDeleteFavButt: UIButton!
}


class Home: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, GADBannerViewDelegate
{
    
    @IBOutlet weak var containerView: UIScrollView!
    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var stateCityTxt: UITextField!
    @IBOutlet weak var typesOutlet: UIButton!
    @IBOutlet weak var actionsOutlet: UIButton!
    @IBOutlet weak var typesActionsTableView: UITableView!
    @IBOutlet weak var recentCollView: UICollectionView!
    @IBOutlet weak var searchOutlet: UIButton!
    @IBOutlet weak var touOutlet: UIButton!
    
    // AdMob
    var adMobBannerView = GADBannerView()
    
    @IBOutlet weak var contView: UIView!
    
    // Vars
    var recentArray = [PFObject]()
    var buttonSelected = UIButton()
    var tempArr = [String]()
    
    let typesArray = [
        "All Types",
        "Houses",
        "Apartments",
        "Lands",
        "Villas",
        "Offices"
    ]
    
    let actionsArray = [
        "All Actions",
        "Sales",
        "Rentals"
    ]
    
    

    
override func viewWillAppear(_ animated: Bool) {
        self.setNeedsStatusBarAppearanceUpdate()
        
    
    
    
    
        // Hide Table View Ini
        typesActionsTableView.frame.origin.y = view.frame.size.height
        
        // Bar Button
        let butt = UIButton(type: UIButtonType.custom)
        butt.adjustsImageWhenHighlighted = false
        butt.frame = CGRect(x: 0, y: 0, width: 70, height: 44)
        
        // Submit Button
        if PFUser.current() != nil {
            
            butt.setTitle("ACCOUNT", for: UIControlState())
            butt.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
            butt.titleLabel?.textColor = UIColor.white
        } else {
            butt.setTitle("LOGIN", for: UIControlState())
            butt.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
            butt.titleLabel?.textColor = UIColor.white
        }
        butt.addTarget(self, action: #selector(submitPropertyButt(_:)), for: UIControlEvents.touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: butt)
        
        // Query
        queryRecents()
    }
    
override func viewDidLoad() {
        super.viewDidLoad()
    
        typesActionsTableView.layer.cornerRadius = 6
        typesActionsTableView.layer.borderColor = UIColor.darkGray.cgColor
        
        // ScrollView
        containerView.contentSize = CGSize(width: containerView.frame.size.width, height: recentCollView.frame.origin.y + recentCollView.frame.size.height + 60)
        
        // Ini AdMob
        initAdMobBanner()
        
}
    
    
// Refresh
@IBAction func refreshButt(_ sender: AnyObject) {
        queryRecents()
}
    
    
    
// Home Properties - Query max 5 properties
func queryRecents() {
        recentArray.removeAll()
        showHUD()
        
        let query = PFQuery(className: PROP_CLASS_NAME)
        query.includeKey(USER_CLASS_NAME)
        query.order(byDescending: "createdAt")
        query.limit = 5
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.recentArray = objects!
                self.recentCollView.reloadData()
                self.hideHUD()
                
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }}
        
    }
    
    
func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
}
    
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recentArray.count
}
    
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PropertyCell", for: indexPath) as! PropertyCell
        
        var propClass = PFObject(className: PROP_CLASS_NAME)
        propClass = recentArray[(indexPath as NSIndexPath).row]
        
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
    
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.size.width, height: 277)
}
    
    
    
// Select Property
func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var propClass = PFObject(className: PROP_CLASS_NAME)
        propClass = recentArray[(indexPath as NSIndexPath).row]
        
        let pdVC =  storyboard!.instantiateViewController(withIdentifier: "PropertyDetails") as! PropertyDetails
        pdVC.propObj = propClass
        navigationController?.pushViewController(pdVC, animated: true)
}
    
    
    
    
// Submit
func submitPropertyButt(_ sender: UIButton) {
        
        if PFUser.current() != nil   {
            let proVC = storyboard?.instantiateViewController(withIdentifier: "Profile") as! Profile
            navigationController?.pushViewController(proVC, animated: true)
            print("\(PFUser.current()!.username!) is LOGGED!")
            
        } else {
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
            present(loginVC, animated: true, completion: nil)
        }
}
    
    
    
@IBAction func selectTypeButt(_ sender: AnyObject) {
        tempArr.removeAll(keepingCapacity: true)
        tempArr = typesArray
        showTableView(typesOutlet)
}
    
@IBAction func selectActionButt(_ sender: AnyObject) {
        tempArr.removeAll(keepingCapacity: true)
        tempArr = actionsArray
        showTableView(actionsOutlet)
}
    
    
func showTableView(_ buttSel: UIButton) {
        typesActionsTableView.reloadData()
        buttonSelected = buttSel
        typesActionsTableView.center = view.center
}
    
func hideTableView () {
        typesActionsTableView.frame.origin.y = view.frame.size.height
}
    
    
func numberOfSections(in tableView: UITableView) -> Int {
        return 1
}
    
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempArr.count
}
    
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "\(tempArr[(indexPath as NSIndexPath).row])"
        return cell
}
    
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        buttonSelected.setTitle(cell!.textLabel!.text!, for: UIControlState())
        hideTableView()
}
    
    
    
// Share Button
@IBAction func sharePropButt(_ sender: AnyObject) {
        let button = sender as! UIButton
        let indexP = IndexPath(item: button.tag, section: 0)
        let cell = recentCollView.cellForItem(at: indexP) as! PropertyCell
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
        
        if PFUser.current() != nil {
            let favClass = PFObject(className: FAV_CLASS_NAME)
            var propClass = PFObject(className: PROP_CLASS_NAME)
            propClass = recentArray[button.tag]
            let currentUser = PFUser.current()
            
            favClass[FAV_USER] = currentUser
            favClass[FAV_PROPERTY] = propClass
            favClass.saveInBackground { (success, error) -> Void in
                if error == nil {
                    let alert = UIAlertView(title: APP_NAME,
                        message: "Added to your Favorites",
                        delegate: nil,
                        cancelButtonTitle: "OK" )
                    alert.show()
                } else {
                    let alert = UIAlertView(title: APP_NAME,
                        message: "Something went wrong, try again later",
                        delegate: nil,
                        cancelButtonTitle: "OK" )
                    alert.show()
                } }
            
        } else {
            let alert = UIAlertView(title: APP_NAME,
                                    message: "You must login or sign up to add Favorites",
                                    delegate: self,
                                    cancelButtonTitle: "OK",
                                    otherButtonTitles: "Login" )
            alert.show()
        }
}

func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.buttonTitle(at: buttonIndex) == "Login" {
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! Login
            present(loginVC, animated: true, completion: nil)
        }
}
    
    
    
// Search Button
@IBAction func searchPropertiesButt(_ sender: AnyObject) {
        let pfVC = storyboard?.instantiateViewController(withIdentifier: "PropertiesFound") as! PropertiesFound
        
        pfVC.cityState = stateCityTxt.text!.lowercased()
        pfVC.types = typesOutlet.titleLabel!.text!
        pfVC.actions = actionsOutlet.titleLabel!.text!
        
        navigationController?.pushViewController(pfVC, animated: true)
}
    
    
@IBAction func touButt(_ sender: AnyObject) {
        let touVC = self.storyboard?.instantiateViewController(withIdentifier: "TermsOfUse") as! TermsOfUse
        present(touVC, animated: true, completion: nil)
}
    
    
func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
}
    
    
    
    
    
// AdMob Banner
    func initAdMobBanner() {
        adMobBannerView.adSize =  GADAdSizeFromCGSize(CGSize(width: 320, height: 50))
        adMobBannerView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: 320, height: 50)
        adMobBannerView.adUnitID = ADMOB_UNIT_AD
        adMobBannerView.rootViewController = self
        adMobBannerView.delegate = self
        view.addSubview(adMobBannerView)
        
        let request = GADRequest()
        adMobBannerView.load(request)
    }
    
    
    // Hide the banner
    func hideBanner(_ banner: UIView) {
        UIView.beginAnimations("hideBanner", context: nil)
        // Hide the banner moving it below the bottom of the screen
        banner.frame = CGRect(x: 0, y: self.view.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
        
    }
    
    // Show the banner
    func showBanner(_ banner: UIView) {
        UIView.beginAnimations("showBanner", context: nil)
        
        // Move the banner on the bottom of the screen
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: self.view.frame.size.height - banner.frame.size.height - 44,
                              width: banner.frame.size.width, height: banner.frame.size.height);
        
        UIView.commitAnimations()
        banner.isHidden = false
        
    }
    
    // AdMob banner available
    func adViewDidReceiveAd(_ view: GADBannerView!) {
        print("AdMob loaded!")
        showBanner(adMobBannerView)
    }
    
    // NO AdMob banner available
    func adView(_ view: GADBannerView!, didFailToReceiveAdWithError error: GADRequestError!) {
        print("AdMob Can't load ads right now, they'll be available later \n\(error)")
        hideBanner(adMobBannerView)
    }
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
