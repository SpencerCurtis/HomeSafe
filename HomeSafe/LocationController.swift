//
//  LocationController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class LocationController: NSObject, CLLocationManagerDelegate {
    
    static let sharedController = LocationController()
    
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.pausesLocationUpdatesAutomatically = true
    }
    
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
    }
    
}