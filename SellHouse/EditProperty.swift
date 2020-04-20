//
//  EditProperty.swift
//  Minifm
//
//  Created by Thomas on 18/03/16.
//  Copyright © 2016 GF. All rights reserved.
//


import UIKit
import Parse


class EditProperty: UIViewController, UITextFieldDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITableViewDataSource
{
    
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var titleTxt: UITextField!
    @IBOutlet weak var priceTxt: UITextField!
    @IBOutlet weak var squareMtTxt: UITextField!
    @IBOutlet weak var descriptionTxt: UITextView!
    @IBOutlet weak var addressTxt: UITextField!
    @IBOutlet weak var detailsTxt: UITextView!
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var typesOutlet: UIButton!
    @IBOutlet weak var actionsOutlet: UIButton!
    @IBOutlet weak var typesActionsTableView: UITableView!
    @IBOutlet var views: [UIView]!
    
    @IBOutlet weak var contView: UIView!
    
    
    // Vars
    var myPropObj = PFObject(className: PROP_CLASS_NAME)
    var myPropArray = NSMutableArray()
    var buttTAG = 0
    var buttonSelected = UIButton()
    var tempArr = [String]()
    
    let typesArray = [
        "Houses",
        "Apartments",
        "Lands",
        "Villas",
        "Offices"
    ]
    
    let actionsArray = [
        "Sales",
        "Rentals"
    ]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        if myPropObj[PROP_TITLE] != nil {
            self.title = "Edit Property"
            showPropDetails()
        } else {
            self.title = "New Property"
            detailsTxt.text = "Price: \nProperty Size: \nRooms: \nBedrooms: \nBathrooms: \nBasement: \nGarage: \nRoofing: \nFloors: \nStructure Type: \nSwimming Pool: \nAvailable From: "
        }
        
