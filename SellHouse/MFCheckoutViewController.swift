//
//  MFCheckoutViewController.swift
//  Minifm
//
//  Created by Thomas on 7/5/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import Parse

class MFCheckoutViewController: MFBaseViewController, PayPalPaymentDelegate {

    @IBOutlet weak var tableView: UITableView!
    var checkoutItems = NSMutableArray()
    var payPalConfig = PayPalConfiguration() // default
    var currentShoppingObject : PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func initializeStyle() {
        super.initializeStyle()
        title = "Checkout"
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        checkoutItems.add("PaymentCell")
        NotificationCenter.default.addObserver(self, selector: #selector(addPaymentMethod(notification:)), name: NSNotification.Name(rawValue: "AddPaymentMethod"), object: nil)
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = true
        payPalConfig.merchantName = "Minifm"
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        
        payPalConfig.payPalShippingAddressOption = .payPal;
    }
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        self.currentShoppingObject?.deleteInBackground(block: { (success, error) in
            if success == true {
                DispatchQueue.main.async {
                    self.checkoutItems.removeAllObjects()
                    self.tableView.reloadData()
                }
            }
            
        })
        paymentViewController.dismiss(animated: false, completion: { () -> Void in
            self.showMessage(message: "You've purchased successfully.")
            
        })
    }

    
    func addPaymentMethod(notification : Notification) {
        
        currentShoppingObject = checkoutItems.firstObject as? PFObject
        IndicatorManager.shared.startIndicatorAnimation(inview: self.view)
        let query = PFQuery(className: LISTING_CLASS_NAME)
        query.whereKey("objectId", equalTo: currentShoppingObject![SHOPPING_CART_LISTING_ID])
        query.includeKey(LISTING_PRODUCT_OWNER)
        query.getFirstObjectInBackground { (object, error) in
            IndicatorManager.shared.stopIndicatorAnimation(inview: self.view)
            if object != nil {
                let description = "\(object![LISTING_PRODUCT_TITLE] as? String ?? "") \(object![LISTING_PRODUCT_DESCRIPTION] ?? "")"
                let item1 = PayPalItem(name: "\(object![LISTING_PRODUCT_TITLE] as? String ?? "") \(object![LISTING_PRODUCT_DESCRIPTION] ?? "")", withQuantity: 1, withPrice: NSDecimalNumber(string: String(describing: object![LISTING_PRODUCT_LISTING_PRICE]!)), withCurrency: "USD", withSku: "Minifm-\(NSUUID().uuidString)")
                
                let items = [item1]
                let subtotal = PayPalItem.totalPrice(forItems: items)
                let total = subtotal
                let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: description, intent: .sale)
                
                payment.items = items
                
                if (payment.processable) {
                    let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: self.payPalConfig, delegate: self)
                    self.present(paymentViewController!, animated: true, completion: nil)
                }
                else {
                    print("Payment not processalbe: \(payment)")
                }
            }
        }
    }
    

}

extension MFCheckoutViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkoutItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if checkoutItems.count - 1 == indexPath.row {
            let paymentCell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell") as! PaymentCell
            return paymentCell
        }
        let checkoutCell = tableView.dequeueReusableCell(withIdentifier: "CheckoutCell") as! CheckoutCell
        checkoutCell.bind(object: checkoutItems[indexPath.row] as! PFObject)
        return checkoutCell
    }
    
}
