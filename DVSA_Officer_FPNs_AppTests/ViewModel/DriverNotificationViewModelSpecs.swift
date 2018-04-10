//
//  DriverNotificationViewModelSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 22/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import DVSA_Officer_FPNs_App

class APINotifyServiceProtcolMock: APINotifyServiceProtcol {

    func sendSMS(body: AWSNotifySMSModel) -> AWSTask<AnyObject> {
        return AWSTask(result: NSObject())
    }

    func sendEmail(body: AWSNotifyEmailModel) -> AWSTask<AnyObject> {
        return AWSTask(result: NSObject())
    }
}

class APINotifyManagerProtocolMock: APINotifyManagerProtocol {

    var done = TestDone()

    var notifyService: APINotifyServiceProtcol = APINotifyServiceProtcolMock()

    func sendSMS(item: AWSNotifySMSModel, completion: @escaping (Bool) -> Void) {
        done["sendSMS"] = true
        completion(true)
    }

    func sendEmail(item: AWSNotifyEmailModel, completion: @escaping (Bool) -> Void) {
        done["sendEmail"] = true
        completion(true)
    }
}

class DriverNotificationViewModelSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {
        describe("DriverNotificationViewModelSpecs") {

            var viewModelSMS: DriverNotificationViewModel!
            var viewModelEmail: DriverNotificationViewModel!
            var notifyManager: APINotifyManagerMock!

            beforeEach {

                notifyManager  = APINotifyManagerMock(notifyService: APINotifyServiceProtcolMock())
                viewModelSMS = DriverNotificationViewModel(type: .sms,
                                                               vehicleReg: "326157",
                                                               location: "nowhere",
                                                               amount: UInt16(16),
                                                               token: "67312576125")

                viewModelSMS.notifyManager = notifyManager

                viewModelEmail = DriverNotificationViewModel(type: .email,
                                                                 vehicleReg: "326157",
                                                                 location: "nowhere",
                                                                 amount: UInt16(16),
                                                                 token: "67312576125")
                viewModelEmail.notifyManager = notifyManager
            }

            context("init sms") {

                it("should not be nil") {
                    expect(viewModelSMS.modelSMS).toNot(beNil())
                    expect(viewModelSMS.modelSMS?.vehicleReg).to(equal("326157"))
                    expect(viewModelSMS.modelSMS?.location).to(equal("nowhere"))
                    expect(viewModelSMS.modelSMS?.amount).to(equal(16))
                    expect(viewModelSMS.modelSMS?.token).to(equal("67312576125"))
                    expect(viewModelSMS.modelEmail).to(beNil())
                }
            }

            context("init email") {
                it("should not be nil") {
                    expect(viewModelEmail.modelSMS).to(beNil())
                    expect(viewModelEmail.modelEmail).toNot(beNil())
                    expect(viewModelEmail.modelEmail?.vehicleReg).to(equal("326157"))
                    expect(viewModelEmail.modelEmail?.location).to(equal("nowhere"))
                    expect(viewModelEmail.modelEmail?.amount).to(equal(16))
                    expect(viewModelEmail.modelEmail?.token).to(equal("67312576125"))
                }
            }

            context("init with document") {
                it("should be nil") {
                    let document = DocumentObject(model: DataMock.shared.bodyModel!.value!)!
                    document.vehicleDetails?.regNo = ""
                    document.paymentToken = nil
                    document.placeWhereIssued = nil
                    document.penaltyAmount = "iiii"

                    let viewModel = DriverNotificationViewModel(document: document, type: .sms)
                    expect(viewModel).to(beNil())

                }

                it("should not be nil") {
                    let document = DocumentObject(model: DataMock.shared.bodyModel!.value!)!
                    let viewModel = DriverNotificationViewModel(document: document, type: .sms)
                    expect(viewModel).toNot(beNil())
                    expect(viewModel?.modelSMS).toNot(beNil())
                    expect(viewModel?.modelSMS?.vehicleReg).to(equal("XXXXXXX"))
                    expect(viewModel?.modelSMS?.location).to(equal("BLACKWALL TUNNEL A, PAVILLION WAY, METROPOLITAN"))
                    expect(viewModel?.modelSMS?.amount).to(equal(50))
                    expect(viewModel?.modelSMS?.token).to(equal("4e004da37939110b"))
                    expect(viewModel?.modelEmail).to(beNil())
                }
            }

            context("isValid") {

                it("should validate email") {

                    let email = "sherlock.holmes@dvsa.gov.uk"
                    let malformed = "sherlock.holmes"
                    expect(viewModelEmail.isValid(address: email)).to(beTrue())
                    expect(viewModelEmail.isValid(address: malformed)).to(beFalse())
                }

                it("should validate sms") {

                    let sms = "+440000000000"
                    let malformed = "+444"
                    expect(viewModelSMS.isValid(address: sms)).to(beTrue())
                    expect(viewModelSMS.isValid(address: malformed)).to(beFalse())
                }
            }

            context("sendEmail") {
                it("should send email") {
                    viewModelEmail.sendEmail(email: "sherlock.holmes@dvsa.gov.uk") { _ in

                    }
                    expect(notifyManager.done["sendEmail"]).toEventually(beTrue())

                }
            }

            context("sendSMS") {
                it("should send email") {
                    viewModelSMS.sendSMS(phoneNumber: "+440000000000") { _ in
                    }
                    expect(notifyManager.done["sendSMS"]).toEventually(beTrue())
                }
            }

            context("Invalid Info message") {
                let smsMessage = "Please recheck the phone number is correct and that it includes the international prefix."
                let emailMessage = "Please recheck the email address is in the correct format (e.g. username@example.com)"

                it ("sms message") {
                    expect(viewModelSMS.invalidInfoMessage()).to(equal(smsMessage))
                }
                it ("email message") {
                    expect(viewModelEmail.invalidInfoMessage()).to(equal(emailMessage))
                }
            }
        }
    }
}
