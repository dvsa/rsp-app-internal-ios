//
//  AWSMobileNotifyAPIClient.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 16/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import AWSCore
import AWSAPIGateway

protocol APINotifyServiceProtcol {
    func sendSMS(body: AWSNotifySMSModel) -> AWSTask<AnyObject>
    func sendEmail(body: AWSNotifyEmailModel) -> AWSTask<AnyObject>
}

public class AWSMobileNotifyAPIClient: AWSAPIGatewayClient, APINotifyServiceProtcol {

    static let AWSInfoClientKey = "IdentityManager"

    private static let _serviceClients = AWSSynchronizedMutableDictionary()
    private static let _defaultClient: AWSMobileNotifyAPIClient = {
        var serviceConfiguration: AWSServiceConfiguration? = nil
        let serviceInfo = AWSInfo.default().defaultServiceInfo(AWSInfoClientKey)
        if let serviceInfo = serviceInfo {
            serviceConfiguration = AWSServiceConfiguration(region: serviceInfo.region, credentialsProvider: serviceInfo.cognitoCredentialsProvider)
        } else if AWSServiceManager.default().defaultServiceConfiguration != nil {
            serviceConfiguration = AWSServiceManager.default().defaultServiceConfiguration
        } else {
            serviceConfiguration = AWSServiceConfiguration(region: .Unknown, credentialsProvider: nil)
        }
        return AWSMobileNotifyAPIClient(configuration: serviceConfiguration!)
    }()

    public class func `default`() -> AWSMobileNotifyAPIClient {
        return _defaultClient
    }

    public class func registerClient(withConfiguration configuration: AWSServiceConfiguration, forKey key: String) {
        _serviceClients.setObject(AWSMobileNotifyAPIClient(configuration: configuration), forKey: key  as NSString)
    }

    public class func client(forKey key: String) -> AWSMobileNotifyAPIClient {
        objc_sync_enter(self)
        if let client: AWSMobileNotifyAPIClient = _serviceClients.object(forKey: key) as? AWSMobileNotifyAPIClient {
            objc_sync_exit(self)
            return client
        }

        let serviceInfo = AWSInfo.default().defaultServiceInfo(AWSInfoClientKey)
        if let serviceInfo = serviceInfo {
            let serviceConfiguration = AWSServiceConfiguration(region: serviceInfo.region,
                                                               credentialsProvider: serviceInfo.cognitoCredentialsProvider)
            AWSMobileNotifyAPIClient.registerClient(withConfiguration: serviceConfiguration!, forKey: key)
        }
        objc_sync_exit(self)

        if let result = _serviceClients.object(forKey: key) as? AWSMobileNotifyAPIClient {
            return result
        } else {
            return AWSMobileNotifyAPIClient(configuration: AWSServiceConfiguration.init())
        }
    }

    public class func removeClient(forKey key: String) {
        _serviceClients.remove(key)
    }

    init(configuration: AWSServiceConfiguration) {
        super.init()

        if let copy = configuration.copy() as? AWSServiceConfiguration {
            self.configuration = copy
        }
        var URLString: String = Environment.notifyAPIEndpoint
        if URLString.hasSuffix("/") {
            let index = URLString.index(before: URLString.endIndex)
            URLString = String(URLString[..<index])
        }
        self.configuration.endpoint = AWSEndpoint(region: configuration.regionType,
                                                  service: .APIGateway,
                                                  url: URL(string: URLString))
        let signer: AWSSignatureV4Signer = AWSSignatureV4Signer(credentialsProvider: configuration.credentialsProvider,
                                                                endpoint: self.configuration.endpoint)
        if let endpoint = self.configuration.endpoint {
            self.configuration.baseURL = endpoint.url
        }
        self.configuration.requestInterceptors = [AWSNetworkingRequestInterceptor(), signer]
    }

    public func sendSMS(body: AWSNotifySMSModel) -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let queryParameters: [String: Any] = [:]
        let pathParameters: [String: Any] = [:]

        return self.invokeHTTPRequest("POST",
                                      urlString: "/notifySms",
                                      pathParameters: pathParameters,
                                      queryParameters: queryParameters,
                                      headerParameters: headerParameters,
                                      body: body,
                                      responseClass: nil)
    }

    public func sendEmail(body: AWSNotifyEmailModel) -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let queryParameters: [String: Any] = [:]
        let pathParameters: [String: Any] = [:]

        return self.invokeHTTPRequest("POST",
                                      urlString: "/notifyEmail",
                                      pathParameters: pathParameters,
                                      queryParameters: queryParameters,
                                      headerParameters: headerParameters,
                                      body: body,
                                      responseClass: nil)
    }
}
