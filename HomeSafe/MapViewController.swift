//
//  MapViewController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol HandleMapSearch {
    func dropPinOnSelectedLocation(placemark: MKPlacemark)
}

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager: CLLocationManager = LocationController.sharedController.locationManager
    var currentLocation = CLLocation()
    
    var selectedSafeZonePin: MKAnnotation? = nil
    
    var color = Colors()
    
    var resultsSearchController: UISearchController? = nil
    
    let authState = CLLocationManager.authorizationStatus()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        if authState == .AuthorizedAlways {
            locationManager.requestLocation()
        } 
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(zoomOnUsersLocation), name: "zoomOnUser", object: nil)
        
        mapView.mapType = .Hybrid
        if authState == .NotDetermined {
            LocationController.sharedController.locationManager.requestAlwaysAuthorization()
            zoomOnUsersLocation()
        }
        zoomOnUsersLocation()
        mapView.delegate = self
        mapView.showsUserLocation = true
        hideTransparentNavigationBar()
        LocationController.sharedController.locationManager.delegate = self
        
        //        let createAnnotation = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.dropLocationPin(_:)))
        //        createAnnotation.minimumPressDuration = 1
        //        mapView.addGestureRecognizer(createAnnotation)
        
        let locationSearchTable = storyboard?.instantiateViewControllerWithIdentifier("LocationSearchTableViewController") as? LocationSearchTableViewController
        resultsSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultsSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultsSearchController?.searchBar
        searchBar?.sizeToFit()
        searchBar?.placeholder = "Enter Desired Location"
        navigationItem.titleView = resultsSearchController?.searchBar
        resultsSearchController?.hidesNavigationBarDuringPresentation = false
        resultsSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable?.mapView = mapView
        locationSearchTable?.handleMapSearchDelegate = self
        
    }
    
    
    func hideTransparentNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.translucent = true
        //        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = UIColor(red: 0.298, green: 0.749, blue: 0.035, alpha: 1.00)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
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
        
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "goArrow") ?? UIImage(), forState: .Normal)
        button.addTarget(self, action: #selector(selectSafeZone), forControlEvents: .TouchUpInside)
        // Get the address from the pin.
        pinView?.rightCalloutAccessoryView = button
        self.selectedSafeZonePin = annotation
        
        return pinView
        
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        if let annotation = self.mapView.annotations.last {
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    func selectSafeZone() {
        if let annotation = self.selectedSafeZonePin {
            let coordinate = annotation.coordinate
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            LocationController.sharedController.selectedSafeLocation = location
            navigationController?.popViewControllerAnimated(true)
            
        }
    }
    
    func zoomOnUsersLocation() {
        if locationManager.location != nil {
            let span = MKCoordinateSpanMake(0.0073, 0.0073)
            let region = MKCoordinateRegionMake(locationManager.location!.coordinate, span)
            mapView.setRegion(region, animated: true)
        }
    }
    
}

extension MapViewController: HandleMapSearch {
    
    func dropPinOnSelectedLocation(placemark: MKPlacemark) {
        selectedSafeZonePin = placemark
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

































