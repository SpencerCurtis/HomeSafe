//
//  SelectContactTableViewController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit
import Contacts
import CloudKit

protocol PassContactsDelegate {
    func userDidSelectContacts(contacts: [CNContact])
}

class SelectContactTableViewController: UITableViewController {
    
    var delegate: PassContactsDelegate?
    var userContacts = [CNContact]() // dataArray
    var contactStore = CNContactStore()
    var favoriteContacts: [CNContact] = []
    var selectedFavoriteContactsArray: [CNContact] = []
    var tempContacts: [User] = []
    
    var searchController: UISearchController!
    @IBOutlet weak var manualPhoneNumberTextField: UITextField!
    
    func configureSearchController() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("results") as? ResultsTableViewController {
            
            searchController = UISearchController(searchResultsController: vc)
            vc.searchController = searchController
            vc.results = userContacts
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Search for followers"
            searchController.searchBar.sizeToFit()
            //            searchController.searchBar.backgroundImage = UIImage()
            navigationController?.navigationBar.barTintColor = UIColor(red: 0.298, green: 0.749, blue: 0.035, alpha: 1.00)
            searchController.searchBar.barTintColor = UIColor(red: 0.298, green: 0.749, blue: 0.035, alpha: 1.00)
            tableView.tableHeaderView = searchController.searchBar
            searchController.searchBar.tintColor = UIColor(red: 0.298, green: 0.749, blue: 0.035, alpha: 1.00)
            tableView.backgroundColor = UIColor.clearColor()
        }
        
        
    }
    
    
    static let sharedController = SelectContactTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.286, green: 0.749, blue: 0.063, alpha: 1.00)
        self.tableView.allowsMultipleSelection = true
        configureSearchController()
        AppearanceController.sharedController.gradientBackgroundForTableViewController(self)
        
    }
    
    @IBAction func done(sender: AnyObject) {
        var contactsNotInICloud: [String] = []
        self.dismissViewControllerAnimated(true, completion: nil)
        guard let currentUser = UserController.sharedController.currentUser else { return }
        contactsToPhoneNumber(UserController.sharedController.selectedArray, completion: { (phoneNumbers) in
            CloudKitController.sharedController.addUsersToContactList(currentUser, phoneNumbers: phoneNumbers, completion: { (success) in
                
            })
        })
    }
    
    
    
    func plainPhoneNumber(string: String) -> String {
        let filter = NSCharacterSet.alphanumericCharacterSet()
        let result = String(string.utf16.filter { filter.characterIsMember($0) }.map { Character(UnicodeScalar($0)) })
        
        return result
    }
    
    
    func contactsToPhoneNumber(contacts: [CNContact], completion: (phoneNumbers: [String]) -> Void) {
        var phoneNumbers: [String] = []
        for contact in contacts {
            if contact.phoneNumbers != [] {
                let value = contact.phoneNumbers.first?.value as! CNPhoneNumber
                let string = value.stringValue
                let phoneNumber = plainPhoneNumber(string)
                phoneNumbers.append(phoneNumber)
            }
        }
        completion(phoneNumbers: phoneNumbers)
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userContacts.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath)
        let contact = userContacts[indexPath.row]
        cell.selectionStyle = .None
        cell.textLabel?.text = contact.givenName + " " + contact.familyName
        cell.tintColor = UIColor.whiteColor()
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
        let selectedContacts = userContacts[indexPath.row]
        UserController.sharedController.selectedArray.append(selectedContacts)
    }
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
        let index = UserController.sharedController.selectedArray.indexOf(userContacts[indexPath.row])
        UserController.sharedController.selectedArray.removeAtIndex(index!)
    }
}






