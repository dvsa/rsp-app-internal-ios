//
//  DataManagerMock.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 20/12/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
@testable import DVSA_Officer_FPNs_App

class APIDataManagerMock: BaseAPIDataManager {

    var done = TestDone()

    var bodyModel = DataMock.shared.bodyModel
    var bodyModelUpdated = DataMock.shared.bodyModelUpdated
    var bodyModelToUpdate = DataMock.shared.bodyModelToUpdate
    var addedBodyModel = DataMock.shared.addedBodyModel
    var conflictedBodyModel = DataMock.shared.conflictedBodyModel
    var bodyListModel = DataMock.shared.bodyListModel
    var opResultListModel = DataMock.shared.opResultListModel
    var siteList = DataMock.shared.siteListModel
    var isResponseNotNil = true

    override func create(item: AWSBodyModel, completion: @escaping (AWSBodyModel?) -> Void) {
        done["create"] = true
        let response: AWSBodyModel? = isResponseNotNil ? bodyModel : nil
        completion(response)
    }

    override func read(for key: String, completion: @escaping (AWSBodyModel?) -> Void) {
        done["read"] = true
        let response: AWSBodyModel? = isResponseNotNil ? bodyModel : nil
        completion(response)
    }

    override func update(item: AWSBodyModel, completion: @escaping (AWSBodyModel?) -> Void) {
        done["update"] = true
        let response: AWSBodyModel? = isResponseNotNil ? bodyModelUpdated : nil
        completion(response)
    }

    override func delete(item: AWSBodyModel, completion: @escaping (AWSBodyModel?) -> Void) {
        done["delete"] = true
        let bodyModelDeleted = DataMock.shared.bodyModelUpdated?.copy() as? AWSBodyModel
        bodyModelDeleted?.enabled = false
        let response: AWSBodyModel? = isResponseNotNil ? bodyModelDeleted : nil
        completion(response)
    }

    override func list(datasource: NextIndexDatasource, completion: @escaping ([AWSBodyModel]?) -> Void) {
        done["list"] = true
        let response: [AWSBodyModel]? = isResponseNotNil ? bodyListModel?.items : nil
        completion(response)
    }

    override func sites(completion: @escaping ([AWSSiteModel]?) -> Void) {
        done["sites"] = true
        let response: [AWSSiteModel]? = isResponseNotNil ? siteList?.items : nil
        completion(response)
    }

    override func update(items: [AWSBodyModel], completion: @escaping (OpResultItems<AWSBodyModel>?) -> Void) {
        done["update"] = true
        let response: OpResultItems<AWSBodyModel>? = isResponseNotNil ? opResultListModel?.toOpResultItems() : nil
        completion(response)
    }
}
