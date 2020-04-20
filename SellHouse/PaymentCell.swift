//
//  PaymentCell.swift
//  Minifm
//
//  Created by Thomas on 7/6/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit

class PaymentCell: UITableViewCell {

    @IBOutlet weak var addPaymentMethodButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addPaymentMethodButton.layer.masksToBounds = true
        addPaymentMethodButton.layer.borderColor = UIColor.red.cgColor
        addPaymentMethodButton.layer.borderWidth = 1
        addPaymentMethodButton.layer.cornerRadius = addPaymentMethodButton.frame.height/2
        addPaymentMethodButton.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func onAddPaymentClicked(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddPaymentMethod"), object: nil)
    }
}
