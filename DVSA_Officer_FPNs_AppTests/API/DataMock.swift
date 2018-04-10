//
//  DataMock.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 20/12/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
@testable import DVSA_Officer_FPNs_App

class DataMock {
    var bodyModel = AWSBodyModel()
    var addedBodyModel = AWSBodyModel()
    var conflictedBodyModel = AWSBodyModel()
    var bodyModelToUpdate = AWSBodyModel()
    var bodyModelUpdated = AWSBodyModel()
    var bodyListModel = AWSBodyListModel()
    var opResultListModel = AWSOperationResultListModel()
    var siteModel = AWSSiteModel()
    var siteListModel = AWSSiteListModel()
    var notifySMSModel = AWSNotifySMSModel()
    var notifyEmailModel = AWSNotifyEmailModel()

    static let shared = DataMock()

    init() {
        let bodyDictionary = JSONUtils().loadJSONDictionary(resource: "AWSBody")
        let bodyAdapter = try? AWSMTLJSONAdapter(jsonDictionary: bodyDictionary, modelClass: AWSBodyModel.self)
        bodyModel = bodyAdapter?.model as? AWSBodyModel

        let bodyListDictionary = JSONUtils().loadJSONDictionary(resource: "AWSGetDocumentsResponse")
        let bodyListAdapter = try? AWSMTLJSONAdapter(jsonDictionary: bodyListDictionary, modelClass: AWSBodyListModel.self)
        bodyListModel = bodyListAdapter?.model as? AWSBodyListModel

        let opResultItemsDictionary = JSONUtils().loadJSONDictionary(resource: "AWSPostDocumentsResponse")
        let opResultItemsAdapter = try? AWSMTLJSONAdapter(jsonDictionary: opResultItemsDictionary, modelClass: AWSOperationResultListModel.self)
        opResultListModel = opResultItemsAdapter?.model as? AWSOperationResultListModel

        let siteListDictionary = JSONUtils().loadJSONDictionary(resource: "AWSSites")
        let siteListAdapter = try? AWSMTLJSONAdapter(jsonDictionary: siteListDictionary, modelClass: AWSSiteListModel.self)
        siteListModel = siteListAdapter?.model as? AWSSiteListModel
        siteModel = siteListModel?.item(at: 0)

        bodyModelToUpdate = bodyListModel?.items?.filter { (model) -> Bool in
            return model.key == "24010910"
        }.first

        addedBodyModel = opResultListModel?.items?.filter { (result) -> Bool in
            return result.item?.key == "7273679"
        }.first?.item

        conflictedBodyModel = opResultListModel?.items?.filter { (result) -> Bool in
            return result.item?.key == "17155624"
        }.first?.item

        bodyModelUpdated = opResultListModel?.items?.filter { (result) -> Bool in
            return result.item?.key == "24010910"
        }.first?.item

        let notifySMSDictionary = JSONUtils().loadJSONDictionary(resource: "AWSNotifySMS")
        let notifySMSAdapter = try? AWSMTLJSONAdapter(jsonDictionary: notifySMSDictionary, modelClass: AWSNotifySMSModel.self)
        notifySMSModel = notifySMSAdapter?.model as? AWSNotifySMSModel

        let notifyEmailDictionary = JSONUtils().loadJSONDictionary(resource: "AWSNotifyEmail")
        let notifyEmailAdapter = try? AWSMTLJSONAdapter(jsonDictionary: notifyEmailDictionary, modelClass: AWSNotifyEmailModel.self)
        notifyEmailModel = notifyEmailAdapter?.model as? AWSNotifyEmailModel
    }
}
