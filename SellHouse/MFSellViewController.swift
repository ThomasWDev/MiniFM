//
//  MFSellViewController.swift
//  Minifm
//
//  Created by Thomas on 2/26/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import RxSwift
//import RxCocoa
import Parse

class MFSellViewController: MFBaseViewController {

    
    @IBOutlet weak var addPhotoView: UIView!
    @IBOutlet weak var femaleView: UIView!
    @IBOutlet weak var maleView: UIView!
    @IBOutlet weak var productTitleTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var brandTextField: UITextField!
    @IBOutlet weak var conditionTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var caculateShipping: UITextField!
    @IBOutlet weak var listingPriceTextField: UITextField!
    @IBOutlet weak var willMakeTextField: UITextField!
    @IBOutlet weak var createListingButton: UIButton!
    fileprivate var selectorType = Enum.SelectorSellType.category
    
    fileprivate var productPhotos = [UIImage]()
    fileprivate var selectionValue : String?
    fileprivate var disposeBag = DisposeBag()
    fileprivate var isFemale = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func initializeStyle() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onCancelClicked(_:)))
        addPhotoView.layer.masksToBounds = true
        addPhotoView.layer.cornerRadius = 4
        addPhotoView.layer.borderWidth = 1
        addPhotoView.layer.borderColor = COLORS.LIGHT_RED_COLOR.cgColor
        femaleView.layer.masksToBounds = true
        femaleView.layer.cornerRadius = 4
        maleView.layer.masksToBounds = true
        maleView.layer.cornerRadius = 4
        productTitleTextField.setLeftPaddingPoints(8)
        listingPriceTextField.setLeftPaddingPoints(8)
        willMakeTextField.setLeftPaddingPoints(8)
        willMakeTextField.isEnabled = false
        listingPriceTextField.delegate = self
        descriptionTextView.delegate = self
        willMakeTextField.backgroundColor = UIColor.gray
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectorController = segue.destination as! MFSelectorViewController
        selectorController.rx_selection.asObservable().subscribe { (selection) in
            
            if let value = selection.element {
                if value != nil && value != "" {
                    
                    self.selectionValue = value
                    switch self.selectorType {
                    case .category:
                        self.categoryTextField.text = value
                    case .size:
                        self.sizeTextField.text = value
                    case .brand:
                        self.brandTextField.text = value
                    default:
                        self.conditionTextField.text = value
                    }
                    
                }
            }
            
        }.addDisposableTo(disposeBag)
        
        if selectorType == Enum.SelectorSellType.size {
            selectorController.selectorSizeValue = self.categoryTextField.text ?? ""
        }
        
        selectorController.selectorType = selectorType
    }
    
    //MARK: Actions
    
    @IBAction func onCancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCreateListingClicked(_ sender: Any) {
        
        if validate() == true {
            showHUD()
            let listingObject = PFObject(className: LISTING_CLASS_NAME)
            listingObject[LISTING_PRODUCT_TITLE] = productTitleTextField.text
            listingObject[LISTING_PRODUCT_GENDER] = (isFemale == true ? "female" : "male")
            listingObject[LISTING_PRODUCT_CATEGORY] = categoryTextField.text
            listingObject[LISTING_PRODUCT_SIZE] = sizeTextField.text
            listingObject[LISTING_PRODUCT_BRAND] = brandTextField.text
            listingObject[LISTING_PRODUCT_CONDITION] = conditionTextField.text
            listingObject[LISTING_PRODUCT_DESCRIPTION] = descriptionTextView.text
            listingObject[LISTING_PRODUCT_CACULATE_SHIPPING] = caculateShipping.text
            listingObject[LISTING_PRODUCT_LISTING_PRICE] = listingPriceTextField.text?.replacingOccurrences(of: "$", with: "")
            listingObject[LISTING_PRODUCT_WILL_MAKE_PRICE] = willMakeTextField.text?.replacingOccurrences(of: "$", with: "")
            listingObject[LISTING_PRODUCT_OWNER] = PFUser.current()
            listingObject[LISTING_PRODUCT_COUNT_PHOTOS] = NSNumber(value: productPhotos.count)
            var i = 0
            for image in productPhotos {
                let udid = NSUUID().uuidString.appending(".png")
                let file = PFFile(name: udid, data: UIImageJPEGRepresentation(image, 0.5)!)
                listingObject["\(LISTING_PRODUCT_PHOTOS)_\(i)"] = file
                i = i + 1
            }
            listingObject.saveInBackground(block: { (success, error) in
                self.hideHUD()
                if success == true {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.simpleAlert((error?.localizedDescription)!)
                }
            })
        }
    }
    
    @IBAction func onPhotosClicked(_ sender: UIButton) {
        
        if sender.tag == 1 {
            showCamera(animated: true)
        } else if sender.tag == 2 { //Female
            femaleView.backgroundColor = COLORS.LIGHT_RED_COLOR
            maleView.backgroundColor = COLORS.LIGHT_GRAY_COLOR
            isFemale = true
        } else { //Male
            femaleView.backgroundColor = COLORS.LIGHT_GRAY_COLOR
            maleView.backgroundColor = COLORS.LIGHT_RED_COLOR
            isFemale = false
        }
    }
    
    @IBAction func onPickerClicked(_ sender: UIButton) {
        selectorType = Enum.SelectorSellType(rawValue: sender.tag)!
        self.performSegue(withIdentifier: "SegueSelectorId", sender: nil)
    }
    
    
    //MARK: Helper methods
    
    func validate() -> Bool {
        if productPhotos.count == 0 {
            simpleAlert("Please add photos.")
            return false
        } else if productTitleTextField.text == "" {
            simpleAlert("Please enter product title.")
            return false
        } else if categoryTextField.text == "" {
            simpleAlert("Please select a category.")
            return false
        } else if descriptionTextView.text == "" {
            simpleAlert("Please enter description.")
            return false
        }
        return true
    }
    
    func showCamera (animated : Bool) {
        
        let cameraController : FusumaViewController = FusumaViewController(nibName: "FusumaViewController", bundle: nil)
        cameraController.delegate = self
        let nav = UINavigationController(rootViewController: cameraController)
        nav.isNavigationBarHidden = true
        self.present(nav, animated: animated, completion: nil)
        
    }

}

extension MFSellViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.isEqual(listingPriceTextField) {
            if listingPriceTextField.text != "" {
                let youmakePrice =  Double(listingPriceTextField.text!)! * 0.82
                willMakeTextField.text = "$\(youmakePrice.roundTo(places: 3))"
                let listPrice =  Double(listingPriceTextField.text!)!
                listingPriceTextField.text = "$\(listPrice.roundTo(places: 3))"
            } else {
                listingPriceTextField.text = "$0.00"
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = ""
        return true
    }
}

extension MFSellViewController : UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        textView.text = ""
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Description here"
        }
    }
}

extension Double {
    
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.00, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension MFSellViewController : FusumaDelegate {
    
    func fusumaImageSelected(_ image: UIImage) {
        
    }
    
    func fusumaDidSelected(controller: UIViewController, _ image: UIImage) {
        productPhotos.append(image)
        controller.dismiss(animated: true) {
            
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
