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
        UINavigationBar.appearance().barStyle = UIBarStyle.Default
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UIBarButtonItem.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().backgroundColor = Colors.sharedColors.exoticGreen
        UINavigationBar.appearanceWhenContainedInInstancesOfClasses([MFMessageComposeViewController.self]).tintColor = UIColor.blueColor()
        
        let textAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        UINavigationBar.appearance().titleTextAttributes = textAttributes
    }
    
    func intitializeAppearanceForMFMessageController() {
        UINavigationBar.appearanceWhenContainedInInstancesOfClasses([MFMessageComposeViewController.self]).tintColor = UIColor.blueColor()
        UINavigationBar.appearance().barStyle = .Black
        UINavigationBar.appearance().backgroundColor = UIColor.greenColor()
        let textAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().titleTextAttributes = textAttributes
        
    }
    
    func gradientBackground() -> CAGradientLayer {
        let colorTop = UIColor(red: 0.314, green: 0.749, blue: 0.000, alpha: 1.00).CGColor
        let colorBottom = UIColor(red: 0.000, green: 0.741, blue: 0.702, alpha: 1.00).CGColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        return gradientLayer
    }
    
    func gradientBackgroundForViewController(viewController: UIViewController) {
        let gradient = AppearanceController.sharedController.gradientBackground()
        gradient.frame = viewController.view.bounds
        let backgroundView = UIView()
        backgroundView.frame = viewController.view.bounds
        backgroundView.layer.addSublayer(gradient)
        viewController.view.addSubview(backgroundView)
        viewController.view.sendSubviewToBack(backgroundView)
    }
    
    func gradientBackgroundForTableViewController(tableViewController: UITableViewController) {
        let gradient = AppearanceController.sharedController.gradientBackground()
        gradient.frame = tableViewController.view.bounds
        let backgroundView = UIView()
        backgroundView.frame = tableViewController.view.bounds
        backgroundView.layer.addSublayer(gradient)
        tableViewController.tableView.backgroundView = backgroundView
    }
    
    func setUpButtons(buttons: [UIButton]) {
        for button in buttons {
            button.layer.cornerRadius = 5
            button.layer.borderColor = UIColor.whiteColor().CGColor
            button.layer.borderWidth = 0.2
        }
    }
    
    func setUpTextFields(textFields: [UITextField]) {
        for textField in textFields {
            textField.layer.cornerRadius = 5
            textField.layer.borderColor = UIColor.whiteColor().CGColor
            textField.layer.borderWidth = 0.3
            textField.tintColor = Colors.sharedColors.exoticGreen
        }
    }
    
    func setUpActivityIndicator(viewController: UIViewController) -> UIActivityIndicatorView {
        let indicator:UIActivityIndicatorView = UIActivityIndicatorView  (activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        indicator.color = UIColor .whiteColor()
        indicator.frame = CGRectMake(0.0, 0.0, 10.0, 10.0)
        indicator.center = viewController.view.center
        indicator.hidesWhenStopped = true
        return indicator
    }
}
