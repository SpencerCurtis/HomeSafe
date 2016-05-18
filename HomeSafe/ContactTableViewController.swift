//
//  ContactTableViewController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit
import Contacts
import CoreLocation

class ContactTableViewController: UITableViewController {
    
    static let sharedController = ContactTableViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UserController.sharedController.currentUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let pageViewController = storyboard.instantiateViewControllerWithIdentifier("CreateUserViewController")
            self.presentViewController(pageViewController, animated: true, completion: nil)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func addContactButtonTapped(sender: AnyObject) {
        requestForAccess { (accessGranted) in
            if accessGranted {
                guard let selectContacts = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("selectContacts") as? SelectContactTableViewController else {return}
                self.presentViewController(selectContacts, animated: true, completion: {
                    self.tableView.reloadData()
                })
                
                let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let containerID = CNContactStore().defaultContainerIdentifier()
                let predicate: NSPredicate = CNContact.predicateForContactsInContainerWithIdentifier(containerID)
                do {
                    
                    selectContacts.userContacts = try CNContactStore().unifiedContactsMatchingPredicate(predicate, keysToFetch: keysToFetch)
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                    
                } catch _ {
                    print("Error getting users contacts")
                }
            }
        }
    }
    func requestForAccess(completionHandler: (accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(.Contacts)
        
        switch authorizationStatus {
        case .Authorized:
            completionHandler(accessGranted: true)
            
        case .Denied, .NotDetermined:
            
            SelectContactTableViewController.sharedInstance.contactStore.requestAccessForEntityType(.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    
                    completionHandler(accessGranted: access)
                }
                else {
                    if authorizationStatus == .Denied {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            SelectContactTableViewController.sharedInstance.showMessage(message)
                            self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    }
                }
            })
        default:
            completionHandler(accessGranted: false)
        }
    }
    
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return SelectContactTableViewController.sharedInstance.selectedFavoriteContactsArray.count
    }
}













