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
    
    @IBOutlet weak var backgroundView: UIView!
    
    static let sharedInstance = ETAViewController()
    
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
        self.view.sendSubviewToBack(backgroundView)
        self.container.layer.cornerRadius = 12
        self.container.layer.masksToBounds = true
        self.containerV.layer.cornerRadius = 12
        self.searchContainerView.layer.cornerRadius = 12
        ETADatePicker.setValue(UIColor.whiteColor(), forKey: "textColor")
//        ETADatePicker.performSelector("setHighlightsToday:", withObject: UIColor.whiteColor())

        
        let gradient = AppearanceController.sharedController.gradientBackground()
        gradient.frame = self.view.bounds
        backgroundView.layer.addSublayer(gradient)
        
        
        ETADatePicker.minimumDate = NSDate()
//        ETADatePicker.addTarget(self, action: #selector(updateETALabel), forControlEvents: .ValueChanged)

    }
    
    func customGradientBackgroundColor() {
        let topColor = UIColor(red: 0.314, green: 0.749, blue: 0.000, alpha: 1.00)
        let bottomColor = UIColor(red: 0.000, green: 0.741, blue: 0.702, alpha: 1.00)
        
        let gradientColors: [CGColor] = [topColor.CGColor, bottomColor.CGColor]
        let gradientLocations: [Float] = [0.0, 1.0]
        
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations
        gradientLayer.frame = self.view.bounds
        self.backgroundView.layer.insertSublayer(gradientLayer, atIndex: 0)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if let name = UserController.sharedController.currentUser?.name, destination = destination {
        ETAController.sharedController.createETA(ETADatePicker.date, latitude: destination.coordinate.latitude, longitude: destination.coordinate.longitude, name: name, canceledETA: false, inDanger: false)
            let region = LocationController.sharedController.regionMonitoringUser(Double((UserController.sharedController.currentUser?.latitude)!), longitude: Double((UserController.sharedController.currentUser?.longitude)!), currentUser: UserController.sharedController.currentUser!)

            LocationController.sharedController.locationManager.startMonitoringForRegion(region)
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

