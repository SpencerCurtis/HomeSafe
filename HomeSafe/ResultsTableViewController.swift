//
//  ResultsTableViewController.swift
//  HomeSafe
//
//  Created by Aaron Eliason on 5/20/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit
import Contacts

class ResultsTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {

    var results: [CNContact] = []
    var filteredArray = [CNContact]()
    var shouldShowResults = false
    var searchController: UISearchController!

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        shouldShowResults = true
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
        guard let searchText = searchController.searchBar.text,
            resultsVC = searchController.searchResultsUpdater as? ResultsTableViewController else {return}
            self.filteredArray =  results.filter { $0.givenName.lowercaseString.containsString(searchText.lowercaseString) }
        tableView.reloadData()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self

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
        let contact = results[indexPath.row]
        if shouldShowResults {
            cell.textLabel?.text = contact.givenName + " " + contact.familyName
        } else {
            cell.textLabel?.text = contact.givenName + " " + contact.familyName
        }
        return cell
    }
    

//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
//        let selectedContacts = userContacts[indexPath.row]
//        selectedFavoriteContactsArray.append(selectedContacts)
//    }
//    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
//        let index = selectedFavoriteContactsArray.indexOf(userContacts[indexPath.row])
//        selectedFavoriteContactsArray.removeAtIndex(index!)
//    }



   
}
