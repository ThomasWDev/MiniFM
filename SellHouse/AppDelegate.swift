//
//  Appdelegate.swift
//  Minifm
//
//  Created by Thomas on 18/03/16.
//  Copyright © 2016 GF. All rights reserved.
//


import UIKit
import Parse
import ParseFacebookUtils

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        // Parse Conf.
        let configuration = ParseClientConfiguration {
            $0.applicationId = PARSE_APP_KEY
            $0.clientKey = PARSE_CLIENT_KEY
            $0.server = "https://minifmproduction.back4app.io"//"https://minifm.back4app.io"
        }
        Parse.initialize(with: configuration)
        PFFacebookUtils.initializeFacebook()
        UINavigationBar.appearance().titleTextAttributes = TEXT_ATTRIBUTE.navigationBarTextAttribute
        //Set Colors
        UINavigationBar.appearance().barTintColor = UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1.0)
        
        // TabBar Icon Colors
        UITabBar.appearance().tintColor = UIColor(red: 59/255.0, green: 187/255.0, blue: 246/255.0, alpha: 1.0)
        UIBarButtonItem.appearance().setTitleTextAttributes(TEXT_ATTRIBUTE.navigationBarTextAttribute, for: .normal)
        
        
        // FOR PUSH NOTIFICATIONS WITH ONE SIGNAL SERVICE (http://onesignal.com)
        OneSignal.initWithLaunchOptions(launchOptions, appId: ONESIGNAL_APP_ID, handleNotificationReceived:nil, handleNotificationAction:nil,
                                        settings: [kOSSettingsKeyInAppAlerts: true, kOSSettingsKeyAutoPrompt: true])
        //Paypal
        PayPalMobile.initializeWithClientIds(forEnvironments:
            [PayPalEnvironmentSandbox: "ARZEOYBKIZk-UVoC70dh4rO84VJN6jsj2k3MMUaegnt-zBGplbKoW9i8cRfJCQiqt5wwooIGjf0bBXQj"])
        
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBAppCall.handleOpen(url, sourceApplication: sourceApplication, with: PFFacebookUtils.session())
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
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

