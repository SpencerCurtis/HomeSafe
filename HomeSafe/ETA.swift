//
//  ETA.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import Foundation
import CoreLocation

class EstimatedTimeOfArrival {
    
    let ETA: NSDate
    let destinationLocation: CLLocation
    let name: String
    
    init(ETA: NSDate, destinationLocation: CLLocation, name: String) {
        self.ETA = ETA
        self.destinationLocation = destinationLocation
        self.name = name
    }
    
    // CloudKit Initializer?
    
}