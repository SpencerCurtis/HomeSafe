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
    func userDidSelectSearchedContacts(_ contacts: [CNContact])
}

class ResultsTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {

    var results: [CNContact] = []
    var filteredArray: [CNContact] = []
    var selectedResultsArray: [CNContact] = []
    var shouldShowResults = false
    var searchController: UISearchController!
    var delegate: PassSearchedContactsDelegate?
    
    @IBOutlet weak var doneButton: UIButton!

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowResults = true
        filteredArray = []
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowResults = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowResults {
            shouldShowResults = true
            tableView.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {return}
            self.filteredArray =  results.filter { $0.givenName.lowercased().contains(searchText.lowercased()) }
            shouldShowResults = true
            tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        tableView.allowsMultipleSelection = true
        doneButton.layer.borderColor = UIColor.white.cgColor
        doneButton.layer.borderWidth = 0.4

        AppearanceController.sharedController.gradientBackgroundForTableViewController(self)
        
        self.tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    @IBAction func secondDoneButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowResults {
            return filteredArray.count
        } else {
            return results.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchedContactCell", for: indexPath)
        let contacts = filteredArray.count > 0 ? filteredArray[indexPath.row] : results[indexPath.row]
        if shouldShowResults {
            cell.textLabel?.text = contacts.givenName + " " + contacts.familyName
            cell.selectionStyle = .none
            cell.tintColor = UIColor.white
        }
        return cell
     
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        let selectedContacts = filteredArray[indexPath.row]
        UserController.sharedController.selectedArray.append(selectedContacts)
        print("\n\(UserController.sharedController.selectedArray)\n")
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
        let index = UserController.sharedController.selectedArray.index(of: filteredArray[indexPath.row])
        UserController.sharedController.selectedArray.remove(at: index!)
        print("\n\(UserController.sharedController.selectedArray)\n")
    }

}
