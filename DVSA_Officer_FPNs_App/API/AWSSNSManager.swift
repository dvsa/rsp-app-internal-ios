//
//  SNSManager.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 01/12/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit
import AWSSNS
import UserNotifications

protocol AWSSNSManagerDelegate: class {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) -> Bool
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError)
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    func registerToken(user: String?)
    func unsubscribe(completion: @escaping (Bool) -> Void)
}

class AWSSNSManager: NSObject, AWSSNSManagerDelegate {
    static let shared = AWSSNSManager()

    internal var keyChain: AWSUICKeyChainStore

    struct Key {
        static let deviceToken = "DeviceToken.AWSSNSManager"
        static let subscriptionArn = "subscriptionArn.AWSSNSManager"
        static let endpointArn = "endpointArn"
    }

    var subscriptionArn: String? {
        get {
            return UserDefaults.standard.string(forKey: Key.subscriptionArn)
        }

        set (newSubscriptionArn) {
            UserDefaults.standard.set(newSubscriptionArn, forKey: Key.subscriptionArn)
            UserDefaults.standard.synchronize()
        }
    }

    var endpointArn: String? {
        get {
            return UserDefaults.standard.string(forKey: Key.endpointArn)
        }

        set (newEndpointArn) {
            UserDefaults.standard.set(newEndpointArn, forKey: Key.endpointArn)
            UserDefaults.standard.synchronize()
        }
    }

