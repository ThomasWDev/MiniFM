//
//  MFSelectorViewController.swift
//  Minifm
//
//  Created by Thomas on 2/27/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
//import RxCocoa
import RxSwift

class MFSelectorViewController: UITableViewController {

    var rx_selection = Variable<String?>(nil)
    var selectorType = Enum.SelectorSellType.category
    //For size
    var selectorSizeValue = ""
    fileprivate var selectorArray = [String]()
    fileprivate var categoryDic : NSDictionary?
    fileprivate var selectionValue : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeStyle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectorArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.textLabel?.text = selectorArray[indexPath.row]
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectionValue = selectorArray[indexPath.row]
        
    }
    
    //MARK: Actions
    
    @IBAction func onCancelClicked(_ sender: Any) {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func onApplyClicked(_ sender: Any) {
        
         rx_selection.value = selectionValue
        self.navigationController!.popViewController(animated: true)
        
    }
    
    //MARK: Helper methods
    
    func initializeStyle() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(onCancelClicked(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Apply", style: .plain, target: self, action: #selector(onApplyClicked(_:)))
        tableView.tableFooterView = UIView()
        switch selectorType {
        case .category:
            title = "Category"
        case .size:
            title = "Sizes"
        case .brand:
            title = "Brands"
        default:
            title = ""
        }
        loadDataFromPlist(type: selectorType)
    }
    
    func loadDataFromPlist(type : Enum.SelectorSellType) {
        var myDict: NSDictionary?
        var nameOfPlist = ""
        switch selectorType {
        case .category, .size:
            nameOfPlist = "category"
            if let path = Bundle.main.path(forResource: nameOfPlist, ofType: "plist") {
                myDict = NSDictionary(contentsOfFile: path)
            }
            if selectorSizeValue == "" && selectorType == .category {
                if let dict = myDict {
                    categoryDic = dict
                    selectorArray = categoryDic?.allKeys as! [String]
                    selectorArray = selectorArray.sorted(by: { $0 < $1 })
                    selectorArray.append("Other")
                }
            } else {
                if let dict = myDict {
                    categoryDic = dict
                    if let array = categoryDic?.object(forKey: selectorSizeValue) {
                        selectorArray =  array as! [String]
                    }
                }
            }
            tableView.reloadData()
        case .brand:
            nameOfPlist = "brand"
            var myBrands : [String]?
            if let path = Bundle.main.path(forResource: nameOfPlist, ofType: "plist") {
                myBrands = NSArray(contentsOfFile: path) as! [String]?
            }
            if let brands = myBrands {
                selectorArray = brands.sorted(by: { $0 < $1 })
                tableView.reloadData()
            }
        case .condition:
            nameOfPlist = "condition"
            var myConditions : [String]?
            if let path = Bundle.main.path(forResource: nameOfPlist, ofType: "plist") {
                myConditions = NSArray(contentsOfFile: path) as! [String]?
            }
            if let conditions = myConditions {
                selectorArray = conditions.sorted(by: { $0 < $1 })
                tableView.reloadData()
            }
        }
    }

}
