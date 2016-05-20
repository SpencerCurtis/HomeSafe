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
    
    var destination: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ETADatePicker.addTarget(self, action: #selector(updateETALabel), forControlEvents: .ValueChanged)
        // Do any additional setup after loading the view.
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

