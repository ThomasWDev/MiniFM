//
//  MFAboutViewController.swift
//  Minifm
//
//  Created by Thomas on 2/14/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit

class MFAboutViewController: MFBaseViewController {

    @IBOutlet weak var webView: UIWebView!
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if index == 0 {
            title = "About"
            if let pdf = Bundle.main.url(forResource: "ABOUT", withExtension: "pdf", subdirectory: nil, localization: nil)  {
                let req = NSURLRequest(url: pdf)
                webView.loadRequest(req as URLRequest)
            }

        } else if index == 1 {
            title = "Privacy Policy"
            if let pdf = Bundle.main.url(forResource: "Mini Fashion Privacy Policy", withExtension: "pdf", subdirectory: nil, localization: nil)  {
                let req = NSURLRequest(url: pdf)
                webView.loadRequest(req as URLRequest)
            }
        } else if index == 2 {
            title = "Terms of Use"
            if let pdf = Bundle.main.url(forResource: "Mini Fashion Terms of Use", withExtension: "pdf", subdirectory: nil, localization: nil)  {
                let req = NSURLRequest(url: pdf)
                webView.loadRequest(req as URLRequest)
            }
        } else if index == 3 {
            title = "Shipping"
            if let pdf = Bundle.main.url(forResource: "shipping", withExtension: "pdf", subdirectory: nil, localization: nil)  {
                let req = NSURLRequest(url: pdf)
                webView.loadRequest(req as URLRequest)
            }
        }
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.backgroundColor = UIColor.white
        webView.scalesPageToFit = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
