//
//  SmallMapViewController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 6/13/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SmallMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    
    var selectedDestinationPin: MKAnnotation? = nil
    
    var color = Colors()
    
    var resultsSearchController: UISearchController? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.mapType = .Hybrid
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(dropPinOnSelectedDestination), name: "locationPicked", object: nil)
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        let createAnnotation = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.dropLocationPin(_:)))
        createAnnotation.minimumPressDuration = 1
        mapView.addGestureRecognizer(createAnnotation)
        
        let locationSearchTable = storyboard?.instantiateViewControllerWithIdentifier("LocationSearchTableViewController") as? LocationSearchTableViewController
        resultsSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultsSearchController?.searchResultsUpdater = locationSearchTable
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0.278, green: 0.749, blue: 0.082, alpha: 1.00)
        backgroundView.frame = view.bounds
        self.view.addSubview(backgroundView)
        self.view.sendSubviewToBack(backgroundView)
        
        searchBar?.sizeToFit()
        searchBar?.placeholder = "Enter Desired Location"
        navigationItem.titleView = resultsSearchController?.searchBar
        resultsSearchController?.hidesNavigationBarDuringPresentation = false
        resultsSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable?.mapView = mapView
        locationSearchTable?.handleMapSearchDelegate = self
        
    }
    
    func dropPinOnSelectedDestination() {
        var destination: MKPlacemark? {
            return LocationController.sharedController.destination
        }
        if let destination = destination {
            selectedDestinationPin = destination
            mapView.removeAnnotations(mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = destination.coordinate
            annotation.title = destination.name
            if let city = destination.locality,
                let state = destination.administrativeArea {
                annotation.subtitle = "\(city), \(state)"
            }
            mapView.addAnnotation(annotation)
            let span = MKCoordinateSpanMake(0.0073, 0.0073)
            let region = MKCoordinateRegionMake(destination.coordinate, span)
            mapView.setRegion(region, animated: true)
            
        }
        
    }
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.currentLocation = location
            let span = MKCoordinateSpanMake(0.0073, 0.0073)
            let region = MKCoordinateRegionMake(location.coordinate, span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: \(error.localizedDescription)")
    }
    
    func dropLocationPin(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let newCoordinate: CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinate
        annotation.title = "New Destination"
        annotation.subtitle = ""
        mapView.addAnnotation(annotation)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        pinView?.pinTintColor = color.exoticGreen
        pinView?.canShowCallout = true
        pinView?.animatesDrop = true
        
        self.selectedDestinationPin = annotation
        
        return pinView
        
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        if let annotation = self.mapView.annotations.last {
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
}

extension SmallMapViewController: HandleMapSearch {
    
    func dropPinOnSelectedLocation(placemark: MKPlacemark) {
        selectedDestinationPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city), \(state)"
        }
        
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.0073, 0.0073)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
    
}

































