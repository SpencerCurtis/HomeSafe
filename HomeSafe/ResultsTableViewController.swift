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
    var filteredArray: [CNContact] = []
    var selectedResultsArray = SelectContactTableViewController.sharedInstance.selectedFavoriteContactsArray
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
        guard let searchText = searchController.searchBar.text else {return}
            self.filteredArray =  results.filter { $0.givenName.lowercaseString.containsString(searchText.lowercaseString) }
            shouldShowResults = true
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
        let contacts = filteredArray.count > 0 ? filteredArray[indexPath.row] : results[indexPath.row]
        if shouldShowResults {
            cell.textLabel?.text = contacts.givenName + " " + contacts.familyName
        }
        return cell
     
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
        let selectedContacts = results[indexPath.row]
        selectedResultsArray.append(selectedContacts)
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
        let index = selectedResultsArray.indexOf(results[indexPath.row])
        selectedResultsArray.removeAtIndex(index!)
    }

}
