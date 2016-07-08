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
import MessageUI

// THIS IS THE FIRST VIEW CONTROLLER PRESENTED WHEN OPENING THE APP.

class ContactTableViewController: UITableViewController, PassContactsDelegate, PassSearchedContactsDelegate, MFMessageComposeViewControllerDelegate {
    
    func userDidSelectContacts(contacts: [CNContact]) {
        UserController.sharedController.selectedArray = contacts
    }
    
    func userDidSelectSearchedContacts(contacts: [CNContact]) {
        UserController.sharedController.selectedArray = contacts
    }
    
    
    static let sharedController = ContactTableViewController()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sendInvitationMessage), name: "noContactFound", object: nil)
        AppearanceController.sharedController.gradientBackgroundForTableViewController(self)
        AppearanceController.sharedController.initializeAppearance()
        hideTransparentNavigationBar()
        UserController.sharedController.currentUser
        if UserController.sharedController.currentUser == nil {
            
            let createUserVC = self.storyboard?.instantiateViewControllerWithIdentifier("CreateUserViewController")
            self.presentViewController(createUserVC!, animated: false, completion: nil)
            //            if NSUserDefaults.standardUserDefaults().valueForKey("newContact") as? String == "newContact" {
            //                if let currentUser = UserController.sharedController.currentUser {
            //                                    CloudKitController.sharedController.checkForNewContacts(
            //                }
            //            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(tableView.reloadData), name: "reloadTableView", object: nil)
        
        self.tableView.allowsMultipleSelection = true
    }
    
    func hideTransparentNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.translucent = true
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        
    }
    
    func sendInvitationMessage() {
        
        let recipients = NSUserDefaults.standardUserDefaults().objectForKey("contactsForSMS") as? [String]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            AppearanceController.sharedController.intitializeAppearanceForMFMessageController()
            let messageVC = MFMessageComposeViewController()
            if MFMessageComposeViewController.canSendText() == true {
                
                let alert = UIAlertController(title: nil, message: "Would you like to invite this person to download HomeSafe so they can be your follower?", preferredStyle: .Alert)
                let yesAction = UIAlertAction(title: "Yes", style: .Default, handler: { (action) in
                    messageVC.body = "I'd like you to download HomeSafe so you can make sure I'm safe while I'm out!"
                    messageVC.recipients = recipients
                    messageVC.messageComposeDelegate = self
                    messageVC.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
                    //                    messageVC.navigationBar.translucent = false // TODO: - GET THE NAVBAR TO FREAKING BE SOLID.
                    self.presentViewController(messageVC, animated: true, completion: {
                        alert.view.tintColor = Colors.sharedController.exoticGreen    
                    })
                    
                    
                })
                let noAction = UIAlertAction(title: "No", style: .Destructive, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(noAction)
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                NotificationController.sharedController.simpleAlert("Cannot send SMS", message: "Your device does not support sending SMS messages")
            }
            
        })
        
    }
    
    @objc func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            AppearanceController.sharedController.initializeAppearance()
        })
        
        self.becomeFirstResponder()
    }
    
    
    
    @IBAction func settingsButtonTapped(sender: AnyObject) {
        
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let contactsAction = UIAlertAction(title: "Add a new follower", style: .Default) { (_) in
            self.requestForAccess { (accessGranted) in
                if accessGranted {
                    guard let selectContactsNavController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("navController") as? UINavigationController,                                let selectContacts = selectContactsNavController.viewControllers[0] as? SelectContactTableViewController else {return}
                    selectContacts.delegate = self
                    self.presentViewController(selectContactsNavController, animated: true, completion: {
                        self.tableView.reloadData()
                        alert.view.tintColor = Colors.sharedController.exoticGreen
                        
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
        
        let signOutAction = UIAlertAction(title: "Sign Out", style: .Destructive) { (_) in
            UserController.sharedController.signOutCurrentUser()
            
            let createUserVC = self.storyboard?.instantiateViewControllerWithIdentifier("CreateUserViewController")
            self.presentViewController(createUserVC!, animated: false, completion: nil)
            
        }
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil)
        
        alert.addAction(contactsAction)
        alert.addAction(signOutAction)
        alert.addAction(dismissAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    func requestForAccess(completionHandler: (accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(.Contacts)
        
        switch authorizationStatus {
        case .Authorized:
            completionHandler(accessGranted: true)
            
        case .Denied, .NotDetermined:
            
            SelectContactTableViewController.sharedController.contactStore.requestAccessForEntityType(.Contacts, completionHandler: { (access, accessError) -> Void in
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
        presentViewController(alert, animated: true, completion: {
            alert.view.tintColor = Colors.sharedController.exoticGreen
        })
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
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.tintColor = UIColor.whiteColor()
        
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
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let names = ContactsController.sharedController.contacts.map({$0.name!})
        NSUserDefaults.standardUserDefaults().setValue(names, forKey: "currentFollowers")
    }
}










