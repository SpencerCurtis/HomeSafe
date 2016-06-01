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
    
    @IBOutlet weak var ETADatePicker: UIDatePicker!
    @IBOutlet weak var ETALabel: UILabel!
    @IBOutlet weak var SelectDestinationButton: UIButton!
    @IBOutlet weak var DestinationLabel: UILabel!
    @IBOutlet weak var startTrackingButton: UIButton!
    
    var destination: CLLocation? = CLLocation(latitude: 0.0, longitude: 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ETADatePicker.minimumDate = NSDate()
        ETADatePicker.addTarget(self, action: #selector(updateETALabel), forControlEvents: .ValueChanged)
        //customGradientBackgroundColor()
        //self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.286, green: 0.749, blue: 0.063, alpha: 1.00)
                // Do any additional setup after loading the view.
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
        self.view.layer.insertSublayer(gradientLayer, atIndex: 0)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateETALabel() {
        ETALabel.text = "Your ETA is \(ETADatePicker.date.formatted)"
    }
    
    
    @IBAction func SelectDestinationButtonTapped(sender: AnyObject) {

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

