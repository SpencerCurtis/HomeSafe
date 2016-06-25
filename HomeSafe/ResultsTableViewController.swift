//
//  ResultsTableViewController.swift
//  HomeSafe
//
//  Created by Aaron Eliason on 5/20/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit
import Contacts

protocol PassSearchedContactsDelegate {
    func userDidSelectSearchedContacts(contacts: [CNContact])
}

class ResultsTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {

    var results: [CNContact] = []
    var filteredArray: [CNContact] = []
    var selectedResultsArray: [CNContact] = []
    var shouldShowResults = false
    var searchController: UISearchController!
    var delegate: PassSearchedContactsDelegate?
    
    @IBOutlet weak var doneButton: UIButton!

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        shouldShowResults = true
        filteredArray = []
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        shouldShowResults = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !shouldShowResults {
            shouldShowResults = true
            tableView.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {return}
            self.filteredArray =  results.filter { $0.givenName.lowercaseString.containsString(searchText.lowercaseString) }
            shouldShowResults = true
            tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        tableView.allowsMultipleSelection = true
        doneButton.layer.borderColor = UIColor.whiteColor().CGColor
        doneButton.layer.borderWidth = 0.4

        AppearanceController.sharedController.gradientBackgroundForTableViewController(self)
        
        self.tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    @IBAction func secondDoneButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowResults {
            return filteredArray.count
        } else {
            return results.count
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchedContactCell", forIndexPath: indexPath)
        let contacts = filteredArray.count > 0 ? filteredArray[indexPath.row] : results[indexPath.row]
        if shouldShowResults {
            cell.textLabel?.text = contacts.givenName + " " + contacts.familyName
            cell.selectionStyle = .None
            cell.tintColor = UIColor.whiteColor()
        }
        return cell
     
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
        let selectedContacts = filteredArray[indexPath.row]
        UserController.sharedController.selectedArray.append(selectedContacts)
        print("\n\(UserController.sharedController.selectedArray)\n")
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
        let index = UserController.sharedController.selectedArray.indexOf(filteredArray[indexPath.row])
        UserController.sharedController.selectedArray.removeAtIndex(index!)
        print("\n\(UserController.sharedController.selectedArray)\n")
    }

}
