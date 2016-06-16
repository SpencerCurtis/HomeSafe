//
//  AppDelegate.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    // TODO: - Fix navBar on first mapView.
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
//        if UserController.sharedController.currentUser == nil {
//            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            
//            let initialViewController = storyboard.instantiateViewControllerWithIdentifier("CreateUserViewController")
//            
//            self.window?.rootViewController = initialViewController
//            self.window?.makeKeyAndVisible()
//        }
//        
        
        
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let pushNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        AppearanceController.sharedController.initializeAppearance()
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        //         Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if let currentUser = UserController.sharedController.currentUser {
            CloudKitController.sharedController.checkForNewETA(currentUser, completion: {
                let phoneNumberArray = NSUserDefaults.standardUserDefaults().valueForKey("phoneNumberArrayForETA") as! [String]
                for phoneNumber in phoneNumberArray {
                    CloudKitController.sharedController.fetchETAAndSubscribe(phoneNumber)
                }
            })
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print(userInfo)
        handleRemoteNotification(userInfo)
        
        
    }
    
    func handleRemoteNotification(userInfo: [NSObject: AnyObject]) {
        let info = userInfo["aps"] as! [String: AnyObject]
        let alertText = info["alert"] as! String
        switch alertText {
        case "You have been added as someone's contact":
            NSUserDefaults.standardUserDefaults().setValue("newContact", forKey: "newContact")
            if let currentUser = UserController.sharedController.currentUser {
                CloudKitController.sharedController.checkForNewContacts(currentUser, completion: { (users) in
                    for user in users {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let alert = NotificationController.sharedController.simpleAlert("\(user.name!) has added you as a contact" , message: "")
                            self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
                        })
                        
                        
                    }
                })
            }
        case "Someone has begun an ETA and wants to you be their watcher.":
            print("idk yet")
        default:
            break
        }
    }
    
    
    
}

