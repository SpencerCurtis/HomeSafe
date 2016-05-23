//
//  LocationTableViewController.swift
//  HomeSafe
//
//  Created by admin on 5/20/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit
import MapKit

class LocationTableViewController: UITableViewController {
    
    static let sharedController = LocationTableViewController()
    
    var matchingLocations: [MKMapItem] = []
    var mapView: MKMapView? = nil
    var mapSearchDelegate: MapSearch? = nil
    
    func parsingTheAddress(selectedItem: MKPlacemark) -> String {
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(format: "%@%@%@%@%@%@%@", selectedItem.subThoroughfare ?? "", firstSpace, selectedItem.thoroughfare ?? "", comma, selectedItem.locality ?? "", secondSpace, selectedItem.administrativeArea ?? "")
        return addressLine
        
    }
    
}

extension LocationTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else {return}
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { response, _ in
            guard let response  = response else {
                return
            }
            self.matchingLocations = response.mapItems
            self.tableView.reloadData()
        }
    }
}

extension LocationTableViewController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingLocations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("locationCell")!
        let selectedItem = matchingLocations[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parsingTheAddress(selectedItem)
        return cell
    }
    
    
}

extension LocationTableViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedItem = matchingLocations[indexPath.row].placemark
        mapSearchDelegate?.dropPinOnSelectedLocation(selectedItem)
        LocationController.sharedController.address = parsingTheAddress(selectedItem)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
