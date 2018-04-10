//
//  APIServiceMock.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 03/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
@testable import DVSA_Officer_FPNs_App

class APIServiceMock: APIServiceProtcol {

    var isValidModel: Bool = true
    var error: Error?

    func setupWithError() {
        self.isValidModel = false
        self.error = NSError(domain: "Test", code: 100, userInfo: [:])
    }

    func documentIDGet(key: String) -> AWSTask<AnyObject> {
        if isValidModel {
            return AWSTask(result: DataMock.shared.bodyModel)
        } else if let error = self.error {
            return AWSTask(error: error)
        } else {
            return AWSTask(result: NSObject())
        }
    }

    func documentIDPut(key: String, body: AWSBodyModel) -> AWSTask<AnyObject> {
        if isValidModel {
            return AWSTask(result: DataMock.shared.bodyModel)
        } else if let error = self.error {
            return AWSTask(error: error)
        } else {
            return AWSTask(result: NSObject())
        }
    }

    func documentIDPost(key: String, body: AWSBodyModel) -> AWSTask<AnyObject> {
        if isValidModel {
            return AWSTask(result: DataMock.shared.bodyModel)
        } else if let error = self.error {
            return AWSTask(error: error)
        } else {
            return AWSTask(result: NSObject())
        }
    }

    func documentIDDelete(key: String, body: AWSBodyModel) -> AWSTask<AnyObject> {
        if isValidModel {
            return AWSTask(result: DataMock.shared.bodyModel)
        } else if let error = self.error {
            return AWSTask(error: error)
        } else {
            return AWSTask(result: NSObject())
        }
    }

    func documentsGet(offset: TimeInterval?, nextOffset: TimeInterval?, nextID: String?) -> AWSTask<AnyObject> {
        if isValidModel {

            guard let offset = offset else {
                return AWSTask(result: DataMock.shared.bodyListModel)
            }

            let maxSize = 10
            let items = DataMock.shared.bodyListModel?.items?.filter { (model) -> Bool in
                if let mOffset = model.offset {
                    if let key = model.key,
                        let nextID = nextID {
                        return mOffset.timeIntervalSince1970 >= offset && key > nextID
                    }
                    return mOffset.timeIntervalSince1970 >= offset
                } else {
                    return true
                }
                }.sorted(by: { (model1, model2) -> Bool in
                    let key1 = model1.key ?? ""
                    let key2 = model2.key ?? ""
                    return key1 < key2
                })

            let len = min(items?.count ?? 0, maxSize)

            let batchItems = Array(items![0...len - 1])

            let bodyListModel = AWSBodyListModel()
            bodyListModel?.items = batchItems
            let nextIndex = AWSNextIndexModel()
            nextIndex?.nextID = len < maxSize ? nil : batchItems.last?.key
            nextIndex?.nextOffset = len < maxSize ? nil : batchItems.last?.offset
            bodyListModel?.nextOperation = nextIndex

            return AWSTask(result: bodyListModel)
        } else if let error = self.error {
            return AWSTask(error: error)
        } else {
            return AWSTask(result: NSObject())
        }
    }

    func documentsPost(body: AWSBodyListModel) -> AWSTask<AnyObject> {
        if isValidModel {
            return AWSTask(result: DataMock.shared.opResultListModel)
        } else if let error = self.error {
            return AWSTask(error: error)
        } else {
            return AWSTask(result: NSObject())
        }
    }

    func sitesGet() -> AWSTask<AnyObject> {
        if isValidModel {
            return AWSTask(result: DataMock.shared.siteListModel)
        } else if let error = self.error {
            return AWSTask(error: error)
        } else {
            return AWSTask(result: NSObject())
        }
    }

}
