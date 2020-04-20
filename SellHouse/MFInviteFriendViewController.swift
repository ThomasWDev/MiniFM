//
//  MFInviteFriendViewController.swift
//  Minifm
//
//  Created by Thomas on 7/3/17.
//  Copyright © 2017 TBL Technerds. All rights reserved.
//

import UIKit
import Contacts
import MessageUI

class MFInviteFriendViewController: MFBaseViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var friends = [CNContact]()
    var searchFriend = [CNContact]()
    var isSearching = false
    let store = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchingContacts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func initializeStyle() {
        title =  "Friends"
        searchBar.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
        let menuButton = Utils.createButtonWithIcon(icon: UIImage(named: "ic_menu")!)
        menuButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        menuButton.addTarget(self, action: #selector(onMenuClicked(_:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchFriend.removeAll()
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            isSearching = false
        } else {
            isSearching = true
            searchFriend.removeAll()
            for contact in friends {
                let fullname = "\(contact.givenName) \(contact.familyName)"
                var phoneValue = ""
                var emailValue  = ""
                if let email = contact.emailAddresses.first?.value as String? {
                    emailValue = email
                } else if let phone = contact.phoneNumbers.first?.value as CNPhoneNumber? {
                    phoneValue = phone.stringValue
                }
                if  fullname.uppercased().contains(searchText.uppercased()) ||
                    emailValue.uppercased().contains(searchText.uppercased()) ||
                    phoneValue.uppercased().contains(searchText.uppercased()) {
                    searchFriend.append(contact)
                }
                
            }
        }
        
        tableView.reloadData()
    }
    
    //MARK: Actions
    
    @IBAction override func onMenuClicked(_ sender: Any) {
        slideMenuController()?.openLeft()
    }
    
    //MARK: Helper methods
    
    func fetchingContacts() {
        
        
        if CNContactStore.authorizationStatus(for: .contacts) == .notDetermined {
            store.requestAccess(for: .contacts, completionHandler: { (authorized, error) in
                if authorized {
                    self.retrieveContactsWithStore(store: self.store)
                }
            })
        } else if CNContactStore.authorizationStatus(for: .contacts) == .authorized {
            self.retrieveContactsWithStore(store: store)
        }
    }
    
    func retrieveContactsWithStore(store: CNContactStore) {
        
        
        let keys = [CNContactGivenNameKey ,CNContactImageDataKey,CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactFamilyNameKey, CNContactImageDataAvailableKey,CNContactThumbnailImageDataKey]
        let fetchRequest = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        fetchRequest.sortOrder = CNContactSortOrder.userDefault
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock: { ( contact, stop) -> Void in
                self.friends.append(contact)
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        isSearching = false
        self.tableView.reloadData()
    }

}

extension MFInviteFriendViewController : UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching == true {
            if searchFriend.count == 0 {
                return 1
            }
            return searchFriend.count
        }
        if friends.count == 0 {
            return 1
        }
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearching == true {
            if searchFriend.count == 0 {
                return tableView.dequeueReusableCell(withIdentifier: "EmptyCell")!
            }
        }
        if friends.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "EmptyCell")!
        }
        let inviteCell = tableView.dequeueReusableCell(withIdentifier: "InviteCell") as! InviteCell
        
        inviteCell.bind(contact: isSearching == true ? searchFriend[indexPath.row] : friends[indexPath.row])
        return inviteCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if friends.count == 0 {
            return 186
        }
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (MFMessageComposeViewController.canSendText()) {
            var contact : CNContact?
            if isSearching == true {
                contact = searchFriend[indexPath.row]
            } else {
                contact = friends[indexPath.row]
            }
            
            if let phone = contact?.phoneNumbers.first?.value as CNPhoneNumber? {
                let controller = MFMessageComposeViewController()
                controller.body = "Checkout this app from the link https://minifm.com"
                controller.recipients = [phone.stringValue]
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
