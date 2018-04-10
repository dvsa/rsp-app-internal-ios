//
//  Environment.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 04/04/2018.
//  Copyright © 2018 BJSS. All rights reserved.
//

//NOTE: Uncomment the class Environment and set the configuration parameters {ENV_...}

//import Foundation
//
//class Environment: NSObject {
//
//    @nonobjc static let tokenEncryptionKey: [UInt32] = [0x00, 0x00]
//    @objc static let adalAuthority = "https://login.microsoftonline.com/common"
//
//    @objc static func adalRedirectURI() -> String {
//        return EnvironmentService.getValueForKey("kAdalRedirectURI")
//    }
//
//    @objc static func awsSNSPlatformApplicationArn() -> String {
//        return EnvironmentService.getValueForKey("kSNSPlatformApplicationArn")
//    }
//
//    @objc static func bundleURLSchema() -> String {
//        return EnvironmentService.getValueForKey("kBundleUrlSchema")
//    }
//
//    static let supportEmail: String? = "{ENV_SUPPORT_EMAIL}"
//    static let retentionOffset: TimeInterval = 72*60*60
//
//     // MARK: - ADAL - DEV - Configuration
//    //Refer to https://docs.microsoft.com/en-us/azure/active-directory/develop/active-directory-devquickstarts-ios
//
//    @objc static let adalClientId = "{ENV_ADAL_CLIENT_ID_PROD}"
//    @objc static let adalOIDCProvider = "{ENV_AWS_ADAL_OIDC_PROVIDER_PROD}"
//    @objc static let adalResource = "{ENV_ADAL_RESOURCE_PROD}"
//
//    // MARK: - AWS - DEV - Configuration
//    static let synchAPIEndpoint = "{ENV_SYNCH_API_ENDPOINT_PROD}"
//    static let notifyAPIEndpoint = "{ENV_NOTIFY_API_ENDPOINT_PROD}"
//    static let awsSNSPlatformTopic = "{ENV_SNSPlatformTopic_PROD}"
//}
