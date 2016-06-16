//
//  ETAViewController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit
import CoreLocation

class ETAViewController: UIViewController {
    
    static let sharedInstance = ETAViewController()
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var containerV: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var ETADatePicker: UIDatePicker!
    @IBOutlet weak var SelectDestinationButton: UIButton!
    @IBOutlet weak var startTrackingButton: UIButton!
    
    var destination: CLLocation? = CLLocation(latitude: 0.0, longitude: 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showMapContainerView), name: "locationPicked", object: nil)
        setupViews()
        ETADatePicker.minimumDate = NSDate()
        
    }
    
    func setupViews() {
        self.view.sendSubviewToBack(backgroundView)
        
        self.container.layer.cornerRadius = 12
        self.container.layer.masksToBounds = true
        self.containerV.layer.cornerRadius = 12
        self.searchContainerView.layer.cornerRadius = 12
        
        ETADatePicker.setValue(UIColor.whiteColor(), forKey: "textColor")
        
        let gradient = AppearanceController.sharedController.gradientBackground()
        gradient.frame = self.view.bounds
        backgroundView.layer.addSublayer(gradient)
    }
    
    @IBAction func SelectDateButtonTapped(sender: AnyObject) {
        ETADatePicker.hidden = false
        container.hidden = true
        containerV.hidden = true
    }
    
    @IBAction func SelectDestinationButtonTapped(sender: AnyObject) {
        container.hidden = false
        containerV.hidden = true
        searchContainerView.hidden = false
        ETADatePicker.hidden = true
    }
    
    func showMapContainerView() {
        containerV.hidden = false
        searchContainerView.hidden = true
        
    }
    @IBAction func startTrackingButtonTapped(sender: AnyObject) {
        
        if let currentUser = UserController.sharedController.currentUser, name = currentUser.name, destination = LocationController.sharedController.destination, latitude = currentUser.latitude, longitude = currentUser.longitude {
            ETAController.sharedController.createETA(ETADatePicker.date, latitude: destination.coordinate.latitude, longitude: destination.coordinate.longitude, name: name, canceledETA: false, inDanger: false)
            
            let region = LocationController.sharedController.regionMonitoringUser(Double(latitude), longitude: Double(longitude), currentUser: currentUser)
            LocationController.sharedController.locationManager.startMonitoringForRegion(region)
            let names = ContactsController.sharedController.contacts.map({$0.name!})
            NSUserDefaults.standardUserDefaults().setValue(names, forKey: "currentFollowers")
        }
    }
}

extension NSDate {
    var formatted: String {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        return formatter.stringFromDate(self)
    }
}

