//
//  AWSMobileBackendAPIClient.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 23/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import AWSCore
import AWSAPIGateway

protocol APIServiceProtcol {
    func documentIDGet(key: String) -> AWSTask<AnyObject>
    func documentIDPut(key: String, body: AWSBodyModel) -> AWSTask<AnyObject>
    func documentIDPost(key: String, body: AWSBodyModel) -> AWSTask<AnyObject>
    func documentIDDelete(key: String, body: AWSBodyModel) -> AWSTask<AnyObject>
    func documentsGet(offset: TimeInterval?, nextOffset: TimeInterval?, nextID: String?) -> AWSTask<AnyObject>
    func sitesGet() -> AWSTask<AnyObject>
    func documentsPost(body: AWSBodyListModel) -> AWSTask<AnyObject>
}

public class AWSMobileBackendAPIClient: AWSAPIGatewayClient, APIServiceProtcol {

	static let AWSInfoClientKey = "IdentityManager"

	private static let _serviceClients = AWSSynchronizedMutableDictionary()
	private static let _defaultClient: AWSMobileBackendAPIClient = {
		var serviceConfiguration: AWSServiceConfiguration? = nil
        let serviceInfo = AWSInfo.default().defaultServiceInfo(AWSInfoClientKey)
        if let serviceInfo = serviceInfo {
            serviceConfiguration = AWSServiceConfiguration(region: serviceInfo.region, credentialsProvider: serviceInfo.cognitoCredentialsProvider)
        } else if AWSServiceManager.default().defaultServiceConfiguration != nil {
            serviceConfiguration = AWSServiceManager.default().defaultServiceConfiguration
        } else {
            serviceConfiguration = AWSServiceConfiguration(region: .Unknown, credentialsProvider: nil)
        }

        return AWSMobileBackendAPIClient(configuration: serviceConfiguration!)
	}()

	public class func `default`() -> AWSMobileBackendAPIClient {
		return _defaultClient
	}

	public class func registerClient(withConfiguration configuration: AWSServiceConfiguration, forKey key: String) {
		_serviceClients.setObject(AWSMobileBackendAPIClient(configuration: configuration), forKey: key  as NSString)
	}

	public class func client(forKey key: String) -> AWSMobileBackendAPIClient {
		objc_sync_enter(self)
		if let client: AWSMobileBackendAPIClient = _serviceClients.object(forKey: key) as? AWSMobileBackendAPIClient {
			objc_sync_exit(self)
		    return client
		}

		let serviceInfo = AWSInfo.default().defaultServiceInfo(AWSInfoClientKey)
		if let serviceInfo = serviceInfo {
			let serviceConfiguration = AWSServiceConfiguration(region: serviceInfo.region, credentialsProvider: serviceInfo.cognitoCredentialsProvider)
			AWSMobileBackendAPIClient.registerClient(withConfiguration: serviceConfiguration!, forKey: key)
		}
		objc_sync_exit(self)

