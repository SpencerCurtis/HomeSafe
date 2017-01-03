//
//  ETAViewController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit
import CoreLocation

class ETAViewController: UIViewController, UITextFieldDelegate {
    
    static let sharedInstance = ETAViewController()
    
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var containerV: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ETADatePicker: UIDatePicker!
    @IBOutlet weak var SelectDestinationButton: UIButton!
    @IBOutlet weak var startTrackingButton: UIButton!
    
    var destination: CLLocation? = CLLocation(latitude: 0.0, longitude: 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(showMapContainerView), name: NSNotification.Name(rawValue: "locationPicked"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clearBorderForContainerView), name: NSNotification.Name(rawValue: "doneAnimating"), object: nil)
        //        self.hideKeyboardWhenTappedAround()
        setupViews()
        ETADatePicker.minimumDate = Date()
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func setupViews() {
        
        self.container.layer.cornerRadius = 12
        self.container.layer.masksToBounds = true
        self.containerV.layer.cornerRadius = 12
        self.searchContainerView.layer.cornerRadius = 12
        self.container.layer.borderWidth = 0.4
        self.container.layer.borderColor = UIColor.white.cgColor
        
        ETADatePicker.setValue(UIColor.white, forKey: "textColor")
        
        let gradient = AppearanceController.sharedController.gradientBackground()
        gradient.frame = self.view.bounds
        
        let backgroundView = UIView()
        backgroundView.frame = self.view.bounds
        backgroundView.layer.addSublayer(gradient)
        self.view.addSubview(backgroundView)
        
        self.view.sendSubview(toBack: backgroundView)
        
        
        
    }
    
    @IBAction func SelectDateButtonTapped(_ sender: AnyObject) {
        ETADatePicker.isHidden = false
        container.isHidden = true
        containerV.isHidden = true
        titleLabel.isHidden = false
        titleLabel.text = "When will you return to your safe place by?"
    }
    
    @IBAction func SelectDestinationButtonTapped(_ sender: AnyObject) {
        self.container.frame.size.height = 0
        self.container.layer.borderColor = UIColor.white.cgColor
        
        UIView.animate(withDuration: 0.3, animations: {
            self.container.frame.size.height = 344
            //        NSNotificationCenter.defaultCenter().postNotificationName("doneAnimating", object: nil)
        })
        //        clearBorderForContainerView()
        container.isHidden = false
        containerV.isHidden = true
        searchContainerView.isHidden = false
        ETADatePicker.isHidden = true
        titleLabel.isHidden = true
        
    }
    
    func showMapContainerView() {
        
        containerV.isHidden = false
        searchContainerView.isHidden = true
    }
    
    func clearBorderForContainerView() {
        let duration = 1.5
        UIView.animateKeyframes(withDuration: duration, delay: 0.5, options: UIViewKeyframeAnimationOptions(), animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: duration * 1/2, animations: {
                self.container.layer.borderColor = UIColor.white.cgColor
            })
            UIView.addKeyframe(withRelativeStartTime: duration * 1/2, relativeDuration:  duration * 1/2, animations: {
                self.container.layer.borderColor = UIColor.clear.cgColor
            })
            
            }, completion: nil)
    }
    
    
    @IBAction func startTrackingButtonTapped(_ sender: AnyObject) {
        guard LocationController.sharedController.destination != nil && ETADatePicker.date != Date() && ContactsController.sharedController.selectedGuardians != [] else {
            let alert = UIAlertController(title: "Hold on a second", message: "Make sure you have selected a destination, a return time, and people to be notified of your departure", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(dismissAction)
            alert.view.tintColor = Colors.sharedColors.exoticGreen
            self.present(alert, animated: true, completion: {
                alert.view.tintColor = Colors.sharedColors.exoticGreen
            })
            return
        }
        
        if let currentUser = UserController.sharedController.currentUser, let name = currentUser.name, let destination = LocationController.sharedController.destination, let latitude = currentUser.latitude, let longitude = currentUser.longitude {
            ETAController.sharedController.createETA(ETADatePicker.date, latitude: destination.coordinate.latitude, longitude: destination.coordinate.longitude, name: name, canceledETA: false, inDanger: false)
            
            let region = LocationController.sharedController.regionMonitoringUser(Double(latitude), longitude: Double(longitude), currentUser: currentUser)
            LocationController.sharedController.locationManager.startMonitoring(for: region)
            let currentETAVC = storyboard?.instantiateViewController(withIdentifier: "currentETAController") as! CurrentETAViewController
            self.present(currentETAVC, animated: true, completion: nil)
        }
    }
}

extension Date {
    var formatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

extension NSDate {
    var formatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self as Date)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