        typesActionsTableView.frame.origin.y = view.frame.size.height
        typesActionsTableView.layer.cornerRadius = 8
        typesActionsTableView.layer.borderColor = UIColor.darkGray.cgColor
        
        
        // Back Button
        let butt = UIButton(type: UIButtonType.custom)
        butt.adjustsImageWhenHighlighted = false
        butt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        butt.setBackgroundImage(UIImage(named: "backButt"), for: UIControlState())
        butt.addTarget(self, action: #selector(backButt(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: butt)
        
        // Save Button
        let saveButt = UIButton(type: UIButtonType.custom)
        saveButt.adjustsImageWhenHighlighted = false
        saveButt.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        saveButt.setTitle("SAVE", for: UIControlState())
        saveButt.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        saveButt.titleLabel?.textColor = UIColor.white
        saveButt.addTarget(self, action: #selector(saveButton(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButt)
        
        containerScrollView.contentSize = CGSize(width: containerScrollView.frame.size.width, height: image3.frame.size.height + image3.frame.origin.y)
    }
    
    
    // Back Button
    func backButt(_ sender:UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    func showPropDetails() {
        
        if myPropObj[PROP_TITLE] != nil { titleTxt.text = "\(myPropObj[PROP_TITLE]!)"
        } else { titleTxt.text = "" }
        
        if myPropObj[PROP_PRICE] != nil { priceTxt.text = "\(myPropObj[PROP_PRICE]!)"
        } else { priceTxt.text = "" }
        
        if myPropObj[PROP_SQUARE_METERS] != nil { squareMtTxt.text = "\(myPropObj[PROP_SQUARE_METERS]!)"
        } else { squareMtTxt.text = "" }
        
        if myPropObj[PROP_DESCRIPTION] != nil { descriptionTxt.text = "\(myPropObj[PROP_DESCRIPTION]!)"
        } else { descriptionTxt.text = "" }
        
        if myPropObj[PROP_ADDRESS] != nil { addressTxt.text = "\(myPropObj[PROP_ADDRESS]!)"
        } else { addressTxt.text = "" }
        
        if myPropObj[PROP_DETAILS] != nil { detailsTxt.text = "\(myPropObj[PROP_DETAILS]!)"
        } else {
            detailsTxt.text = "Price: \nProperty Size: \nRooms: \nBedrooms: \nBathrooms: \nBasement: \nGarage: \nRoofing: \nFloors: \nStructure Type: \nSwimming Pool: \nAvailable From: "
        }
        
        if myPropObj[PROP_TYPE] != nil { typesOutlet.setTitle("\(myPropObj[PROP_TYPE]!)", for: UIControlState())
        } else { typesOutlet.setTitle("Select Type", for: UIControlState()) }
        
        if myPropObj[PROP_ACTION] != nil { actionsOutlet.setTitle("\(myPropObj[PROP_ACTION]!)", for: UIControlState())
        } else { actionsOutlet.setTitle("Select Action", for: UIControlState()) }
        
        let imageFile1 = myPropObj[PROP_IMAGE] as? PFFile
        imageFile1?.getDataInBackground { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.image1.image = UIImage(data:imageData)
                } } }
        
        let imageFile2 = myPropObj[PROP_IMAGE2] as? PFFile
        imageFile2?.getDataInBackground { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.image2.image = UIImage(data:imageData)
                } } }
        
        let imageFile3 = myPropObj[PROP_IMAGE3] as? PFFile
        imageFile3?.getDataInBackground { (imageData, error) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.image3.image = UIImage(data:imageData)
                } } }
        
    }
    
    
    // Types Button
    @IBAction func selectTypeButt(_ sender: AnyObject) {
        tempArr.removeAll(keepingCapacity: true)
        tempArr = typesArray
        showTableView(typesOutlet)
        dismissKeyb()
    }
    
    
    // Actions Buttons
    @IBAction func selectActionButt(_ sender: AnyObject) {
        tempArr.removeAll(keepingCapacity: true)
        tempArr = actionsArray
        showTableView(actionsOutlet)
        dismissKeyb()
    }
    
    // Show/Hide TableView
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
    
    
    // If Tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        buttonSelected.setTitle(cell!.textLabel!.text!, for: UIControlState())
        hideTableView()
    }
    
    
    
    
    // Upload Pictures
    @IBAction func uploadPicButtons(_ sender: AnyObject) {
        let button = sender as! UIButton
        buttTAG = button.tag
        
        let alert = UIAlertView(title: APP_NAME,
                                message: "Select source",
                                delegate: self,
                                cancelButtonTitle: "Cancel",
                                otherButtonTitles: "Camera", "Photo Library")
        alert.show()
    }

    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.buttonTitle(at: buttonIndex) == "Camera" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
            {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
            
        } else if alertView.buttonTitle(at: buttonIndex) == "Photo Library" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary)
            {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        switch buttTAG {
        case 1: image1.image = image; break
        case 2: image2.image = image; break
        case 3: image3.image = image; break
        default:break }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // Save Button
    func saveButton(_ sender:UIButton) {
        showHUD()
        dismissKeyb()
        
        let currentUser = PFUser.current()
        
        
        if titleTxt.text != ""     &&   priceTxt.text != ""    &&
            descriptionTxt.text != ""  &&   addressTxt.text != ""  &&
            typesOutlet.titleLabel?.text != "Select Type"  &&  actionsOutlet.titleLabel?.text != "Select Action"
            && image1.image != nil && image2.image != nil && image3.image != nil
        {
            myPropObj[PROP_SELLER_POINTER] = currentUser
            myPropObj[PROP_TITLE] = titleTxt.text
            myPropObj[PROP_PRICE] = priceTxt.text
            myPropObj[PROP_SQUARE_METERS] = "\(squareMtTxt!.text!)"
            myPropObj[PROP_DESCRIPTION] = descriptionTxt.text
            myPropObj[PROP_ADDRESS] = addressTxt.text
            myPropObj[PROP_ADDRESS_LOWERCASE] = addressTxt.text!.lowercased()
            myPropObj[PROP_DETAILS] = detailsTxt.text
            myPropObj[PROP_TYPE] = typesOutlet.titleLabel!.text!
            myPropObj[PROP_ACTION] = actionsOutlet.titleLabel!.text!
            
            if image1.image != nil {
                let imageData = UIImageJPEGRepresentation(image1.image!, 0.5)
                let imageFile = PFFile(name:"image.jpg", data:imageData!)
                myPropObj[PROP_IMAGE] = imageFile
            }
            if image2.image != nil {
                let imageData = UIImageJPEGRepresentation(image2.image!, 0.5)
                let imageFile = PFFile(name:"image2.jpg", data:imageData!)
                myPropObj[PROP_IMAGE2] = imageFile
            }
            if image3.image != nil {
                let imageData = UIImageJPEGRepresentation(image3.image!, 0.5)
                let imageFile = PFFile(name:"image3.jpg", data:imageData!)
                myPropObj[PROP_IMAGE3] = imageFile
            }
            
            myPropObj.saveInBackground { (success, error) -> Void in
                if error == nil {
                    self.simpleAlert("Property successfully saved!")
                    self.hideHUD()
                    _ = self.navigationController?.popViewController(animated: true)
                    
                } else {
                    self.simpleAlert("\(error!.localizedDescription)")
                    self.hideHUD()
                }}
            
            
        } else {
            simpleAlert("Please compile all fields and upload 3 images to publish your Property")
            hideHUD()
        }
    }
    
    
    
    
    @IBAction func tapToDismissKeyb(_ sender: UITapGestureRecognizer) {
        dismissKeyb()
    }
    
    func dismissKeyb() {
        titleTxt.resignFirstResponder()
        priceTxt.resignFirstResponder()
        squareMtTxt.resignFirstResponder()
        descriptionTxt.resignFirstResponder()
        addressTxt.resignFirstResponder()
        detailsTxt.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTxt   { priceTxt.becomeFirstResponder()       }
        if textField == priceTxt   { squareMtTxt.becomeFirstResponder() }
        if textField == squareMtTxt   { descriptionTxt.becomeFirstResponder() }
        if textField == addressTxt { detailsTxt.becomeFirstResponder()     }
        
        return true
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
