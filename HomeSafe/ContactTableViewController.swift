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

class ContactTableViewController: UITableViewController, PassContactsDelegate {
    //*********************//
    //PROTOCOLS FUNCTION
    //*******************//

   func userDidSelectContacts(contacts: [CNContact]) {
        UserController.sharedController.selectedArray = contacts
    }
    //**********************************************************************************************************//
    //SHARED CONTROLLER. SELECTED CONTACTS ARRAY. VIEW DID LOAD IF USER WAS CREATED. SHOW VIEW. RELOAD TABLEVIEW.
    //**********************************************************************************************************//

    static let sharedController = ContactTableViewController()
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadTableView), name: "reloadTableView", object: nil)
        if UserController.sharedController.currentUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let pageViewController = storyboard.instantiateViewControllerWithIdentifier("CreateUserViewController")
            self.presentViewController(pageViewController, animated: true, completion: nil)
        }
        self.tableView.allowsMultipleSelection = true
    }
    
    override func viewWillAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })
    }

    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    
    //************************************************************//
    // MARK: - Calling Request for access Function.//
    //IF ACCESS IS GRANTED, PROCEED. IF NOT, DO NOT PRESENT MODALLY
    //************************************************************//
    
    @IBAction func addContactButtonTapped(sender: AnyObject) {
        requestForAccess { (accessGranted) in
            if accessGranted {
                guard let selectContactsNavController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("navController") as? UINavigationController,                 let selectContacts = selectContactsNavController.viewControllers[0] as? SelectContactTableViewController else {return}
                selectContacts.delegate = self
                self.presentViewController(selectContactsNavController, animated: true, completion: {
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
    
    //*********************************************************************************//
    // MARK: - Request For Access Function//
    // CHECKS PERMISSION, IF GRANTED, PROCCEED. IF NOT, DO NOT. MUST CHANGE IN SETTINGS.
    //*********************************************************************************//
    
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
                            self.showMessage(message)
                            self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    }
                }
            })
        default:
            completionHandler(accessGranted: false)
        }
    }
    
    func showMessage(message: String) {
        let alert = UIAlertController(title: "My Contacts", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }

    //*****************************//
    //MARK: - TABLEVIEW DELEGATION CONTACTTABLEVIEWCONTROLLER
    //*******************************************************//

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ContactsController.sharedController.contacts.count
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath)
        let favoriteContact = ContactsController.sharedController.contacts[indexPath.row]
        cell.selectionStyle = .None
        cell.textLabel?.text = favoriteContact.name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {

            let contact = ContactsController.sharedController.contacts[indexPath.row]
            ContactsController.sharedController.removeContact(contact)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
        let selectedGuardians = ContactsController.sharedController.contacts[indexPath.row]
        ContactsController.sharedController.selectedGuardians.append(selectedGuardians)
        
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
        let index = ContactsController.sharedController.selectedGuardians.indexOf(ContactsController.sharedController.contacts[indexPath.row])
        ContactsController.sharedController.selectedGuardians.removeAtIndex(index!)

    }
  
}