        if let result = _serviceClients.object(forKey: key) as? AWSMobileBackendAPIClient {
            return result
        } else {
            return AWSMobileBackendAPIClient(configuration: AWSServiceConfiguration.init())
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
	    var URLString: String = Environment.synchAPIEndpoint
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

    public func documentIDGet(key: String) -> AWSTask<AnyObject> {
	    let headerParameters = [
                   "Content-Type": "application/json",
                   "Accept": "application/json"
	            ]
	    let queryParameters: [String: Any] = [:]
	    let pathParameters: [String: Any] = ["iD": key]

	    return self.invokeHTTPRequest("GET",
                                      urlString: "/documents/{iD}",
                                      pathParameters: pathParameters,
                                      queryParameters: queryParameters,
                                      headerParameters: headerParameters,
                                      body: nil,
                                      responseClass: AWSBodyModel.self)
	}

    public func documentIDPut(key: String, body: AWSBodyModel) -> AWSTask<AnyObject> {
	    let headerParameters = [
                   "Content-Type": "application/json",
                   "Accept": "application/json"

	            ]

	    let queryParameters: [String: Any] = [:]

	    let pathParameters: [String: Any] = ["iD": key]

	    return self.invokeHTTPRequest("PUT",
                                      urlString: "/documents/{iD}",
                                      pathParameters: pathParameters,
                                      queryParameters: queryParameters,
                                      headerParameters: headerParameters,
                                      body: body,
                                      responseClass: AWSBodyModel.self)
	}

    public func documentIDPost(key: String, body: AWSBodyModel) -> AWSTask<AnyObject> {
	    let headerParameters = [
                   "Content-Type": "application/json",
                   "Accept": "application/json"

	            ]
	    let queryParameters: [String: Any] = [:]
	    let pathParameters: [String: Any] = [:]
	    return self.invokeHTTPRequest("POST",
                                      urlString: "/documents",
                                      pathParameters: pathParameters,
                                      queryParameters: queryParameters,
                                      headerParameters: headerParameters,
                                      body: body,
                                      responseClass: AWSBodyModel.self)
	}

    public func documentIDDelete(key: String, body: AWSBodyModel) -> AWSTask<AnyObject> {
	    let headerParameters = [
                   "Content-Type": "application/json",
                   "Accept": "application/json"
	            ]
	    let queryParameters: [String: Any] = [:]
	    let pathParameters: [String: Any] = ["iD": key]
        return self.invokeHTTPRequest("DELETE",
                                      urlString: "/documents/{iD}",
                                      pathParameters: pathParameters,
                                      queryParameters: queryParameters,
                                      headerParameters: headerParameters,
                                      body: body,
                                      responseClass: AWSBodyModel.self)
	}

    public func documentsGet(offset: TimeInterval?, nextOffset: TimeInterval?, nextID: String?) -> AWSTask<AnyObject> {
	    let headerParameters = [
                   "Content-Type": "application/json",
                   "Accept": "application/json"
	            ]
	    var queryParameters: [String: Any] = [:]
        if let offset = offset {
            queryParameters["Offset"] = NSNumber(value: offset)
        }
        if let nextID = nextID {
            queryParameters["NextID"] = nextID
        }
        if let nextOffset = nextOffset {
            queryParameters["NextOffset"] = nextOffset
        }

	    let pathParameters: [String: Any] = [:]
        return self.invokeHTTPRequest("GET",
                                      urlString: "/documents",
                                      pathParameters: pathParameters,
                                      queryParameters: queryParameters,
                                      headerParameters: headerParameters,
                                      body: nil,
                                      responseClass: AWSBodyListModel.self)
	}

    public func documentsPost(body: AWSBodyListModel) -> AWSTask<AnyObject> {
	    let headerParameters = [
                   "Content-Type": "application/json",
                   "Accept": "application/json"
	            ]
	    let queryParameters: [String: Any] = [:]
	    let pathParameters: [String: Any] = [:]

	    return self.invokeHTTPRequest("PUT",
                                      urlString: "/documents",
                                      pathParameters: pathParameters,
                                      queryParameters: queryParameters,
                                      headerParameters: headerParameters,
                                      body: body,
                                      responseClass: AWSOperationResultListModel.self)
	}

    public func helloGet() -> AWSTask<AnyObject> {
	    let headerParameters = [
                   "Content-Type": "application/json",
                   "Accept": "application/json"
	            ]
	    let queryParameters: [String: Any] = [:]
	    let pathParameters: [String: Any] = [:]

	    return self.invokeHTTPRequest("GET",
                                      urlString: "/hello",
                                      pathParameters: pathParameters,
                                      queryParameters: queryParameters,
                                      headerParameters: headerParameters,
                                      body: nil,
                                      responseClass: nil)
	}

    public func sitesGet() -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let queryParameters: [String: Any] = [:]
        let pathParameters: [String: Any] = [:]

        return self.invokeHTTPRequest("GET",
                                      urlString: "/sites",
                                      pathParameters: pathParameters,
                                      queryParameters: queryParameters,
                                      headerParameters: headerParameters,
                                      body: nil,
                                      responseClass: AWSSiteListModel.self)
    }

    public func sendSMS(body: AWSNotifySMSModel) -> AWSTask<AnyObject> {
        let headerParameters = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let queryParameters: [String: Any] = [:]
        let pathParameters: [String: Any] = [:]

        return self.invokeHTTPRequest("POST",
                                      urlString: "/notifysms",
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
                                      urlString: "/notifyemail",
                                      pathParameters: pathParameters,
                                      queryParameters: queryParameters,
                                      headerParameters: headerParameters,
                                      body: body,
                                      responseClass: nil)
    }
}
