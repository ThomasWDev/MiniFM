//
//  Utils.swift
//  Minifm
//
//  Created by Thomas on 1/13/17.
//  Copyright © 2017 TBL. All rights reserved.
//

import UIKit

class Utils: NSObject {

    static func createButtonWithIcon( icon : UIImage) -> UIButton {
        
        let buttonTemplate = UIButton(type: .custom)
        buttonTemplate.setImage(icon, for: .normal)
        buttonTemplate.frame = CGRect(x: 0, y: 0, width: 36, height: 36)
        return buttonTemplate
        
    }
    
}
