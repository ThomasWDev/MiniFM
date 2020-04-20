//
//  Configs.swift
//  Minifm
//
//  Created by Thomas on 18/03/16.
//  Copyright © 2016 GF. All rights reserved.
//


import UIKit

class TermsOfUse: UIViewController {

    @IBOutlet var webView: UIWebView!
    
    
   
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Top Navigation
    navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
    navigationController?.navigationBar.tintColor = UIColor.white
    
    let url = Bundle.main.url(forResource: "terms", withExtension: "html")
    webView.loadRequest(URLRequest(url: url!))
    
    // Set ComposeMail Navigation Colors
    UIBarButtonItem.appearance().tintColor = UIColor.white
   
}

    
    
// Dismiss Button
@IBAction func dismissButt(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
}
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
