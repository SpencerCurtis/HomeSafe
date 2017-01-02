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
    
    func userDidSelectContacts(_ contacts: [CNContact]) {
        UserController.sharedController.selectedArray = contacts
    }
    
    func userDidSelectSearchedContacts(_ contacts: [CNContact]) {
        UserController.sharedController.selectedArray = contacts
    }
    
    
    static let sharedController = ContactTableViewController()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsMultipleSelection = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(sendInvitationMessage), name: NSNotification.Name(rawValue: "noContactFound"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(tableView.reloadData), name: NSNotification.Name(rawValue: "reloadTableView"), object: nil)
        
        AppearanceController.sharedController.gradientBackgroundForTableViewController(self)
        AppearanceController.sharedController.initializeAppearance()
        hideTransparentNavigationBar()
        
        if UserController.sharedController.currentUser == nil {
            
            let createUserVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateUserViewController")
            self.present(createUserVC!, animated: false, completion: nil)
        }
        DispatchQueue.main.async(execute: { () -> Void in
            guard let image = UIImage(named: "HomeSafeNavBarIconOnly.png") else { return }
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            self.navigationItem.titleView = imageView
        })
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ContactsController.sharedController.contacts.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        let favoriteContact = ContactsController.sharedController.contacts[indexPath.row]
        
        cell.selectionStyle = .none
        cell.textLabel?.text = favoriteContact.name
        cell.textLabel?.textColor = UIColor.white
        cell.tintColor = UIColor.white
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let contact = ContactsController.sharedController.contacts[indexPath.row]
            ContactsController.sharedController.removeContact(contact)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        let selectedGuardians = ContactsController.sharedController.contacts[indexPath.row]
        ContactsController.sharedController.selectedGuardians.append(selectedGuardians)
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
        let index = ContactsController.sharedController.selectedGuardians.index(of: ContactsController.sharedController.contacts[indexPath.row])
        ContactsController.sharedController.selectedGuardians.remove(at: index!)
    }
    
    
    func hideTransparentNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = UIColor.clear
    }
    
    func sendInvitationMessage() {
        
        let recipients = UserDefaults.standard.object(forKey: "contactsForSMS") as? [String]
        DispatchQueue.main.async(execute: { () -> Void in
            AppearanceController.sharedController.intitializeAppearanceForMFMessageController()
            let messageVC = MFMessageComposeViewController()
            if MFMessageComposeViewController.canSendText() == true {
                
                let alert = UIAlertController(title: "No user found", message: "Would you like to invite this person to download HomeSafe so they can be your follower?", preferredStyle: .alert)
                let yesAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    messageVC.body = "I'd like you to download HomeSafe so you can make sure I'm safe while I'm out!"
                    messageVC.recipients = recipients
                    messageVC.messageComposeDelegate = self
                    messageVC.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
                    //                    messageVC.navigationBar.translucent = false // TODO: - GET THE NAVBAR TO FREAKING BE SOLID.
                    self.present(messageVC, animated: true, completion: {
                        alert.view.tintColor = Colors.sharedColors.exoticGreen
                    })
                    
                    
                })
                let noAction = UIAlertAction(title: "No", style: .destructive, handler: nil)
                alert.addAction(yesAction)
                alert.addAction(noAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = NotificationController.sharedController.simpleAlert("Cannot send SMS", message: "Your device does not support sending SMS messages")
                self.present(alert, animated: true, completion: nil)
            }
            
        })
        
    }
    
    @objc func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async(execute: { () -> Void in
            AppearanceController.sharedController.initializeAppearance()
        })
        
        self.becomeFirstResponder()
    }
    
    
    
    @IBAction func settingsButtonTapped(_ sender: AnyObject) {
        
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor(red: 0.314, green: 0.749, blue: 0.000, alpha: 1.00)
        
        
        let contactsAction = UIAlertAction(title: "Add a new follower", style: .default) { (_) in
            self.requestForAccess { (accessGranted) in
                if accessGranted {
                    guard let selectContactsNavController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "navController") as? UINavigationController,                                let selectContacts = selectContactsNavController.viewControllers[0] as? SelectContactTableViewController else {return}
                    selectContacts.delegate = self
                    self.present(selectContactsNavController, animated: true, completion: {
                        self.tableView.reloadData()
                        alert.view.tintColor = Colors.sharedColors.exoticGreen
                        
                    })
                    
                    
                }
            }
        }
        
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { (_) in
            UserController.sharedController.signOutCurrentUser()
            guard let createUserVC = self.storyboard?.instantiateViewController(withIdentifier: "CreateUserViewController") else { return }
            self.present(createUserVC, animated: false, completion: nil)
            
        }
        
        let manualEntryAction = UIAlertAction(title: "Enter a phone number manually", style: .default) { (_) in
            
            var phoneNumberTextField: UITextField?
            
            let alert = UIAlertController(title: "Search for a user", message: "Please enter the other user's phone number", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Enter a phone number:"
                textField.keyboardType = .numberPad
                
                phoneNumberTextField = textField
            })
            
            let submitAction = UIAlertAction(title: "Submit", style: .cancel, handler: { (_) in
                DispatchQueue.main.async(execute: { () -> Void in
                    let loadingView = UIView()
                    loadingView.frame = self.view.bounds
                    loadingView.alpha = 0.2
                    loadingView.backgroundColor = UIColor.gray
                    self.view.addSubview(loadingView)
                    self.view.bringSubview(toFront: loadingView)
                    
                    let indicator:UIActivityIndicatorView = UIActivityIndicatorView  (activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
                    indicator.color = UIColor.white
                    indicator.frame = CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)
                    indicator.center = CGPoint(x: self.view.center.x, y: 256)
                    indicator.hidesWhenStopped = true
                    
                    
                    self.view.addSubview(indicator)
                    self.view.bringSubview(toFront: indicator)
                    
                    
                    indicator.startAnimating()
                    
                    
                    guard let phoneNumber = phoneNumberTextField!.text, let currentUser = UserController.sharedController.currentUser else { indicator.stopAnimating(); loadingView.removeFromSuperview();                         NotificationCenter.default.post(name: Notification.Name(rawValue: "noContactFound"), object: nil); return }
                    CloudKitController.sharedController.addUsersToContactList(currentUser, phoneNumbers: [phoneNumber], completion: { (success) in
                        DispatchQueue.main.async(execute: { () -> Void in
                            indicator.stopAnimating()
                            loadingView.removeFromSuperview()
                            self.tableView.reloadData()
                        })
                    })
                })
            })
            
            let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
            
            alert.addAction(submitAction)
            alert.addAction(dismissAction)
            
            
            
            
            //            let manualVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("manualVC")
            self.present(alert, animated: true, completion: nil)
        }
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
        
        alert.addAction(contactsAction)
        alert.addAction(manualEntryAction)
        alert.addAction(signOutAction)
        alert.addAction(dismissAction)
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func requestForAccess(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined:
            
            SelectContactTableViewController.sharedController.contactStore.requestAccess(for: .contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access)
                } else {
                    if authorizationStatus == .denied {
                        DispatchQueue.main.async(execute: { () -> Void in
                            let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                            self.showMessage(message)
                            self.dismiss(animated: true, completion: nil)
                        })
                    }
                }
            })
        default:
            completionHandler(false)
        } 
    }
    
    func showMessage(_ message: String) {
        let alert = UIAlertController(title: "My Contacts", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: {
            alert.view.tintColor = Colors.sharedColors.exoticGreen
        })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let names = ContactsController.sharedController.selectedGuardians.map({$0.name!})
        UserDefaults.standard.setValue(names, forKey: "currentFollowers")
    }
}










