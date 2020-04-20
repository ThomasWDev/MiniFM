//
//  MFPdfReaderViewController.swift
//  Minifm
//
//  Created by Thomas on 7/10/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit

class MFPdfReaderViewController: MFBaseViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let pdf = Bundle.main.url(forResource: "shipping", withExtension: "pdf", subdirectory: nil, localization: nil)  {
            let req = NSURLRequest(url: pdf)
            webView.loadRequest(req as URLRequest)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func initializeStyle() {
        super.initializeStyle()
        title = "Shipping Info"
    }

}
