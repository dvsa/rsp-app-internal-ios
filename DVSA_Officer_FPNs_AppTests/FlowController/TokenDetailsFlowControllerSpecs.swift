//
//  TokenDetailsFlowControllerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 19/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
import UIKit
import Compass
@testable import DVSA_Officer_FPNs_App

class TokenDetailsFlowControllerSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        describe("TokenDetailsFlowController") {

            var navigationController: UINavigationController!
            var flowConfigure: FlowConfigure!
            var tokenDetailsFlowController: TokenDetailsFlowController?
            var object: BodyObject!
            var viewModel: TokenDetailsViewModel?
            var syncDelgateMock: SynchronizationManagerMock!

            beforeEach {

                navigationController = UINavigationController()
                _ = navigationController.view
                navigationController.pushViewController(UIViewController(), animated: false)

                flowConfigure = FlowConfigure(window: nil, navigationController: navigationController, parent: nil)

                let model = DataMock.shared.bodyModel!
                object = BodyObject(model: model)

                viewModel = TokenDetailsViewModel(model: object)

                syncDelgateMock = SynchronizationManagerMock()
                tokenDetailsFlowController = TokenDetailsFlowController(configure: flowConfigure)
                tokenDetailsFlowController?.syncManager = syncDelgateMock
                tokenDetailsFlowController?.viewModel = viewModel
            }

            context("init") {
                it("should not be nil") {
                    expect(tokenDetailsFlowController).toNot(beNil())
                }
                it("should set configure as main") {
                    expect(tokenDetailsFlowController?.configure.whichFlowAmI()).to(equal(.navigation))
                }
            }

            context("when start") {
                beforeEach {
                    tokenDetailsFlowController?.start()
                    _ = tokenDetailsFlowController?.viewController?.view
                }
                it("should not set window") {
                    expect(tokenDetailsFlowController?.configure.window).to(beNil())
                }
                it("should set navigation") {
                    expect(tokenDetailsFlowController?.configure.navigationController).toNot(beNil())
                }
                it("should set the viewController") {
                    expect(tokenDetailsFlowController?.viewController).toNot(beNil())
                    expect(tokenDetailsFlowController?.viewController?.viewModel).toNot(beNil())
                    expect(tokenDetailsFlowController?.viewController?.newTokenDelegate).toNot(beNil())
                }
                it("should set back button") {
                    let nc = tokenDetailsFlowController?.configure.navigationController
                    expect(nc?.topViewController?.navigationItem.backBarButtonItem).toNot(beNil())
                }
            }

            context("NewTokenDetailsDelegate") {

                beforeEach {
                    tokenDetailsFlowController?.start()
                    _ = tokenDetailsFlowController?.viewController?.view
                }

                context("didTapSendSMS") {
                    it("should show SendNotificationViewController") {
                        tokenDetailsFlowController?.didTapSendSMS()
                        let vc = tokenDetailsFlowController?.navigationController.topViewController
                        expect(vc as? SendNotificationViewController).toNot(beNil())
                    }
                }

                context("didTapSendEmail") {
                    it("should show SendNotificationViewController") {
                        tokenDetailsFlowController?.didTapSendEmail()
                        let vc = tokenDetailsFlowController?.navigationController.topViewController
                        expect(vc as? SendNotificationViewController).toNot(beNil())
                    }
                }

                context("didTapRevokeToken") {
                    it("should show alert") {
                        tokenDetailsFlowController?.didTapRevokeToken()
                        let alert = tokenDetailsFlowController?.alertController
                        expect(alert).toNot(beNil())
                    }
                }

                context("revokeToken") {
                    it("should call delete") {
                        tokenDetailsFlowController?.revokeToken()
                        expect(syncDelgateMock.done["delete"]).to(beTrue())
                    }
                }

                context("showCancelError") {
                    it("should show alert") {
                        tokenDetailsFlowController?.showCancelError()
                        let alert = tokenDetailsFlowController?.alertController
                        expect(alert).toNot(beNil())
                    }
                }
            }
        }
    }
}
