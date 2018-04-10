//
//  StyleManagerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 12/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class StyleManagerSpecs: QuickSpec {

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        describe("StyleManager") {

            context("applyStype") {

                it("should set the style preferences") {
                    StyleManager.applyStyle()

                    expect(UITabBar.appearance().tintColor).to(equal(UIColor.white))
                    expect(UITabBar.appearance().barTintColor).to(equal(UIColor.black))
                    expect(UINavigationBar.appearance().tintColor).to(equal(UIColor.white))
                    expect(UINavigationBar.appearance().backgroundColor).to(equal(UIColor.black))
                    expect(UINavigationBar.appearance().barTintColor).to(equal(UIColor.black))
                    let titleTextAttributes = UINavigationBar.appearance().titleTextAttributes
                    expect(titleTextAttributes).toNot(beNil())
                    expect(titleTextAttributes?[NSAttributedStringKey.foregroundColor] as? UIColor).to(equal(UIColor.white))
                    expect(UIApplication.shared.statusBarStyle).to(equal(UIStatusBarStyle.lightContent))
                }
            }

            context("icon function") {

                it("should return valid icon") {
                    expect(StyleManager.iconTokens().size.height).to(beGreaterThan(0))
                    expect(StyleManager.iconNewToken().size.height).to(beGreaterThan(0))
                    expect(StyleManager.iconNotifications().size.height).to(beGreaterThan(0))
                    expect(StyleManager.iconSettings().size.height).to(beGreaterThan(0))
                }
            }

            context("roundedBorder") {

                it("should set default values") {
                    let view = DesignableView(frame: CGRect.zero)
                    StyleManager.roundedBorder(view: view)
                    expect(view.borderWidth).to(equal(1.5))
                    expect(view.borderColor).to(equal(UIColor.black))
                    expect(view.cornerRadius).to(equal(8.0))
                }
            }

            context("segmented") {

                it("should set default values") {
                    let sc = UISegmentedControl(frame: CGRect.zero)
                    StyleManager.segmented(segmented: sc)
                    expect(sc.layer.borderWidth).to(equal(1.5))
                    expect(sc.tintColor).to(equal(UIColor.black))
                    expect(sc.layer.cornerRadius).to(equal(8.0))
                    expect(sc.layer.masksToBounds).to(beTrue())
                }
            }

            context("route to icon") {

                it("should return valid icon") {
                    expect(StyleManager.icon(route: .tokenList).size.height).to(beGreaterThan(0))
                    expect(StyleManager.icon(route: .newToken).size.height).to(beGreaterThan(0))
                    expect(StyleManager.icon(route: .settings).size.height).to(beGreaterThan(0))
                }
            }
        }
    }
}