    override init() {
        self.keyChain = AWSUICKeyChainStore(service: Bundle.main.bundleIdentifier)
        super.init()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) -> Bool {

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, _) in
            log.info("Notification permission granted: \(granted)")
        }
        if let delegate = application.delegate as? UNUserNotificationCenterDelegate {
            UNUserNotificationCenter.current().delegate = delegate
        }
        UIApplication.shared.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

        var tokenString = ""
        for value in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [deviceToken[value]])
        }
        log.debug("tokenString: \(tokenString)")
        self.keyChain[Key.deviceToken] = tokenString
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        log.error("Failed to register with error: \(error)")
        self.keyChain.removeItem(forKey: Key.deviceToken)
    }

    internal func creatEndpointIfRequired(sns: AWSSNS, deviceToken: String) -> AWSTask<AnyObject> {

        var task = AWSTask<AnyObject>(result: nil)
        if self.endpointArn == nil {
            // # first time registration
            task = task.continueOnSuccessWith { (task) -> Any? in

                let request = AWSSNSCreatePlatformEndpointInput()!
                request.token = deviceToken
                request.platformApplicationArn = Environment.awsSNSPlatformApplicationArn()

                // call CreatePlatformEndpoint
                return sns.createPlatformEndpoint(request).continueOnSuccessWith { task -> AWSTask<AWSSNSSubscribeResponse>? in
                    if let createEndpointResponse = task.result {
                        log.debug("endpointArn: \(String(describing: createEndpointResponse.endpointArn))")

                        // store returned endpoint arn
                        self.endpointArn = createEndpointResponse.endpointArn
                    }
                    return nil
                }
            }
        }
        return task
    }

    internal func getEndpointAttributes(sns: AWSSNS, task: AWSTask<AnyObject>) -> AWSTask<AWSSNSGetEndpointAttributesResponse>? {
        if let error = task.error {
            log.error(error)
        } else {
            // call GetEndpointAttributes on the endpoint arn
            let requestAttribute = AWSSNSGetEndpointAttributesInput()!
            requestAttribute.endpointArn = self.endpointArn
            return sns.getEndpointAttributes(requestAttribute)
        }
        return nil
    }

    internal func updateEndpointAttributes(user: String?, sns: AWSSNS, deviceToken: String, task: AWSTask<AnyObject>) -> AWSTask<AnyObject>? {
        if let error = task.error as NSError?,
            error.domain == AWSSNSErrorDomain && error.code == AWSSNSErrorType.notFound.rawValue {
            // #endpoint was deleted

            let request = AWSSNSCreatePlatformEndpointInput()!
            request.token = deviceToken
            request.platformApplicationArn = Environment.awsSNSPlatformApplicationArn()
            // call CreatePlatformEndpoint
            return sns.createPlatformEndpoint(request).continueOnSuccessWith { task -> AWSTask<AWSSNSSubscribeResponse>? in
                if let createEndpointResponse = task.result {
                    log.debug("endpointArn: \(String(describing: createEndpointResponse.endpointArn))")

                    // store returned endpoint arn
                    self.endpointArn = createEndpointResponse.endpointArn
                }
                return nil
            }
        }
        if let getEndpointAttributesResponse = task.result as? AWSSNSGetEndpointAttributesResponse {

            // call SetEndpointAttributes to set the latest token and enable the endpoint
            var attributes = getEndpointAttributesResponse.attributes ?? [:]
            attributes["CustomUserData"] = user
            attributes["Enabled"] = "true"
            attributes["Token"] = deviceToken
            getEndpointAttributesResponse.attributes = attributes

            let requestAttribute = AWSSNSSetEndpointAttributesInput()!
            requestAttribute.endpointArn = self.endpointArn
            requestAttribute.attributes = attributes
            return sns.setEndpointAttributes(requestAttribute)
        }
        return nil
    }

    internal func subscribeTopic(sns: AWSSNS, task: AWSTask<AnyObject>) -> AWSTask<AWSSNSSubscribeResponse>? {

        if let error = task.error {
            log.error(error)
        } else {
            if let endpointArn = self.endpointArn {
                let request = self.subscribeTopicRequest(endpointArn: endpointArn)
                return sns.subscribe(request)
            }
            log.warning("endpointArn is nil")
        }
        return nil
    }

    internal func saveSubscriptionARN(task: AWSTask<AnyObject>) -> AWSTask<AnyObject>? {
        guard let response = task.result as? AWSSNSSubscribeResponse else {
            return nil
        }
        if let subscriptionArn = response.subscriptionArn {
            self.subscriptionArn = subscriptionArn
            log.info("Topic \(subscriptionArn) subscribed!")
        }
        return nil
    }

    func registerToken(user: String?) {

        let sns = AWSSNS.default()

        guard let deviceToken = self.keyChain[Key.deviceToken] else {
            log.error("Error: APNs Token is nil")
            log.error("You need a real device to test APNs")
            return
        }

        let task = creatEndpointIfRequired(sns: sns, deviceToken: deviceToken)
        task.continueWith { (task) -> Any? in
            return self.getEndpointAttributes(sns: sns, task: task)
        }.continueWith { (task) -> Any? in
            return self.updateEndpointAttributes(user: user, sns: sns, deviceToken: deviceToken, task: task)
        }.continueWith { (task) -> Any? in
            return self.subscribeTopic(sns: sns, task: task)
        }.continueWith { (task) -> Any? in
           return self.saveSubscriptionARN(task: task)
        }
    }

    func unsubscribe(completion: @escaping (Bool) -> Void) {

        guard let subscriptionArn = self.subscriptionArn else {
            log.error("subscriptionArn is nil")
            completion(false)
            return
        }

        let unsubscribeRequest = unsubscribeTopicRequest(subscriptionArn: subscriptionArn)
        let sns = AWSSNS.default()
        sns.unsubscribe(unsubscribeRequest).continueWith { (task) -> Any? in
            if let error = task.error {
                log.error(error)
                completion(false)
            } else {
                self.subscriptionArn = nil
                log.info("unsubscribeTopicRequest succeded")
                completion(true)
            }
            return nil
        }
    }

    internal func subscribeTopicRequest(endpointArn: String) -> AWSSNSSubscribeInput {
        let subscribeRequest = AWSSNSSubscribeInput()!
        subscribeRequest.endpoint = endpointArn
        subscribeRequest.protocols = "application"
        subscribeRequest.topicArn = Environment.awsSNSPlatformTopic
        return subscribeRequest
    }

    internal func unsubscribeTopicRequest(subscriptionArn: String) -> AWSSNSUnsubscribeInput {
        let unsubscribeRequest = AWSSNSUnsubscribeInput()!
        unsubscribeRequest.subscriptionArn = subscriptionArn
        return unsubscribeRequest
    }

    internal func confirmSubscritpionRequest(token: String) -> AWSSNSConfirmSubscriptionInput {
        let confirmRequest = AWSSNSConfirmSubscriptionInput()!
        confirmRequest.token = token
        confirmRequest.topicArn = Environment.awsSNSPlatformTopic
        return confirmRequest
    }
}
