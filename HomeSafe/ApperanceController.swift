//
//  AppearanceController.swift
//  HomeSafe
//
//  Created by admin on 5/17/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit
import MessageUI

class AppearanceController {
    
    static let sharedController = AppearanceController()
    
    var color = Colors()
    
    func initializeAppearance() {
        UINavigationBar.appearance().barStyle = UIBarStyle.default
        UINavigationBar.appearance().tintColor = UIColor.white
        UIBarButtonItem.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().backgroundColor = Colors.sharedColors.exoticGreen
        UINavigationBar.appearance(whenContainedInInstancesOf: [MFMessageComposeViewController.self]).tintColor = UIColor.blue
        
        let textAttributes = [NSForegroundColorAttributeName:UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = textAttributes
    }
    
    func intitializeAppearanceForMFMessageController() {
        UINavigationBar.appearance(whenContainedInInstancesOf: [MFMessageComposeViewController.self]).tintColor = UIColor.blue
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().backgroundColor = UIColor.green
        let textAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UINavigationBar.appearance().titleTextAttributes = textAttributes
        
    }
    
    func gradientBackground() -> CAGradientLayer {
        let colorTop = UIColor(red: 0.314, green: 0.749, blue: 0.000, alpha: 1.00).cgColor
        let colorBottom = UIColor(red: 0.000, green: 0.741, blue: 0.702, alpha: 1.00).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        return gradientLayer
    }
    
    func gradientBackgroundForViewController(_ viewController: UIViewController) {
        let gradient = AppearanceController.sharedController.gradientBackground()
        gradient.frame = viewController.view.bounds
        let backgroundView = UIView()
        backgroundView.frame = viewController.view.bounds
        backgroundView.layer.addSublayer(gradient)
        viewController.view.addSubview(backgroundView)
        viewController.view.sendSubview(toBack: backgroundView)
    }
    
    func gradientBackgroundForTableViewController(_ tableViewController: UITableViewController) {
        let gradient = AppearanceController.sharedController.gradientBackground()
        gradient.frame = tableViewController.view.bounds
        let backgroundView = UIView()
        backgroundView.frame = tableViewController.view.bounds
        backgroundView.layer.addSublayer(gradient)
        tableViewController.tableView.backgroundView = backgroundView
    }
    
    func setUpButtons(_ buttons: [UIButton]) {
        for button in buttons {
            button.layer.cornerRadius = 5
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 0.2
        }
    }
    
    func setUpTextFields(_ textFields: [UITextField]) {
        for textField in textFields {
            textField.layer.cornerRadius = 5
            textField.layer.borderColor = UIColor.white.cgColor
            textField.layer.borderWidth = 0.3
            textField.tintColor = Colors.sharedColors.exoticGreen
        }
    }
    
    func setUpActivityIndicator(_ viewController: UIViewController) -> UIActivityIndicatorView {
        let indicator:UIActivityIndicatorView = UIActivityIndicatorView  (activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        indicator.color = UIColor.white
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)
        indicator.center = viewController.view.center
        indicator.hidesWhenStopped = true
        return indicator
    }
}
