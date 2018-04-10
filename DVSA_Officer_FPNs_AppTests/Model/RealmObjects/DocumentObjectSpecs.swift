//
//  DocumentObjectSpecs.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 14/12/2017.
//Copyright © 2017 Andrea Scuderi. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class DocumentObjectSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {
        var dictionary: [String: Any]?
        var documentModel: AWSDocumentModel!

        beforeEach {
            dictionary = JSONUtils().loadJSONDictionary(resource: "AWSDocument")
            let adapter = try? AWSMTLJSONAdapter(jsonDictionary: dictionary, modelClass: AWSDocumentModel.self)
            documentModel = adapter?.model as? AWSDocumentModel
        }

        describe("DocumentObject") {
            context("init") {
                it("should init with AWSDocumentModel") {

                    let document = DocumentObject(model: documentModel)
                    expect(document).toNot(beNil())
                }
            }

            context("extension") {
                it("should init with AWSDocumentModel") {
                    if let document = DocumentObject(model: documentModel) {
                        let model = AWSDocumentModel(object: document)
                        expect(document).toNot(beNil())
                        expect(document.penaltyType).to(equal(Int8(PenaltyType.fpn.rawValue)))
                        expect(document.paymentStatus).to(equal(Int8(PaymentStatus.paid.rawValue)))
                        expect(document.paymentToken).to(equal("4e004da37939110b"))
                        expect(document.officerID).to(equal("sherlock.holmes@dvsa.gov.uk"))
                        expect(document.siteCode).to(equal(7))

                        expect(document.formNo).to(equal(model.formNo))
                        expect(document.referenceNo).to(equal(model.referenceNo))
                        expect(document.driverDetails?.isEqualToModel(model: model.driverDetails!)).to(beTrue())
                        expect(document.trailerDetails?.isEqualToModel(model: model.trailerDetails!)).to(beTrue())
                        expect(document.vehicleDetails?.isEqualToModel(model: model.vehicleDetails!)).to(beTrue())
                        expect(document.nonEndorsableOffence.count).to(equal(model.nonEndorsableOffence?.count))
                        for ival in 0..<document.nonEndorsableOffence.count {
                            expect(document.nonEndorsableOffence[ival]).to(equal(model.nonEndorsableOffence?[ival]))
                        }
                        expect(UInt16(document.penaltyAmount)).to(equal(model.penaltyAmount?.uint16Value))
                        expect(document.paymentDueDate).to(equal(model.paymentDueDate))
                        expect(document.officerName).to(equal(model.officerName))
                        expect(document.placeWhereIssued).to(equal(model.placeWhereIssued))
                        expect(document.dateTime).to(equal(model.dateTime))
                        expect(document.paymentAuthCode).to(equal(model.paymentAuthCode))
                        expect(document.paymentDate).to(equal(model.paymentDate))

                        expect(document.isEqualToModel(model: model)).to(beTrue())
                    } else {
                        fail()
                    }
                }
            }
        }
    }
}
