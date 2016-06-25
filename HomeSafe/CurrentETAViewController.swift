//
//  DangerViewController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit

class CurrentETAViewController: UIViewController {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var dangerButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        labelText()
    }
    
    func setupViews() {
        let gradient = AppearanceController.sharedController.gradientBackground()
        gradient.frame = self.view.bounds
        backgroundView.layer.addSublayer(gradient)
        self.view.sendSubviewToBack(backgroundView)
        
        
        dangerButton.layer.cornerRadius = 50
        dangerButton.layer.borderColor = UIColor.whiteColor().CGColor
        dangerButton.layer.borderWidth = 1
        
        cancelButton.layer.cornerRadius = 50
        cancelButton.layer.borderColor = UIColor.whiteColor().CGColor
        cancelButton.layer.borderWidth = 1
    }
    
    func labelText() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let guardians = ContactsController.sharedController.selectedGuardians
            if let currentETA = ETAController.sharedController.currentETA, eta = currentETA.eta {
                self.etaLabel.text = "Your estimated time of arrival is \(eta.formatted)"
                if guardians.count == 1 {
                    self.followersLabel.text = "Your watcher is \(guardians.first!.name!)"
                } else {
                    self.followersLabel.text = "Your watchers are:\n"
                    for guardian in NSUserDefaults.standardUserDefaults().valueForKey("currentFollowers") as! [String] {
                        self.followersLabel.text = self.followersLabel.text! + "\(guardian)\n"
                    }
                }
            }
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dangerButtonTapped(sender: AnyObject) {
        if let eta = ETAController.sharedController.currentETA {
            ETAController.sharedController.inDanger(eta)
            self.dismissViewControllerAnimated(true, completion: nil)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("selectFollowersVC")
            self.presentViewController(vc, animated: true, completion: nil)
            // Add alert to tell user that followers have been notified.
        }
        
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        if let eta = ETAController.sharedController.currentETA {
            print(eta.id!)
            ETAController.sharedController.cancelETA(eta)
            
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("selectFollowersVC")
        self.presentViewController(vc, animated: true, completion: nil)

    }
}
