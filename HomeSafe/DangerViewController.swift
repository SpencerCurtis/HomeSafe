//
//  DangerViewController.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit

class DangerViewController: UIViewController {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var dangerButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dangerButtonTapped(sender: AnyObject) {
        if let eta = ETAController.sharedController.currentETA {
            ETAController.sharedController.inDanger(eta)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        if let eta = ETAController.sharedController.currentETA {
            ETAController.sharedController.cancelETA(eta)
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
