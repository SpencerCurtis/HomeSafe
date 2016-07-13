//
//  DangerViewController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit

class CurrentETAViewController: UIViewController {
    
    @IBOutlet weak var etaLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var currentFollowersLabel: UILabel!
    @IBOutlet weak var dangerButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }
    
    func setupViews() {
        let gradient = AppearanceController.sharedController.gradientBackground()
        gradient.frame = self.view.bounds
        
        let backgroundView = UIView()
        backgroundView.frame = self.view.bounds
        backgroundView.layer.addSublayer(gradient)
        self.view.addSubview(backgroundView)
        
        self.view.sendSubviewToBack(backgroundView)
        
        if let currentETA = ETAController.sharedController.currentETA, eta = currentETA.eta {
            self.etaLabel.text = "Your estimated time of arrival is \(eta.formatted)"
        }
        
        let followers = NSUserDefaults.standardUserDefaults().valueForKey("currentFollowers") as! [String]
        
        if followers.count == 1 {
            self.followersLabel.text = "Your watcher is:"
        } else if followers.count > 1 {
            self.followersLabel.text = "Your watchers are:"
        }
        
        
        
        currentFollowersLabel.text = followersAsString()
        
        dangerButton.layer.cornerRadius = 50
        dangerButton.layer.borderColor = UIColor.whiteColor().CGColor
        dangerButton.layer.borderWidth = 1
        
        cancelButton.layer.cornerRadius = 50
        cancelButton.layer.borderColor = UIColor.whiteColor().CGColor
        cancelButton.layer.borderWidth = 1
    }
    
    
    func followersAsString() -> String {
        var followersString: String = ""
        for follower in NSUserDefaults.standardUserDefaults().valueForKey("currentFollowers") as! [String] {
            followersString = followersString + "\(follower)\n"
        }
        return followersString
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
            AppearanceController.sharedController.initializeAppearance()
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
        AppearanceController.sharedController.initializeAppearance()
        
    }
}
