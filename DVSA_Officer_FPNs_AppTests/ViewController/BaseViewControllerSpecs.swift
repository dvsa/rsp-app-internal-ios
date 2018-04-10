//
//  BaseViewControllerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 09/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble
import UIKit

@testable import DVSA_Officer_FPNs_App

class BaseViewControllerChild: BaseViewController {

    var done = TestDone()

    override func configure() {
        super.configure()
        done["configure"] = true
    }

    override func addSubviews() {
        done["addSubviews"] = true
        super.addSubviews()
    }

    override func addSubviewsiPad() {
        done["addSubviewsiPad"] = true
    }

    override func addSubviewsiPhone() {
        done["addSubviewsiPhone"] = true
    }

    override func layoutElements() {
        done["layoutElements"] = true
        super.layoutElements()
    }

    override func layoutElementsiPad() {
        done["layoutElementsiPad"] = true
    }

    override func layoutElementsiPhone() {
        done["layoutElementsiPhone"] = true
    }
}

class BaseViewControllerSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        describe("Classes derived from BaseView") {

            let bvc = BaseViewControllerChild()
            let bundle = Bundle(for: type(of: self))
            let storyboard = UIStoryboard(name: "TestStoryboard", bundle: bundle)
            let bvc3 = storyboard.instantiateViewController(withIdentifier: "BaseViewControllerChild") as? BaseViewControllerChild

            it("Should call configure on init") {
                expect(bvc.done["configure"]).toEventually(equal(true))

                expect(bvc3).notTo(beNil())
                expect(bvc3?.done["configure"] ?? false).toEventually(equal(true))

            }

            describe("on viewDidLoad") {
                UIApplication.shared.keyWindow!.rootViewController = bvc
                _ = bvc.view
                _ = bvc3?.view

                it("Should call addSubviews") {

                    expect(bvc.done["addSubviews"]).toEventually(equal(true))
                    expect(bvc3?.done["addSubviews"] ?? false).toEventually(equal(true))

                    if UI_USER_INTERFACE_IDIOM() == .pad {
                        expect(bvc.done["addSubviewsiPad"]).toEventually(equal(true))
                        expect(bvc3?.done["addSubviewsiPad"] ?? false).toEventually(equal(true))
                    } else {
                        expect(bvc.done["addSubviewsiPhone"]).toEventually(equal(true))
                        expect(bvc3?.done["addSubviewsiPhone"] ?? false).toEventually(equal(true))
                    }
                }

                it("Should call layoutElements") {
                    expect(bvc.done["layoutElements"]).toEventually(equal(true))
                    expect(bvc3?.done["layoutElements"] ?? false).toEventually(equal(true))

                    if UI_USER_INTERFACE_IDIOM() == .pad {
                        expect(bvc.done["addSubviewsiPad"]).toEventually(equal(true))
                        expect(bvc3?.done["addSubviewsiPad"] ?? false).toEventually(equal(true))
                    } else {
                        expect(bvc.done["addSubviewsiPhone"]).toEventually(equal(true))
                        expect(bvc3?.done["addSubviewsiPhone"] ?? false).toEventually(equal(true))
                    }
                }
            }
        }
    }
}
