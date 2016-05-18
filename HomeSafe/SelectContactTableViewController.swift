//
//  SelectContactTableViewController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit
import Contacts


class SelectContactTableViewController: UITableViewController {
    
    var userContacts = [CNContact]()
    var contactStore = CNContactStore()
    
    static let sharedInstance = SelectContactTableViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsMultipleSelection = true
        
    }
    @IBAction func done(sender: AnyObject) {
        if self.delegate != nil {
            let contacts: [CNContact] = self.selectedFavoriteContactsArray
            self.delegate?.userDidSelectContacts(contacts)
            
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        self.tableView.reloadData()
//        ContactTableViewController.sharedController.tableView.reloadData()
        
        
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
    
    func showMessage(message: String) {
        let alert = UIAlertController(title: "My Contacts", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userContacts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath)
        let contact = userContacts[indexPath.row]
        cell.selectionStyle = .None
        cell.textLabel?.text = contact.givenName + " " + contact.familyName
        
        return cell
    }
    
    var favoriteContacts: [CNContact] = []
    var selectedFavoriteContactsArray: [CNContact] = []
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
        let selectedContacts = userContacts[indexPath.row]
        
        selectedFavoriteContactsArray.append(selectedContacts)
        
        
    }
    
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
        let index = selectedFavoriteContactsArray.indexOf(userContacts[indexPath.row])
        selectedFavoriteContactsArray.removeAtIndex(index!)
        
    }
    var delegate: PassContactsDelegate?
    
}
protocol PassContactsDelegate {
    func userDidSelectContacts(contacts: [CNContact])
}





























