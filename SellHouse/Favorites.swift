//
//  Favorites.swift
//  Minifm
//
//  Created by Thomas on 18/03/16.
//  Copyright © 2016 GF. All rights reserved.
//


import UIKit
import Parse


class Favorites: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate
{
    
    @IBOutlet weak var propertiesCollView: UICollectionView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var favArray = [PFObject]()
    var favTAG = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PFUser.current() != nil {  queryFavorites()  }
        
    }
    
    func queryFavorites() {
        favArray.removeAll()
        showHUD()
        
        let query = PFQuery(className: FAV_CLASS_NAME)
        query.whereKey(FAV_USER, equalTo: PFUser.current()!)
        query.includeKey(USER_CLASS_NAME)
        query.includeKey(PROP_CLASS_NAME)
        query.order(byAscending: "createdAt")
        
        query.findObjectsInBackground { (objects, error)-> Void in
            if error == nil {
                self.favArray = objects!
                self.propertiesCollView.reloadData()
                self.hideHUD()
                if self.favArray.count > 0 {  self.emptyLabel.isHidden = true  }
                
            } else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            }}
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PropertyCell", for: indexPath) as! PropertyCell
        
        var favClass = PFObject(className: FAV_CLASS_NAME)
        favClass = favArray[(indexPath as NSIndexPath).row]
        
        var propPointer = favClass[FAV_PROPERTY] as! PFObject
        do { propPointer = try propPointer.fetchIfNeeded() } catch {}
        
        var userPointer = favClass[FAV_USER] as! PFUser
        do { userPointer = try  userPointer.fetchIfNeeded() } catch {}
        
        let imageFile = propPointer[PROP_IMAGE] as? PFFile
        imageFile?.getDataInBackground { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.pImage.image = UIImage(data:imageData)
                }}}
        
        cell.typeActionLabel.text = "\(propPointer[PROP_TYPE]!) - \(propPointer[PROP_ACTION]!)"
        
        if propPointer[PROP_TITLE] != nil { cell.pTitle.text = "\(propPointer[PROP_TITLE]!)"
        } else { cell.pTitle.text = "N/A"  }
        
        if propPointer[PROP_SQUARE_METERS] != nil { cell.pSquareMeters.text = "\(propPointer[PROP_SQUARE_METERS]!)"
        } else { cell.pSquareMeters.text = "N/A"  }
        
        if propPointer[PROP_DESCRIPTION] != nil { cell.pDescription.text = "\(propPointer[PROP_DESCRIPTION]!)"
        } else { cell.pDescription.text = "N/A" }
        
        if propPointer[PROP_PRICE] != nil { cell.pPrice.text = "\(propPointer[PROP_PRICE]!)"
        } else { cell.pPrice.text = "N/A"  }
        
        cell.pShareButt.tag = (indexPath as NSIndexPath).row
        cell.pDeleteFavButt.tag = (indexPath as NSIndexPath).row
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.size.width, height: 277)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var favClass = PFObject(className: FAV_CLASS_NAME)
        favClass = favArray[(indexPath as NSIndexPath).row]
        var propPointer = favClass[FAV_PROPERTY] as! PFObject
        do { propPointer = try propPointer.fetchIfNeeded() } catch {}
        
        let pdVC = storyboard?.instantiateViewController(withIdentifier: "PropertyDetails") as! PropertyDetails
        pdVC.propObj = propPointer
        navigationController?.pushViewController(pdVC, animated: true)
    }
    
    
    
    // Delete Favorite
    @IBAction func deleteFavButt(_ sender: AnyObject) {
        let button = sender as! UIButton
        favTAG = button.tag
        
        let alert = UIAlertView(title: APP_NAME,
                                message: "Are you sure you want to delete this Property from your Favorites?",
                                delegate: self,
                                cancelButtonTitle: "Cancel",
                                otherButtonTitles: "Delete")
        alert.show()
    }

    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.buttonTitle(at: buttonIndex) == "Delete" {
            
            var favClass = PFObject(className: FAV_CLASS_NAME)
            favClass = favArray[favTAG]
            favClass.deleteInBackground {(success, error) -> Void in
                if error == nil {
                    self.queryFavorites()
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                }}
        }
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
    
    
    // Refresh Button
    @IBAction func refreshButt(_ sender: AnyObject) {
        if PFUser.current() != nil {  queryFavorites()  }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
