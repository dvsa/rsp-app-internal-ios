//
//  AppDelegate.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 28/09/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit
import AWSAuthCore
import Compass
import AWSAuthUI
import Fabric
import Crashlytics
import ADAL
import IQKeyboardManagerSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var isInitialized: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        #if DEBUG
            ADLogger.setLevel(ADAL_LOG_LEVEL_VERBOSE)
            AWSDDLog.sharedInstance.logLevel = .verbose
        #else
            ADLogger.setLevel(ADAL_LOG_LEVEL_ERROR)
            AWSDDLog.sharedInstance.logLevel = .error
        #endif
        ADAuthenticationSettings.sharedInstance().setDefaultKeychainGroup(nil)

        //AWS
        AWSSignInManager.sharedInstance().register(signInProvider: AWSADALSignInProvider.sharedInstance())

        let didFinishLaunching = AWSSignInManager.sharedInstance().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)

        if !isInitialized {
            AWSSignInManager.sharedInstance().resumeSession(completionHandler: { (result: Any?, error: Error?) in
                if let result = result {
                    #if DEBUG
                    //Warning: It logs AWS Credentials
                    log.verbose(result)
                    #endif
                }

                if let error = error {
                    log.error(error)
                }
            })
            isInitialized = true
        }

        //Fabric
        Fabric.with([Crashlytics.self])

        //Realm
        WhistleReachability.shared.startReachability()
        SynchronizationManager.setup()

        //Style
        StyleManager.applyStyle()

        //IQKeyboardManager
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().canAdjustAdditionalSafeAreaInsets = true

        //Root Flow Controller
        let navigator = NavigatorManager.shared

        window = UIWindow(frame: UIScreen.main.bounds)

        let configure = FlowConfigure(window: window, navigationController: nil, parent: nil)
        let mainFlow = RootFlowController(configure: configure)
        navigator.assignFlowController(rootFlowController: mainFlow)
        mainFlow.start()

        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        UIApplication.shared.applicationIconBadgeNumber = 0

        return AWSSNSManager.shared.application(application, didFinishLaunchingWithOptions: launchOptions) && didFinishLaunching
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // swiftlint:disable:next line_length
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state. Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // swiftlint:disable:next line_length
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // swiftlint:disable:next line_length
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // swiftlint:disable:next line_length
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        SettingsBundleManager.setVersionAndBuildNumber()
        DispatchQueue.global(qos: .background).async { () in
            let datasource = PersistentDataSource()
            try? datasource.removeExpiredDocuments(offset: Environment.retentionOffset)
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: Deep Linking
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            let navigator = NavigatorManager.shared
            if let url = userActivity.webpageURL {
                return navigator.handle(url: url)
            }
        }
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let navigator = NavigatorManager.shared
        return navigator.handle(url: url)
    }

    // MARK: Push Notification
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        AWSSNSManager.shared.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        AWSSNSManager.shared.application(application, didFailToRegisterForRemoteNotificationsWithError: error as NSError)
    }

    // MARK: Background Fetch
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        log.info("Background Fetch")
        completionHandler(UIBackgroundFetchResult.newData)
    }

    // MARK: Remote Notificarion with content-available
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        //content-available: 1 in the message
        log.info("Remote notification")
        log.debug(userInfo)

        if let currentSite = PreferencesDataSource.shared.site()?.code,
            let notificationRequest = NotificationUtils.notificationRequest(userInfo: userInfo, siteCode: currentSite) {
            UNUserNotificationCenter.current().add(notificationRequest, withCompletionHandler: nil)
            log.info("show notification")
            completionHandler(UIBackgroundFetchResult.newData)
        } else if let offset = NotificationUtils.silentOffset(userInfo: userInfo) {
            log.info("sync notification")
            SynchronizationManager.shared.startSync(offset: offset, performFetchWithCompletionHandler: completionHandler)
        } else {
            log.warning("notification ignored")
            completionHandler(UIBackgroundFetchResult.noData)
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    // MARK: Background Transfer
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        log.info("Background Trasnsfer")
        log.debug(identifier)
        completionHandler()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    // called when user interacts with notification (app not running in foreground)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // the docs say you should execute this asap
        log.info("didReceiveNotifcation")
        completionHandler()
    }

    // called if app is running in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // show alert while app is running in foreground
        completionHandler(UNNotificationPresentationOptions.alert)
    }
}
