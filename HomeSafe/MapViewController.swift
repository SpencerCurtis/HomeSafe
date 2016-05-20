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
    
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    
    var selectedSafeZonePin: MKAnnotation? = nil
    
    var color = Colors()
    
    var resultsSearchController: UISearchController? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        /*
        let createAnnotation = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.dropLocationPin(_:)))
        createAnnotation.minimumPressDuration = 1
        mapView.addGestureRecognizer(createAnnotation)
        */
        
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
    
    /* Long Press Function
     
    func dropLocationPin(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.locationInView(mapView)
        let newCoordinate: CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinate
        annotation.title = "New Destination"
        mapView.addAnnotation(annotation)
        
        // Attempt to pull address info from dropped pin //
        
        let num = (newCoordinate.latitude as NSNumber).floatValue
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 4
        formatter.minimumFractionDigits = 4
        _ = formatter.stringFromNumber(num)
        
        let num1 = (newCoordinate.longitude as NSNumber).floatValue
        let formatter1 = NSNumberFormatter()
        formatter1.maximumFractionDigits = 4
        formatter1.minimumFractionDigits = 4
        _ = formatter1.stringFromNumber(num1)
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            let placeArray = placemarks as [CLPlacemark]!
            var placeMark: CLPlacemark
            placeMark = placeArray[0]
            
            guard let locationName = placeMark.addressDictionary?["Name"],
                  let street = placeMark.addressDictionary?["Throughfare"],
                  let city = placeMark.addressDictionary?["City"],
                  let zip = placeMark.addressDictionary?["ZIP"],
                  let country = placeMark.addressDictionary?["Country"] as? NSString else {return}
            print(locationName, street, city, zip, country)
            
        }
    } */
    
    
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
    
    func selectSafeZone() {
        if let annotation = self.selectedSafeZonePin {
            let coordinate = annotation.coordinate
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            CreateUserViewController.sharedController.selectedSafeLocation = location
            navigationController?.popViewControllerAnimated(true)
        }
    
    }
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
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































    

