//
//  CommentCell.swift
//  Minifm
//
//  Created by Thomas on 3/1/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import Parse

class CommentCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIButton!
    @IBOutlet weak var commentLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height/2
        self.backgroundColor = UIColor.clear
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
        commentLabel.text = model[COMMENT_CONTENT] as? String
        let userObject = model[COMMENT_BY_USER] as! PFUser
        
        if let file = userObject[USER_AVATAR] as? PFFile {
            
            file.getDataInBackground { (data, error) in
                if data != nil {
                    let image = UIImage(data: data!)
                    self.avatarImageView.setBackgroundImage(image, for: .normal)
                }
            }
        }
        
    }
    
    static func attributeHeightForEntity(message : PFObject, width : CGFloat) -> CGFloat {
        var contentLabel : UILabel!
        
        if contentLabel == nil {
            contentLabel = UILabel(frame: CGRect.zero)
            contentLabel.numberOfLines = 0;
            contentLabel.lineBreakMode = .byWordWrapping
            contentLabel.font = UIFont.systemFont(ofSize: 16)
            contentLabel.width = width
        }
        else {
            contentLabel.frame = CGRect.zero
            contentLabel.width = width
        }
        
        contentLabel.text = message[COMMENT_CONTENT] as? String
        
        var contentSize = contentLabel.sizeThatFits(CGSize(width: width, height: 99999.0))
        if (contentSize.height < 20) {
            contentSize.height = 20;
        }
        return contentSize.height;
    }
    
}
