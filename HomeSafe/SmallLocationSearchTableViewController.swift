//
//  SmallLocationSearchTableViewController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 6/14/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit
import MapKit

class SmallLocationSearchTableViewController: UITableViewController, UISearchResultsUpdating {
    
    @IBOutlet weak var locationSearchBar: UISearchBar!
    
    static let sharedController = SmallLocationSearchTableViewController()
    
    var resultSearchController: UISearchController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        let locationSearchTable = storyboard!.instantiateViewControllerWithIdentifier("SmallLocationSearchTable") as! SmallLocationSearchTableViewController
        //        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        //        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let controller = UISearchController(searchResultsController: nil)
        resultSearchController = controller
        if let resultSearchController = resultSearchController {
            resultSearchController.searchResultsUpdater = self
            resultSearchController.dimsBackgroundDuringPresentation = false
            resultSearchController.searchBar.sizeToFit()
            resultSearchController.searchBar.barTintColor = UIColor(red: 0.255, green: 0.749, blue: 0.133, alpha: 1.00)
            //        resultSearchController.searchBar.searchBarStyle = .Minimal
            resultSearchController.searchBar.backgroundImage = UIImage()
            resultSearchController.searchBar.placeholder = "Search for your destination"
//            resultSearchController.searchBar.setSearchFieldBackgroundImage(UIImage(), forState: .Normal)
            self.tableView.tableHeaderView = resultSearchController.searchBar
            self.tableView.backgroundColor = UIColor.clearColor()
        }
        
    }
    
    var matchingLocations: [MKMapItem] = []
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate: HandleMapSearch? = nil
    var searchController = UISearchController(searchResultsController: nil)
    
    func parsingTheAddress(selectedItem: MKPlacemark) -> String {
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(format: "%@%@%@%@%@%@%@", selectedItem.subThoroughfare ?? "", firstSpace, selectedItem.thoroughfare ?? "", comma, selectedItem.locality ?? "", secondSpace, selectedItem.administrativeArea ?? "")
        return addressLine
        
    }
    
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else {return}
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        //        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { response, _ in
            guard let response  = response else { return }
            self.matchingLocations = response.mapItems
            self.tableView.reloadData()
        }
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingLocations.count ?? 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("smallCell")!
        let selectedItem = matchingLocations[indexPath.row].placemark
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.textColor = UIColor.whiteColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.detailTextLabel?.text = parsingTheAddress(selectedItem)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = matchingLocations[indexPath.row].placemark
        LocationController.sharedController.destination = selectedItem
        handleMapSearchDelegate?.dropPinOnSelectedLocation(selectedItem)
        LocationController.sharedController.address = parsingTheAddress(selectedItem)
        NSNotificationCenter.defaultCenter().postNotificationName("locationPicked", object: nil)
        dismissViewControllerAnimated(true, completion: nil)
    }
}