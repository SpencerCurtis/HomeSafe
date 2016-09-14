 //
 //  CreateUserViewController.swift
 //  HomeSafe
 //
 //  Created by Spencer Curtis on 5/16/16.
 //  Copyright © 2016 Spencer Curtis. All rights reserved.
 //
 
 import UIKit
 import CoreLocation
 
 class CreateUserViewController: UIViewController {
    
    static let sharedController = CreateUserViewController()
    
    @IBOutlet weak var selectSafePlaceButton: UIButton!
    @IBOutlet weak var createAccountLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var safeLocationLabel: UILabel!
    @IBOutlet weak var alreadyHaveAccountButton: UIButton!
    
    var selectedSafeLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        hideTransparentNavigationBar()
        bounceAnimation()
        self.hideKeyboardWhenTappedAround()
    }
    
    func setupViews() {
        createAccountLabel.center.x = self.view.frame.width - 620
        nameTextField.center.x = self.view.frame.width - 620
        phoneNumberTextField.center.x = self.view.frame.width - 620
        passwordTextField.center.x = self.view.frame.width - 620
        selectSafePlaceButton.center.x = self.view.frame.width - 620
        
        AppearanceController.sharedController.setUpButtons([selectSafePlaceButton, alreadyHaveAccountButton])
        AppearanceController.sharedController.setUpTextFields([passwordTextField, nameTextField, phoneNumberTextField])
        AppearanceController.sharedController.gradientBackgroundForViewController(self)
        
    }
    
    func hideTransparentNavigationBar() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController?.navigationBar.translucent = true
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = UIColor.clearColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if LocationController.sharedController.address != "" {
                self.safeLocationLabel.hidden = false
                self.safeLocationLabel.text = "Your safe location is: \(LocationController.sharedController.address)"
            } else {
                self.safeLocationLabel.hidden = true
            }
            self.hideTransparentNavigationBar()
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createUserButtonTapped(sender: AnyObject) {
        let indicator = AppearanceController.sharedController.setUpActivityIndicator(self)
        self.view.addSubview(indicator)
        let loadingView = UIView()
        loadingView.frame = self.view.bounds
        loadingView.alpha = 0.2
        loadingView.backgroundColor = UIColor.grayColor()
        self.view.addSubview(loadingView)
        self.view.bringSubviewToFront(loadingView)
        self.view.bringSubviewToFront(indicator)
        indicator.startAnimating()
        
        if let name = nameTextField.text, password = passwordTextField.text, phoneNumber = phoneNumberTextField.text, safeLocation = LocationController.sharedController.selectedSafeLocation {
            UserController.sharedController.createUser(name, password: password, safeLocation: safeLocation, phoneNumber: phoneNumber, completion: {
                if let currentUser = UserController.sharedController.currentUser {
                    CloudKitController.sharedController.subscribeToUsersAddingCurrentUserToContactList(currentUser, completion: {
                        CloudKitController.sharedController.subscribeToUsersAddingCurrentUserToNewETA(currentUser, completion: {
                            print("Subscribed successfully to all subscriptions.")
                            CloudKitController.sharedController.fetchSubscriptions()
                            
                            indicator.stopAnimating()
                            self.view.sendSubviewToBack(loadingView)
                            indicator.hidesWhenStopped = true
                            self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    })
                }
            })
        } else {
            indicator.stopAnimating()
            let alert = NotificationController.sharedController.simpleAlert("Hold on", message: "Make sure you enter all the fields, and select a safe place as well.")
            self.view.sendSubviewToBack(loadingView)
            alert.view.tintColor = Colors.sharedColors.exoticGreen
            self.presentViewController(alert, animated: true, completion: {
                alert.view.tintColor = Colors.sharedColors.exoticGreen
                
            })
        }
        
    }
    
    func bounceAnimation() {
        UIView.animateWithDuration(1.8, delay: 0.3, usingSpringWithDamping: 1.0, initialSpringVelocity: 5, options: [], animations: ({
            self.createAccountLabel.center.x = self.view.frame.width / 2
        }), completion: nil)
        
        UIView.animateWithDuration(1.8, delay: 0.5, usingSpringWithDamping: 1.0, initialSpringVelocity: 5, options: [], animations: ({
            self.nameTextField.center.x = self.view.frame.width / 2
        }), completion: nil)
        
        UIView.animateWithDuration(1.8, delay: 0.7, usingSpringWithDamping: 1.0, initialSpringVelocity: 5, options: [], animations: ({
            self.phoneNumberTextField.center.x = self.view.frame.width / 2
        }), completion: nil)
        
        UIView.animateWithDuration(1.8, delay: 0.9, usingSpringWithDamping: 1.0, initialSpringVelocity: 5, options: [], animations: ({
            self.passwordTextField.center.x = self.view.frame.width / 2
        }), completion: nil)
        
        UIView.animateWithDuration(1.8, delay: 1.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 5, options: [], animations: ({
            self.selectSafePlaceButton.center.x = self.view.frame.width / 2
        }), completion: nil)
    }
    
 }
