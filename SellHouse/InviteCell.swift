//
//  InviteCell.swift
//  Minifm
//
//  Created by Thomas on 7/3/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import Contacts

class InviteCell: UITableViewCell {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    var currentCNContact : CNContact?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width/2
        avatarImageView.backgroundColor = UIColor.darkGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bind(contact : CNContact) {
        
        currentCNContact = contact
        nameLabel.text = "\(contact.givenName) \(contact.familyName)"
        if let email = contact.emailAddresses.first?.value as String? {
            addressLabel.text = email
        } else if let phone = contact.phoneNumbers.first?.value as CNPhoneNumber? {
            addressLabel.text = phone.stringValue
        }
        
        if contact.imageDataAvailable {
            avatarImageView.image = UIImage(data: contact.thumbnailImageData!)
        } else {
            avatarImageView.image = nil
        }
        
    }
    
    //MARK: Actions
    
    @IBAction func onDetailClicked(_ sender: Any) {
        
    }
    

}
