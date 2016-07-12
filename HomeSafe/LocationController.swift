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
import CloudKit
import MapKit

class LocationController: NSObject, CLLocationManagerDelegate {
    
    static let sharedController = LocationController()
    
    let locationManager = CLLocationManager()
    
    var selectedSafeLocation: CLLocation?
    
    var address: String = ""
    
    var destination: MKPlacemark?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.pausesLocationUpdatesAutomatically = true
    }
    
    
    
    
    func regionMonitoringUser(latitude: Double, longitude: Double, currentUser: CurrentUser) -> CLCircularRegion {
        locationManager.requestAlwaysAuthorization()
        
        let usersLocation = CLCircularRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), radius: 600, identifier: currentUser.uuid!)
        
        return usersLocation
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let currentETA = ETAController.sharedController.currentETA {
            ETAController.sharedController.homeSafely(currentETA)
        }
        print("Entered Location")
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited Location")
    }
    
    
    
    
}