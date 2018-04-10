//
//  CognitoSignInManager.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 31/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit
import AWSCore
import AWSAuthUI

class CognitoSignInManager: SignInManagerProtocol {
    static let shared = CognitoSignInManager()

    func isLoggedIn(completion: @escaping (Bool, SignInToken) -> Void) {
        completion(AWSSignInManager.sharedInstance().isLoggedIn, .cognito)
    }

    func login(completion: @escaping (Bool, SignInToken) -> Void) {

        guard let window = UIApplication.shared.delegate?.window else { return }
        guard let rootNavigationController = window?.rootViewController as? UINavigationController else { return }

        if !AWSSignInManager.sharedInstance().isLoggedIn {
            let config = AWSAuthUIConfiguration()
            config.enableUserPoolsUI = false
            config.addSignInButtonView(class: AWSADALSignInButton.self)
            config.canCancel = false
            config.logoImage = UIImage(named: "dvsaRspLogoPadding")
            config.backgroundColor = UIColor.black
            AWSAuthUIViewController.presentViewController(with: rootNavigationController,
                                                          configuration: config) { (_, error: Error?) in
                if error != nil {
                    log.error(error)
                    completion(false, .cognito)
                } else {
                    log.info("login completion is true with cognito")
                    completion(true, .cognito)
                }
            }
        }
    }

    func getOpenIdToken(completion: @escaping (AWSCognitoIdentityGetOpenIdTokenResponse) -> Void) {

        let identityManager = AWSIdentityManager.default()
        let identityID = identityManager.identityId ?? ""
        let credentialsProvider = identityManager.credentialsProvider
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration

        AWSIdentityManager.default().logins().continueOnSuccessWith { (task) -> AWSTask<AWSCognitoIdentityGetOpenIdTokenInput>? in
            if let logins = task.result as? [String: String] {
                let input = AWSCognitoIdentityGetOpenIdTokenInput()!
                input.identityId = identityID as String
                input.logins = logins
                return  AWSTask<AWSCognitoIdentityGetOpenIdTokenInput>(result: input)
            } else if let error = task.error {
                return AWSTask(error: error)
            } else {
                let error = NSError(domain: "CognitoSignInManager", code: 400, userInfo: [:])
                return AWSTask(error: error)
            }
        }.continueWith { (task) ->  AWSTask<AWSCognitoIdentityGetOpenIdTokenResponse> in
            if let input = task.result as? AWSCognitoIdentityGetOpenIdTokenInput {
                return AWSCognitoIdentity.default().getOpenIdToken(input)
            } else if let error = task.error {
                return AWSTask(error: error)
            } else {
                let error = NSError(domain: "CognitoSignInManager", code: 400, userInfo: [:])
                return AWSTask(error: error)
            }
        }.continueWith { (task) -> Void in
            if let tokenResponse =  task.result as? AWSCognitoIdentityGetOpenIdTokenResponse {
                log.debug("Token: " + (tokenResponse.token ?? ""))
                completion(tokenResponse)
            } else if task.error != nil {
                log.error(task.error)
            }
        }
    }

    func logout(completion: @escaping (Bool) -> Void) {
        if AWSSignInManager.sharedInstance().isLoggedIn {
            AWSSignInManager.sharedInstance().logout { result, error  in

                if error != nil {
                    log.error(error)
                    AWSIdentityManager.default().credentialsProvider.clearCredentials()
                    AWSIdentityManager.default().credentialsProvider.clearKeychain()
                    completion(false)
                    return
                }
                AWSIdentityManager.default().credentialsProvider.clearCredentials()
                AWSIdentityManager.default().credentialsProvider.clearKeychain()
                log.info("logout with completion true")
                log.info(result)
                completion(true)
            }
        } else {
            log.info("logout with completion false")
            AWSIdentityManager.default().credentialsProvider.clearCredentials()
            AWSIdentityManager.default().credentialsProvider.clearKeychain()
            completion(false)
        }
    }
}

struct SignInManagerGetterCognito: SignInManagerGetterProtocol {
    func get() -> SignInManagerProtocol {
        return CognitoSignInManager.shared
    }
}
