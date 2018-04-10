//
//  APINotifyManagerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 16/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class APINotifyManagerSpecs: QuickSpec {

    //swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        var notifyManager: APINotifyManagerProtocol?
        var notifyServiceMock: APINotifyServiceMock!

        describe("APIDataManager") {
            beforeEach {
                notifyManager = APINotifyManager()
                notifyServiceMock = APINotifyServiceMock()
            }
            context("apiService") {
                it("should be a DVSAMobileBackendDevClient") {
                    expect(notifyManager?.notifyService as? AWSMobileNotifyAPIClient).toNot(beNil())
                }
            }

            context("sendEmail") {
                context("valid response") {
                    it("should return a true") {
                        notifyServiceMock.isValidModel = true
                        notifyManager?.notifyService = notifyServiceMock

                        let model = DataMock.shared.notifyEmailModel!
                        var result = false
                        notifyManager?.sendEmail(item: model) { (success) in
                            result = success
                        }
                        expect(result).toEventually(beTrue())
                    }
                }

                context("invalid response") {
                    it("should return true") {
                        notifyServiceMock.isValidModel = false
                        notifyManager?.notifyService = notifyServiceMock

                        let model = DataMock.shared.notifyEmailModel!
                        var result = false
                        notifyManager?.sendEmail(item: model) { (success) in
                            result = success
                        }
                        expect(result).toEventually(beTrue())
                    }
                }

                context("error") {
                    it("should return false") {
                        notifyServiceMock.setupWithError()
                        notifyManager?.notifyService = notifyServiceMock

                        let model = DataMock.shared.notifyEmailModel!
                        var result = false
                        notifyManager?.sendEmail(item: model) { (success) in
                            result = success
                        }
                        expect(result).toEventually(beFalse())
                    }
                }
            }

            context("sendSMS") {
                context("valid response") {
                    it("should return a true") {
                        notifyServiceMock.isValidModel = true
                        notifyManager?.notifyService = notifyServiceMock

                        let model = DataMock.shared.notifySMSModel!
                        var result = false
                        notifyManager?.sendSMS(item: model) { (success) in
                            result = success
                        }
                        expect(result).toEventually(beTrue())
                    }
                }

                context("invalid response") {
                    it("should return true") {
                        notifyServiceMock.isValidModel = false
                        notifyManager?.notifyService = notifyServiceMock

                        let model = DataMock.shared.notifySMSModel!
                        var result = false
                        notifyManager?.sendSMS(item: model) { (success) in
                            result = success
                        }
                        expect(result).toEventually(beTrue())
                    }
                }

                context("error") {
                    it("should return false") {
                        notifyServiceMock.setupWithError()
                        notifyManager?.notifyService = notifyServiceMock

                        let model = DataMock.shared.notifySMSModel!
                        var result = false
                        notifyManager?.sendSMS(item: model) { (success) in
                            result = success
                        }
                        expect(result).toEventually(beFalse())
                    }
                }
            }
        }
    }
}
