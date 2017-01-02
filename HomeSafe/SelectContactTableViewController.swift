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
    func userDidSelectContacts(_ contacts: [CNContact])
}

class SelectContactTableViewController: UITableViewController {
    
    var delegate: PassContactsDelegate?
    var contactStore = CNContactStore()
    var favoriteContacts: [CNContact] = []
    var selectedFavoriteContactsArray: [CNContact] = []
    var tempContacts: [User] = []
    
    lazy var contacts: [CNContact] = {
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactEmailAddressesKey,
            CNContactPhoneNumbersKey,
            CNContactImageDataAvailableKey,
            CNContactThumbnailImageDataKey] as [Any]
        
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
    }()
    
    
    var searchController: UISearchController!
    @IBOutlet weak var manualPhoneNumberTextField: UITextField!
    
    func configureSearchController() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "results") as? ResultsTableViewController {
            
            searchController = UISearchController(searchResultsController: vc)
            vc.searchController = searchController
            vc.results = contacts
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Search for followers"
            searchController.searchBar.sizeToFit()
            //            searchController.searchBar.backgroundImage = UIImage()
            navigationController?.navigationBar.barTintColor = UIColor(red: 0.298, green: 0.749, blue: 0.035, alpha: 1.00)
            searchController.searchBar.barTintColor = UIColor(red: 0.298, green: 0.749, blue: 0.035, alpha: 1.00)
            tableView.tableHeaderView = searchController.searchBar
            searchController.searchBar.tintColor = UIColor(red: 0.298, green: 0.749, blue: 0.035, alpha: 1.00)
            tableView.backgroundColor = UIColor.clear
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
    
    @IBAction func done(_ sender: AnyObject) {
        let indicator = AppearanceController.sharedController.setUpActivityIndicator(self)
        self.view.addSubview(indicator)
        self.view.bringSubview(toFront: indicator)
        indicator.startAnimating()
        
        guard let currentUser = UserController.sharedController.currentUser else { return }
        guard UserController.sharedController.selectedArray.count > 1 else { indicator.stopAnimating(); self.dismiss(animated: true, completion: nil); return }
        contactsToPhoneNumber(UserController.sharedController.selectedArray, completion: { (phoneNumbers) in
            CloudKitController.sharedController.addUsersToContactList(currentUser, phoneNumbers: phoneNumbers, completion: { (success) in
                UserController.sharedController.selectedArray = []
                indicator.stopAnimating()
                self.dismiss(animated: true, completion: nil)
                
            })
        })
    }
    
    
    
    func plainPhoneNumber(_ string: String) -> String {
        let filter = CharacterSet.alphanumerics
        let result = String(string.utf16.filter { filter.contains(UnicodeScalar($0)!) }.map { Character(UnicodeScalar($0)!) })
        
        return result
    }
    
    
    func contactsToPhoneNumber(_ contacts: [CNContact], completion: (_ phoneNumbers: [String]) -> Void) {
        var phoneNumbers: [String] = []
        for contact in contacts {
            if contact.phoneNumbers != [] {
                guard let firstPhoneNumber = contact.phoneNumbers.first else { return }
                
                let phoneNum = firstPhoneNumber.value.stringValue
                
                let phoneNumber = plainPhoneNumber(phoneNum)
                phoneNumbers.append(phoneNumber)
            }
        }
        completion(phoneNumbers)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async(execute: { () -> Void in
            self.tableView.reloadData()
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        let contact = contacts[indexPath.row]
        cell.selectionStyle = .none
        cell.textLabel?.text = contact.givenName + " " + contact.familyName
        cell.tintColor = UIColor.white
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        let selectedContacts = contacts[indexPath.row]
        UserController.sharedController.selectedArray.append(selectedContacts)
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
        let index = UserController.sharedController.selectedArray.index(of: contacts[indexPath.row])
        UserController.sharedController.selectedArray.remove(at: index!)
    }
}






