//
//  PropertyDetails.swift
//  Minifm
//
//  Created by Thomas on 18/03/16.
//  Copyright © 2016 GF. All rights reserved.
//


import UIKit
import Parse
import MapKit
import MessageUI
import GoogleMobileAds
import AudioToolbox


class PropertyDetails: UIViewController, UIScrollViewDelegate, MKMapViewDelegate, MFMailComposeViewControllerDelegate, GADBannerViewDelegate
{
    
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var squareMtLabel: UILabel!
    @IBOutlet weak var previewScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var descriptionTxt: UITextView!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var addressTop: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var detailsTop: UILabel!
    @IBOutlet weak var detailsTxt: UITextView!
    @IBOutlet weak var sellerInfoTop: UILabel!
    @IBOutlet weak var sellerAvatar: UIImageView!
    @IBOutlet weak var sellerTelOutlet: UIButton!
    @IBOutlet weak var sellerMobileOutlet: UIButton!
    @IBOutlet weak var sellerEmailOutlet: UIButton!
    @IBOutlet weak var sellerNameLabel: UILabel!
    
    //AdMob
    var adMobBannerView = GADBannerView()
    
    @IBOutlet weak var fbOutlet: UIButton!
    @IBOutlet weak var twOutlet: UIButton!
    
    @IBOutlet weak var contView: UIView!
    
