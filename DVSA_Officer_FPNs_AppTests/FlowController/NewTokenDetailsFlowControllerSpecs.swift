//
//  NewTokenDetailsFlowControllerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 05/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
import UIKit
import Compass
@testable import DVSA_Officer_FPNs_App

class CreateTokenDetailsDelegateMock: CreateTokenDetailsDelegate {

    var done = TestDone()

    func didTapDone() {
        done["didTapDone"] = true
    }
}

class NewTokenDetailsDelegateMock: NewTokenDetailsDelegate {

    var done = TestDone()

    func didTapRevokeToken() {
        done["didTapRevokeToken"] = true
    }

    func didTapSendSMS() {
        done["didTapSendSMS"] = true
    }

    func didTapSendEmail() {
        done["didTapSendEmail"] = true
    }
}

class NewTokenDetailsFlowControllerSpecs: QuickSpec {

    let tokenEncryptionKey: [UInt32] = [0x01, 0x01, 0x01, 0x01]

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        describe("NewTokenDetailsFlowController") {

            var navigationController: UINavigationController!
            var flowConfigure: FlowConfigure!
            var newTokenDetailsFlowController: NewTokenDetailsFlowController?
            var syncManager: SynchronizationManagerMock!
            var model: NewTokenModel!
            var viewModel: NewTokenDetailsViewModel?
            var datasource: PersistentDataSourceMock!
            var createTokenDelegate: CreateTokenDetailsDelegateMock!

            beforeEach {

                navigationController = UINavigationController()
                _ = navigationController.view

                flowConfigure = FlowConfigure(window: nil, navigationController: navigationController, parent: nil)

                model = NewTokenModel(value: nil)
                model.dateTime = Date()
                model.referenceNo = "123456-1-666777-IM"
                model.penaltyAmount = "66"
                model.vehicleRegNo = "LD12HHH"
                model.penaltyType = PenaltyType.immobilization

                datasource = PersistentDataSourceMock()
                createTokenDelegate = CreateTokenDetailsDelegateMock()

                viewModel = try? NewTokenDetailsViewModel(model: model,
                                                          preferences: PreferencesDataSourceMock(),
                                                          datasource: datasource, key: self.tokenEncryptionKey)
                syncManager = SynchronizationManagerMock()
                newTokenDetailsFlowController = NewTokenDetailsFlowController(configure: flowConfigure)
                _ = newTokenDetailsFlowController?.navigationController.view
                newTokenDetailsFlowController?.viewModel = viewModel
                newTokenDetailsFlowController?.synchManager = syncManager
                newTokenDetailsFlowController?.createTokenDelegate = createTokenDelegate
            }

            context("init") {
                it("should not be nil") {
                    expect(newTokenDetailsFlowController).toNot(beNil())
                }
                it("should set configure as main") {
                    expect(newTokenDetailsFlowController?.configure.whichFlowAmI()).to(equal(.navigation))
                }
            }

            context("when start") {
                beforeEach {
                    newTokenDetailsFlowController?.start()
                    expect(newTokenDetailsFlowController?.createTokenDelegate).toNot(beNil())
                }
                it("should not set window") {
                    expect(newTokenDetailsFlowController?.configure.window).to(beNil())
                }
                it("should set navigation") {
                    expect(newTokenDetailsFlowController?.configure.navigationController).toNot(beNil())
                }
                it("should setup the viewController") {
                    expect(newTokenDetailsFlowController?.viewController?.viewModel).toNot(beNil())
                    expect(newTokenDetailsFlowController?.viewController?.createTokenDelegate).toNot(beNil())
                    expect(newTokenDetailsFlowController?.viewController?.newTokenDelegate).toNot(beNil())
                }
                it("should call synchronize") {
                    expect(syncManager.done["synchronize"]).toEventually(beTrue())
                    expect(viewModel?.isSynchronized).toEventually(beTrue())
                }

                context("NewTokenDetailsDelegate") {

                    beforeEach {
                        newTokenDetailsFlowController?.start()
                        expect(newTokenDetailsFlowController?.createTokenDelegate).toNot(beNil())
                    }
                }
            }

            context("CreateTokenDetailsDelegate") {
                it("should didTapDone") {
                    newTokenDetailsFlowController?.didTapDone()
                    expect(createTokenDelegate.done["didTapDone"]).toEventually(beTrue())
                }
            }

            context("NewTokenDetailsDelegate") {

                beforeEach {
                    newTokenDetailsFlowController?.start()
                }

                context("didTapSendSMS") {
                    it("should show SendNotificationViewController") {
                        newTokenDetailsFlowController?.didTapSendSMS()
                        let vc = newTokenDetailsFlowController?.notificationViewController
                        expect(vc).toNot(beNil())
                    }
                }

                context("didTapSendEmail") {
                    it("should show SendNotificationViewController") {
                        newTokenDetailsFlowController?.didTapSendEmail()
                        let vc = newTokenDetailsFlowController?.notificationViewController
                        expect(vc).toNot(beNil())
                    }
                }
            }
        }
    }
}
