//
//  DangerViewController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit
import MapKit

class CurrentETAViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var currentFollowersLabel: UILabel!
    @IBOutlet weak var dangerButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var destinationMapView: MKMapView!
    
    var selectedDestinationPin: MKAnnotation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        destinationMapView.delegate = self
        setupViews()
        // Do any additional setup after loading the view.
    }
    
    func setupViews() {
        let gradient = AppearanceController.sharedController.gradientBackground()
        gradient.frame = self.view.bounds
        
        let backgroundView = UIView()
        backgroundView.frame = self.view.bounds
        backgroundView.layer.addSublayer(gradient)
        self.view.addSubview(backgroundView)
        
        self.view.sendSubview(toBack: backgroundView)
        
        if let currentETA = ETAController.sharedController.currentETA, let eta = currentETA.eta {
            self.etaLabel.text = "Your estimated time of arrival is \(eta.formatted)"
        }
        
        let followers = UserDefaults.standard.value(forKey: "currentFollowers") as! [String]
        
        if followers.count == 1 {
            self.followersLabel.text = "Your watcher is:"
        } else if followers.count > 1 {
            self.followersLabel.text = "Your watchers are:"
        }
        
        
        
        currentFollowersLabel.text = followersAsString()
        
        destinationMapView.layer.cornerRadius = 12
        
        dangerButton.layer.cornerRadius = 50
        dangerButton.layer.borderColor = UIColor.white.cgColor
        dangerButton.layer.borderWidth = 1
        
        cancelButton.layer.cornerRadius = 50
        cancelButton.layer.borderColor = UIColor.white.cgColor
        cancelButton.layer.borderWidth = 1
        
        let annotation = MKPointAnnotation()
        guard let destination = ETAController.sharedController.currentETA, let latitude = destination.latitude, let longitude = destination.longitude else { return }
        let destinationCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        
        annotation.coordinate = destinationCoordinate
        annotation.title = LocationController.sharedController.address
        annotation.subtitle = ""
        
        let span = MKCoordinateSpanMake(0.0073, 0.0073)
        let region = MKCoordinateRegionMake(destinationCoordinate, span)
        
        destinationMapView.setRegion(region, animated: true)
        destinationMapView.addAnnotation(annotation)
        destinationMapView.mapType = .hybrid
        
        
        
    }
    
    
    func followersAsString() -> String {
        var followersString: String = ""
        for follower in UserDefaults.standard.value(forKey: "currentFollowers") as! [String] {
            followersString = followersString + "\(follower)\n"
        }
        return followersString
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
        pinView?.pinTintColor = Colors.sharedColors.exoticGreen
        pinView?.canShowCallout = true
        pinView?.animatesDrop = true
        
        self.selectedDestinationPin = annotation
        
        return pinView
        
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if let annotation = self.destinationMapView.annotations.last {
            self.destinationMapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    
    @IBAction func dangerButtonTapped(_ sender: AnyObject) {
        if let eta = ETAController.sharedController.currentETA {
            ETAController.sharedController.inDanger(eta)
            self.dismiss(animated: true, completion: nil)
            if let region = LocationController.sharedController.locationManager.monitoredRegions.first {
                LocationController.sharedController.locationManager.stopMonitoring(for: region)
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "selectFollowersVC")
            self.present(vc, animated: true, completion: nil)
            AppearanceController.sharedController.initializeAppearance()
            // Add alert to tell user that followers have been notified.
        }
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "selectFollowersVC")
        self.present(vc, animated: true, completion: nil)
        
        AppearanceController.sharedController.initializeAppearance()
        
        guard let eta = ETAController.sharedController.currentETA, let region = LocationController.sharedController.locationManager.monitoredRegions.first else { /* Alert to tell them it didn't work. */ return }
        
        print(eta.id!)
        ETAController.sharedController.cancelETA(eta)
        
        LocationController.sharedController.locationManager.stopMonitoring(for: region)
        
        
        
    }
}