    // Vars
    var propObj = PFObject(className: PROP_CLASS_NAME)
    var sellerPointer = PFObject(className: USER_CLASS_NAME)
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinView:MKPinAnnotationView!
    var region: MKCoordinateRegion!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Initialize a BACK BarButton Item
        let butt = UIButton(type: UIButtonType.custom)
        butt.adjustsImageWhenHighlighted = false
        butt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        butt.setBackgroundImage(UIImage(named: "backButt"), for: UIControlState())
        butt.addTarget(self, action: #selector(backButt(_:)), for: UIControlEvents.touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: butt)
        
        // Initialize a REPORT BarButton Item
        let reportButt = UIButton(type: UIButtonType.custom)
        reportButt.adjustsImageWhenHighlighted = false
        reportButt.frame = CGRect(x: 0, y: 0, width: 54, height: 44)
        //reportButt.setBackgroundImage(UIImage(named: "reportButt"), forState: UIControlState.Normal)
        reportButt.addTarget(self, action: #selector(reportButton(_:)), for: UIControlEvents.touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reportButt)
        reportButt.setTitle("REPORT", for: UIControlState())
        reportButt.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 13)
        reportButt.titleLabel?.textColor = UIColor.white
        
        
        sellerAvatar.layer.cornerRadius = sellerAvatar.bounds.size.width/2
        sellerAvatar.layer.borderColor = UIColor.darkGray.cgColor
        sellerAvatar.layer.borderWidth = 0
        
        // Setup images rect
        image1.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 180)
        image2.frame = CGRect(x: view.frame.size.width, y: 0, width: view.frame.size.width, height: 180)
        image3.frame = CGRect(x: view.frame.size.width*2, y: 0, width: view.frame.size.width, height: 180)
        
        
        // Ini AdMob
        initAdMobBanner()
        
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: detailsView.frame.size.height + detailsView.frame.origin.y)
        
        
        // Details
        getPropertyDetails()
        
        
    }
    
    func backButt(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    
    
    // Details
    func getPropertyDetails() {
        
        // Set Title
        self.title = "\(propObj[PROP_TYPE]!) - \(propObj[PROP_ACTION]!)"
        
        
        // GET PROPERTY INFO
        if propObj[PROP_TITLE] != nil { titleLabel.text = "\(propObj[PROP_TITLE]!)"
        } else { titleLabel.text = "N/A" }
        
        if propObj[PROP_PRICE] != nil { priceLabel.text = "\(propObj[PROP_PRICE]!)"
        } else { priceLabel.text = "N/A" }
        
        if propObj[PROP_SQUARE_METERS] != nil { squareMtLabel.text = "\(propObj[PROP_SQUARE_METERS]!)"
        } else { squareMtLabel.text = "N/A" }
        
        if propObj[PROP_DESCRIPTION] != nil {  descriptionTxt.text = "\(propObj[PROP_DESCRIPTION]!)"
        } else { descriptionTxt.text = "Description is not available"  }
        descriptionTxt.sizeToFit()
        
        // Move detailsView underneath the descriptionTxt
        detailsView.frame.origin.y = descriptionTxt.frame.size.height + descriptionTxt.frame.origin.y + 10
        
        if propObj[PROP_ADDRESS] != nil {
            addressLabel.text = "\(propObj[PROP_ADDRESS]!)"
            addPinOnMap(addressLabel.text!)
        } else { addressLabel.text = "Address is not available" }
        
        if propObj[PROP_DETAILS] != nil {  detailsTxt.text = "\(propObj[PROP_DETAILS]!)"
        } else { detailsTxt.text = "Details are not available" }
        
        
        // Get Images
        DispatchQueue.main.async(execute: {
            let imageFile = self.propObj[PROP_IMAGE] as? PFFile
            imageFile?.getDataInBackground { (imageData, error) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        self.image1.image = UIImage(data: imageData)
                    } } }
            
            let imageFile2 = self.propObj[PROP_IMAGE2] as? PFFile
            imageFile2?.getDataInBackground { (imageData, error) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        self.image2.image = UIImage(data:imageData)
                        self.image2.frame.origin.x = self.view.frame.size.width
                    } } }
            
            let imageFile3 = self.propObj[PROP_IMAGE3] as? PFFile
            imageFile3?.getDataInBackground { (imageData, error) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        self.image3.image = UIImage(data:imageData)
                        self.image3.frame.origin.x = self.view.frame.size.width*2
                    } } }
            
            // Set previewScrollView content size
            self.previewScrollView.contentSize = CGSize(width: self.view.frame.size.width * 3.0, height: self.previewScrollView.frame.size.height-44)
        })
        
        
        
        
        //Info Seller
        sellerPointer = propObj[PROP_SELLER_POINTER] as! PFUser
        do { sellerPointer = try sellerPointer.fetchIfNeeded() } catch {  print("Error") }
        
        sellerAvatar.image = UIImage(named: "logo")
        let avatarFile = sellerPointer[USER_AVATAR] as? PFFile
        avatarFile?.getDataInBackground { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.sellerAvatar.image = UIImage(data:imageData)
                } } }
        
        
        if sellerPointer[USER_TEL] != nil { sellerTelOutlet.setTitle("\(sellerPointer[USER_TEL]!)", for: .normal)
        } else { sellerTelOutlet.setTitle("N/A", for: .normal) }
        if "\(sellerPointer[USER_TEL])" == "" { sellerTelOutlet.setTitle("N/A", for: .normal) }
        
        if sellerPointer[USER_MOBILE] != nil { sellerMobileOutlet.setTitle("\(sellerPointer[USER_MOBILE]!)", for: .normal)
        } else { sellerMobileOutlet.setTitle("N/A", for: .normal) }
        if "\(sellerPointer[USER_MOBILE])" == "" { sellerMobileOutlet.setTitle("N/A", for: .normal) }
        
        sellerEmailOutlet.setTitle("\(sellerPointer[USER_EMAIL]!)", for: .normal)
        sellerNameLabel.text = "\(sellerPointer[USER_FULLNAME]!)"
        
        
        // Hide social buttons if User has not stored his/her links in the Profile screen
        if "\(sellerPointer[USER_FACEBOOK])" == "" { fbOutlet.isHidden = true }
        if sellerPointer[USER_FACEBOOK] == nil { fbOutlet.isHidden = true }
        
        if "\(sellerPointer[USER_TWITTER])" == "" { twOutlet.isHidden = true }
        if sellerPointer[USER_TWITTER] == nil { twOutlet.isHidden = true }
        
    }
    
    
    
    // MapView PIN
    func addPinOnMap(_ address: String) {
        mapView.delegate = self
        
        if mapView.annotations.count != 0 {
            annotation = mapView.annotations[0]
            mapView.removeAnnotation(annotation)
        }
        // Make a search on the Map
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = address
        localSearch = MKLocalSearch(request: localSearchRequest)
        
        localSearch.start { (localSearchResponse, error) -> Void in
            // Add PointAnnonation text and a Pin to the Map
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = self.titleLabel.text
            
            if localSearchResponse != nil {
                self.pointAnnotation.coordinate = CLLocationCoordinate2D( latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:localSearchResponse!.boundingRegion.center.longitude)
            } else {
                let alert = UIAlertView(title: APP_NAME,
                                        message: "This Property's address couldn't be found on Map",
                                        delegate: nil,
                                        cancelButtonTitle: "OK" )
                alert.show()
            }
            
            self.pinView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinView.annotation!)
            
            // Zoom the Map to the location
            self.region = MKCoordinateRegionMakeWithDistance(self.pointAnnotation.coordinate, 1000, 1000);
            self.mapView.setRegion(self.region, animated: true)
            self.mapView.regionThatFits(self.region)
            self.mapView.reloadInputViews()
        }
    }
    
    
    // PIN Annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Handle custom annotations.
        if annotation.isKind(of: MKPointAnnotation.self) {
            
            // Try to dequeue an existing pin view first.
            let reuseID = "CustomPinAnnotationView"
            var annotView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
            
            if annotView == nil {
                annotView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
                annotView!.canShowCallout = true
                
                // Custom Pin image
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
                imageView.image =  UIImage(named: "locationPin")
                imageView.center = annotView!.center
                imageView.contentMode = UIViewContentMode.scaleAspectFill
                annotView!.addSubview(imageView)
                
                // Add a RIGHT CALLOUT Accessory
                let rightButton = UIButton(type: .custom)
                rightButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
                rightButton.layer.cornerRadius = rightButton.bounds.size.width/2
                rightButton.clipsToBounds = true
                rightButton.setImage(UIImage(named: "openInMaps"), for: .normal)
                annotView!.rightCalloutAccessoryView = rightButton
            }
            return annotView
        }
        
        return nil
    }
    
    
    // Native iOS Maps
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        annotation = view.annotation
        let coordinate = annotation.coordinate
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapitem = MKMapItem(placemark: placemark)
        mapitem.name = annotation.title!
        mapitem.openInMaps(launchOptions: nil)
    }
    
    
    
    // Seller Button - Facebook
    @IBAction func sellerFBbutt(_ sender: AnyObject) {
        if sellerPointer[USER_FACEBOOK] != nil {
            let fbURL = URL(string: "\(sellerPointer[USER_FACEBOOK]!)")
            UIApplication.shared.openURL(fbURL!)
            
        } else if sellerPointer[USER_FACEBOOK] == nil {
            let alert = UIAlertView(title: APP_NAME,
                                    message: "Sorry, \(sellerPointer[USER_FULLNAME]!) does not have a Facebook page",
                delegate: nil,
                cancelButtonTitle: "OK")
            alert.show()
            
        }
    }
    
    
    // Seller Button - Twitter
    @IBAction func sellerTWbutt(_ sender: AnyObject) {
        if sellerPointer[USER_TWITTER] != nil {
            let twURL = URL(string: "\(sellerPointer[USER_TWITTER]!)")
            UIApplication.shared.openURL(twURL!)
        } else {
            let alert = UIAlertView(title: APP_NAME,
                                    message: "Sorry, \(sellerPointer[USER_FULLNAME]!) does not have a Twitter page",
                delegate: nil,
                cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    
    
    // Telephon Button
    @IBAction func telButt(_ sender: AnyObject) {
        let butt = sender as! UIButton
        if butt.titleLabel?.text != "N/A" {
            let aURL = URL(string: "telprompt://\(butt.titleLabel!.text!)")!
            if UIApplication.shared.canOpenURL(aURL) { UIApplication.shared.openURL(aURL) }
        }
    }
    
    // Mobile Button
    @IBAction func mobileButt(_ sender: AnyObject) {
        let butt = sender as! UIButton
        if butt.titleLabel!.text != "N/A" {
            let aURL = URL(string: "telprompt://\(butt.titleLabel!.text!)")!
            if UIApplication.shared.canOpenURL(aURL) { UIApplication.shared.openURL(aURL) }
        }
    }
    
    
    // Email Button
    @IBAction func mailButt(_ sender: AnyObject) {
        let butt = sender as! UIButton
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients(["\(butt.titleLabel!.text!)"])
        mailComposer.setSubject("Interested to \(titleLabel!.text!)")
        mailComposer.setMessageBody("", isHTML: true)
        
        // Attach an image
        let imageData = UIImageJPEGRepresentation(image1.image!, 1.0)
        mailComposer.addAttachmentData(imageData!, mimeType: "image/png", fileName: "property.png")
        
        if MFMailComposeViewController.canSendMail() {
            present(mailComposer, animated: true, completion: nil)
        } else {
            let alert = UIAlertView(title: APP_NAME,
                                    message: "Your device cannot send emails. Please configure an email address into Settings -> Mail, Contacts, Calendars.",
                                    delegate: nil,
                                    cancelButtonTitle: "OK")
            alert.show()
        }
    }
    // Email delegate
    func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
        var outputMessage = ""
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue: outputMessage = "Mail cancelled"
        case MFMailComposeResult.saved.rawValue: outputMessage = "Mail saved"
        case MFMailComposeResult.sent.rawValue: outputMessage = "Mail sent"
        case MFMailComposeResult.failed.rawValue: outputMessage = "Something went wrong with sending Mail, try again later."
        default: break }
        
        simpleAlert(outputMessage)
        dismiss(animated: false, completion: nil)
    }
    
    
    
    
    // Inapropriate Button
    func reportButton(_ sender:UIButton) {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients([REPORT_EMAIL_ADDRESS])
        mailComposer.setSubject("Reporting inappropriate contents on \(APP_NAME)")
        // The red strong below has HTML tags
        mailComposer.setMessageBody("Hello,<br>the listing with Title: <strong>\(titleLabel.text!)</strong><br>and ID: <strong>\(propObj.objectId!)</strong><br>from Seller: <strong>\(sellerPointer[USER_FULLNAME]!)</strong><br>contains inappropriate/offensive contents.<br>Please review and remove it.<br>Thanks,<br>Regards", isHTML: true)
        
        // Attach an image
        let imageData = UIImageJPEGRepresentation(image1.image!, 1.0)
        mailComposer.addAttachmentData(imageData!, mimeType: "image/png", fileName: "property.png")
        
        if MFMailComposeViewController.canSendMail() {
            present(mailComposer, animated: true, completion: nil)
        } else {
            let alert = UIAlertView(title: APP_NAME,
                                    message: "Your device cannot send emails. Please configure an email address into Settings -> Mail, Contacts, Calendars.",
                                    delegate: nil,
                                    cancelButtonTitle: "OK")
            alert.show()
        }
        
    }
    
    
    // ScrollView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Switch pageControl to current page
        let pageWidth = previewScrollView.frame.size.width
        let page = Int(floor((previewScrollView.contentOffset.x * 2 + pageWidth) / (pageWidth * 2)))
        pageControl.currentPage = page
    }
    
    
    
    
    // AdMob banner
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
        banner.frame = CGRect(x: 0, y: view.frame.size.height, width: banner.frame.size.width, height: banner.frame.size.height)
        UIView.commitAnimations()
        banner.isHidden = true
        
    }
    
    // Show the banner
    func showBanner(_ banner: UIView) {
        UIView.beginAnimations("showBanner", context: nil)
        
        // Move the banner on the bottom of the screen
        banner.frame = CGRect(x: view.frame.size.width/2 - banner.frame.size.width/2, y: view.frame.size.height - banner.frame.size.height - 44,
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
