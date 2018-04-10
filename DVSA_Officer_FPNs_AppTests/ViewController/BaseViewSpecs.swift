//
//  BaseViewSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 09/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import DVSA_Officer_FPNs_App

class BaseViewChild: BaseView {

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

class BaseViewSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        describe("Classes derived from BaseView") {

            let bvc = BaseViewChild()
            let bvc2 = BaseViewChild(frame: CGRect.zero)
            let bvc3 = Bundle(for: type(of: self)).loadNibNamed("TestView", owner: self, options: nil)?.first as? BaseViewChild

            it("Should call configure on init") {
                expect(bvc.done["configure"]).toEventually(equal(true))

                expect(bvc2.done["configure"]).toEventually(equal(true))

                expect(bvc3).notTo(beNil())
                expect(bvc3?.done["configure"] ?? false).toEventually(equal(true))

            }

            it("Should call addSubviews") {
                expect(bvc.done["addSubviews"]).toEventually(equal(true))
                expect(bvc2.done["addSubviews"]).toEventually(equal(true))
                expect(bvc3?.done["addSubviews"] ?? false).toEventually(equal(true))

                if UI_USER_INTERFACE_IDIOM() == .pad {
                    expect(bvc.done["addSubviewsiPad"]).toEventually(equal(true))
                    expect(bvc2.done["addSubviewsiPad"]).toEventually(equal(true))
                    expect(bvc3?.done["addSubviewsiPad"] ?? false).toEventually(equal(true))
                } else {
                    expect(bvc.done["addSubviewsiPhone"] ).toEventually(equal(true))
                    expect(bvc2.done["addSubviewsiPhone"] ).toEventually(equal(true))
                    expect(bvc3?.done["addSubviewsiPhone"]  ?? false).toEventually(equal(true))
                }
            }

            it("Should call layoutElements") {
                expect(bvc.done["layoutElements"]).toEventually(equal(true))
                expect(bvc2.done["layoutElements"]).toEventually(equal(true))
                expect(bvc3?.done["layoutElements"] ?? false).toEventually(equal(true))

                if UI_USER_INTERFACE_IDIOM() == .pad {
                    expect(bvc.done["layoutElementsiPad"]).toEventually(equal(true))
                    expect(bvc2.done["layoutElementsiPad"]).toEventually(equal(true))
                    expect(bvc3?.done["layoutElementsiPad"] ?? false).toEventually(equal(true))
                } else {
                    expect(bvc.done["layoutElementsiPhone"]).toEventually(equal(true))
                    expect(bvc2.done["layoutElementsiPhone"]).toEventually(equal(true))
                    expect(bvc3?.done["layoutElementsiPhone"] ?? false).toEventually(equal(true))
                }
            }
        }
    }
}
