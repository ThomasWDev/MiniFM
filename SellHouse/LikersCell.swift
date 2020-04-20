//
//  LikersCell.swift
//  Minifm
//
//  Created by Thomas on 3/1/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import Parse

class LikersCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var model : PFObject? {
        didSet {
            
            bind(model: model!)
        }
    }
    
    func bind( model : PFObject ) {
        let user = model[ACTIVITY_FAVES_BY_USER] as! PFUser
        let fullname = user[USER_FULLNAME] as? String
        if  fullname != nil && fullname! != "" {
            nameLabel.text = fullname
        } else {
            nameLabel.text = "Unknown"
        }
        
        let file = user[USER_AVATAR] as? PFFile
        file?.getDataInBackground { (data, error) in
            if data != nil {
                let image = UIImage(data: data!)
                self.avatarImageView.setBackgroundImage(image, for: .normal)
            }
        }
    }

}
