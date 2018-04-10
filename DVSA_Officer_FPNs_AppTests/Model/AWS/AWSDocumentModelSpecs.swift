//
//  AWSDocumentModelSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 24/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class AWSDocumentModelSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {
        var dictionary: [String: Any]?

        beforeEach {
            dictionary = JSONUtils().loadJSONDictionary(resource: "AWSDocument")
        }

        describe("AWSDocumentModel") {
            context("encode") {
                it("should match keys") {
                    let adapter = try? AWSMTLJSONAdapter(jsonDictionary: dictionary, modelClass: AWSDocumentModel.self)

                    let document = adapter?.model as? AWSDocumentModel
                    expect(document).toNot(beNil())

                    expect(document?.penaltyType).to(equal("FPN"))
                    expect(document?.paymentStatus).to(equal("PAID"))
                    expect(document?.paymentToken).to(equal("4e004da37939110b"))
                    expect(document?.officerID).to(equal("sherlock.holmes@dvsa.gov.uk"))
                    expect(document?.siteCode).to(equal(7))

                    expect(document?.formNo).to(equal("FPN 11/08"))
                    expect(document?.referenceNo).to(equal("820500000877"))
                    expect(document?.driverDetails).toNot(beNil())
                    expect(document?.vehicleDetails).toNot(beNil())
                    expect(document?.trailerDetails).toNot(beNil())

                    expect(document?.nonEndorsableOffence).toNot(beNil())
                    expect(document?.penaltyAmount?.uint16Value).to(equal(50))

                    expect(document?.paymentDueDate?.timeIntervalSince1970).to(equal(479945600))
                    expect(document?.dateTime?.timeIntervalSince1970).to(equal(1476180720))
                    expect(document?.officerName).to(equal("Sherlock Holmes"))
                    expect(document?.placeWhereIssued).to(equal("BLACKWALL TUNNEL A, PAVILLION WAY, METROPOLITAN"))
                    expect(document?.paymentDate?.timeIntervalSince1970).to(equal(1476180750))
                    expect(document?.paymentAuthCode).to(equal("AWrs3909"))
                }
            }

            context("mapping") {
                it("should map jsonKeyPathsByPropertyKey") {

                    let params = AWSDocumentModel.jsonKeyPathsByPropertyKey()!
                    expect(params.count).to(equal(18))
                    expect(params["penaltyType"] as? String).to(equal("penaltyType"))
                    expect(params["paymentStatus"] as? String).to(equal("paymentStatus"))
                    expect(params["paymentToken"] as? String).to(equal("paymentToken"))
                    expect(params["officerID"] as? String).to(equal("officerID"))
                    expect(params["siteCode"] as? String).to(equal("siteCode"))
                    expect(params["formNo"] as? String).to(equal("formNo"))
                    expect(params["referenceNo"] as? String).to(equal("referenceNo"))
                    expect(params["driverDetails"] as? String).to(equal("driverDetails"))
                    expect(params["vehicleDetails"] as? String).to(equal("vehicleDetails"))
                    expect(params["trailerDetails"] as? String).to(equal("trailerDetails"))
                    expect(params["nonEndorsableOffence"] as? String).to(equal("nonEndorsableOffence"))
                    expect(params["penaltyAmount"] as? String).to(equal("penaltyAmount"))
                    expect(params["paymentDueDate"] as? String).to(equal("paymentDueDate"))
                    expect(params["officerName"] as? String).to(equal("officerName"))
                    expect(params["placeWhereIssued"] as? String).to(equal("placeWhereIssued"))
                    expect(params["dateTime"] as? String).to(equal("dateTime"))
                    expect(params["paymentDate"] as? String).to(equal("paymentDate"))
                    expect(params["paymentAuthCode"] as? String).to(equal("paymentAuthCode"))
                }
            }

            context("decode") {
                it("should match keys") {

                    let document = AWSDocumentModel()

                    document?.penaltyType = "FPN"
                    document?.paymentStatus = "UNPAID"
                    document?.paymentToken = "4e004da37939110b"
                    document?.officerID = "sherlock.holmes@dvsa.gov.uk"
                    document?.siteCode = 7

                    document?.formNo = "my formNo"
                    document?.referenceNo = "my referenceNo"
                    document?.nonEndorsableOffence = ["2", "3"]
                    document?.penaltyAmount = NSNumber(value: UInt16(50))
                    document?.paymentDueDate = Date(timeIntervalSince1970: 73683487)
                    document?.officerName = "Me"
                    document?.placeWhereIssued = "London"
                    document?.dateTime = Date(timeIntervalSince1970: 73383487)
                    document?.paymentAuthCode = "AUTH_CODE"
                    document?.paymentDate = Date(timeIntervalSince1970: 73383487)

                    let driverDetails = AWSDriverDetailsModel()
                    driverDetails?.address = "my address"
                    driverDetails?.licenceNumber = "my licenceNumber"
                    driverDetails?.name = "my name"
                    document?.driverDetails = driverDetails

                    let vehicleDetails = AWSVehicleDetailsModel()
                    vehicleDetails?.make = "myMake"
                    vehicleDetails?.nationality = "myNationality"
                    vehicleDetails?.regNo = "myRegNo"
                    document?.vehicleDetails = vehicleDetails

                    let trailerDetails = AWSTrailerDetailsModel()
                    trailerDetails?.number1 = "my number1"
                    trailerDetails?.number2 = "my number2"
                    document?.trailerDetails = trailerDetails

                    let myDictionary = AWSMTLJSONAdapter.jsonDictionary(from: document) as? [String: Any]
                    expect(myDictionary).toNot(beNil())

                    expect(myDictionary?["penaltyType"] as? String).to(equal("FPN"))
                    expect(myDictionary?["paymentStatus"] as? String).to(equal("UNPAID"))
                    expect(myDictionary?["paymentToken"] as? String).to(equal("4e004da37939110b"))
                    expect(myDictionary?["officerID"] as? String).to(equal("sherlock.holmes@dvsa.gov.uk"))
                    let siteCode = myDictionary?["siteCode"] as? NSNumber
                    expect(siteCode?.intValue).to(equal(7))

                    expect(myDictionary?["formNo"] as? String).to(equal("my formNo"))
                    expect(myDictionary?["referenceNo"] as? String).to(equal("my referenceNo"))

                    document?.nonEndorsableOffence = ["2", "3"]
                    let penaltyAmount = myDictionary?["penaltyAmount"] as? NSNumber
                    expect(penaltyAmount?.uint16Value).to(equal(50))
                    expect(myDictionary?["officerName"] as? String).to(equal("Me"))
                    expect(myDictionary?["placeWhereIssued"] as? String).to(equal("London"))

                    let paymentDueDate = myDictionary?["paymentDueDate"] as? NSNumber
                    expect(paymentDueDate?.doubleValue).to(equal(73683487))

                    let dateTime = myDictionary?["dateTime"] as? NSNumber
                    expect(dateTime?.doubleValue).to(equal(73383487))

                    let myDriverDetails = myDictionary?["driverDetails"] as? [String: Any]
                    expect(myDriverDetails).toNot(beNil())
                    expect(myDriverDetails?["address"] as? String).to(equal("my address"))
                    expect(myDriverDetails?["licenceNumber"] as? String).to(equal("my licenceNumber"))
                    expect(myDriverDetails?["name"] as? String).to(equal("my name"))

                    let myVehicleDetails = myDictionary?["vehicleDetails"] as? [String: Any]
                    expect(myVehicleDetails).toNot(beNil())
                    expect(myVehicleDetails?["regNo"] as? String).to(equal("myRegNo"))
                    expect(myVehicleDetails?["nationality"] as? String).to(equal("myNationality"))
                    expect(myVehicleDetails?["make"] as? String).to(equal("myMake"))

                    let myTrailerDetails = myDictionary?["trailerDetails"] as? [String: Any]
                    expect(myTrailerDetails).toNot(beNil())
                    expect(myTrailerDetails?["number1"] as? String).to(equal("my number1"))
                    expect(myTrailerDetails?["number2"] as? String).to(equal("my number2"))

                    let paymentDate = myDictionary?["paymentDate"] as? NSNumber
                    expect(paymentDate?.doubleValue).to(equal(73383487))
                    expect(myDictionary?["paymentAuthCode"] as? String).to(equal("AUTH_CODE"))

                    expect(myDictionary?.count).to(equal(18))
                }
            }
        }
    }
}
