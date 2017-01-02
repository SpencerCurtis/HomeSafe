//
//  LocationSearchTableViewController.swift
//  HomeSafe
//
//  Created by admin on 5/17/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchTableViewController: UITableViewController {
    
    
    override func viewDidLoad() {
        let gradient = AppearanceController.sharedController.gradientBackground()
        gradient.frame = self.view.bounds
        let backgroundView = UIView()
        backgroundView.frame = self.view.bounds
        backgroundView.layer.addSublayer(gradient)
        
        self.tableView.addSubview(backgroundView)
        
        self.tableView.sendSubview(toBack: backgroundView)
        
    }
    
    static let sharedController = LocationSearchTableViewController()
    
    var matchingLocations: [MKMapItem] = []
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate: HandleMapSearch? = nil
    
    func parsingTheAddress(_ selectedItem: MKPlacemark) -> String {
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(format: "%@%@%@%@%@%@%@", selectedItem.subThoroughfare ?? "", firstSpace, selectedItem.thoroughfare ?? "", comma, selectedItem.locality ?? "", secondSpace, selectedItem.administrativeArea ?? "")
        return addressLine
        
    }

}

extension LocationSearchTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
              let searchBarText = searchController.searchBar.text else {return}
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response  = response else {
                return
            }
            self.matchingLocations = response.mapItems
            self.tableView.reloadData()
        }
    }
}

extension LocationSearchTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingLocations.count 
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell")!
        let selectedItem = matchingLocations[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = parsingTheAddress(selectedItem)
        return cell
    }
    
    
}

extension LocationSearchTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingLocations[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinOnSelectedLocation(selectedItem)
        LocationController.sharedController.address = parsingTheAddress(selectedItem)
        dismiss(animated: true, completion: nil)
    }
}
