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
    
    // TODO: - Run a check on adding contacts that if the contact hasn't made an account, pull up an sms vc to invite them.
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if let _ = ETAController.sharedController.currentETA {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "currentETAController")
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            
            return true
        }
        
        
        
        let notificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
        let pushNotificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
        UIApplication.shared.statusBarStyle = .lightContent
        AppearanceController.sharedController.initializeAppearance()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        //         Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if let currentUser = UserController.sharedController.currentUser {
            CloudKitController.sharedController.checkForNewETA(currentUser, completion: {
                guard let phoneNumberArray = UserDefaults.standard.value(forKey: "phoneNumberArrayForETA") as? [String] else { return }
                for phoneNumber in phoneNumberArray {
                    CloudKitController.sharedController.fetchETAAndSubscribe(phoneNumber)
                }
            })
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print(userInfo)
        handleRemoteNotification(userInfo)
        
        
    }
    
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        let info = userInfo["aps"] as! [String: AnyObject]
        let alertText = info["alert"] as! String
        switch alertText {
        case "You have been added as someone's contact":
            UserDefaults.standard.setValue("newContact", forKey: "newContact")
            if let currentUser = UserController.sharedController.currentUser {
                CloudKitController.sharedController.checkForNewContacts(currentUser, completion: { (users) in
                    guard let users = users else { return }
                    for user in users {
                        DispatchQueue.main.async(execute: { () -> Void in
                            let alert = NotificationController.sharedController.simpleAlert("\(user.name!) has added you as a contact" , message: "")
                            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
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

