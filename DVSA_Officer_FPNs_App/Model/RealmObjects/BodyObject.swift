//
//  BodyObject.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 14/12/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import RealmSwift

enum SynchStatusType: Int8 {
    case updated
    case pending
    case conflicted

    func predicate() -> NSPredicate {
        return NSPredicate(format: "status == \(self.rawValue)")
    }
}

class BodyObject: Object, Model {

    @objc dynamic var key: String = ""
    @objc dynamic var value: DocumentObject?
    @objc dynamic var hashToken: String = ""
    @objc dynamic var offset: Date = Date()
    @objc dynamic var enabled: Bool = false
    @objc dynamic var status: Int8 = SynchStatusType.updated.rawValue
    @objc dynamic var hideNotification = false

    override public class func primaryKey() -> String? {
        return "key"
    }

    convenience init?(object: DocumentObject) {

        guard object.referenceNo != "",
              object.key != "" else {
            return nil
        }
        self.init()
        self.key = object.key
        self.value = object
        self.hashToken = "New"
        self.offset = Date()
        self.enabled = true
    }

    convenience init?(model: AWSBodyModel) {

        guard let key = model.key,
            let awsDocumentModel = model.value,
            let value = DocumentObject(model: awsDocumentModel),
            let hashToken = model.hashToken,
            let offset = model.offset,
            let enabled = model.enabled?.boolValue
            else {
                return nil
        }
        self.init()
        self.key = key
        self.value = value
        self.hashToken = hashToken
        self.offset = offset
        self.enabled = enabled
    }

    func awsModel() -> AWSBodyModel? {
        return AWSBodyModel(object: self)
    }
}

extension AWSBodyModel {
    convenience init(object: BodyObject) {
        self.init()
        self.key = object.key
        self.value = object.value?.awsModel()
        self.hashToken = object.hashToken
        self.offset = object.offset
        self.enabled = NSNumber(value: object.enabled)
    }
}

extension BodyObject {
    static func randomBody() -> BodyObject? {
        guard let document = DocumentObject.randomDocument() else {
            return nil
        }
        let body = BodyObject(object: document)
        body?.hashToken = String.randomAlphaNumericString(length: 32)
        return body
    }
}
