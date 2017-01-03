//
//  AppDelegate.swift
//  HomeSafe
//
//  Created by Spencer Curtis on 5/16/16.
//  Copyright © 2016 Spencer Curtis. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
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
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (_, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                application.registerForRemoteNotifications()
            }
        }
        UNUserNotificationCenter.current().delegate = self
        
        
        UIApplication.shared.statusBarStyle = .lightContent
        AppearanceController.sharedController.initializeAppearance()
        return true
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
