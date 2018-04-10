//
//  DVSA_Officer_FPNs_AppUITests.swift
//  DVSA_Officer_FPNs_AppUITests
//
//  Created by Andrea Scuderi on 28/09/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import XCTest
@testable import DVSA_Officer_FPNs_App

class DVSAOfficerFPNsAppUITests: XCTestCase {

    func waitForElementToAppear(_ element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate,
                                                    object: element)

        let result = XCTWaiter().wait(for: [expectation], timeout: 5)
        return result == .completed
    }

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        app.launchArguments = ["UI_TEST_MODE"]
        app.launchEnvironment["route"] = "config"
        app.launch()

        // swiftlint:disable:next line_length
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.

        self.login()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.logout()
        super.tearDown()
    }

    func screenshot(named: String) {
        XCTContext.runActivity(named: named) { (activity) in
            let screen = XCUIScreen.main
            screen.screenshot()
            let screenshot = screen.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.lifetime = .keepAlways
            activity.add(attachment)
        }
    }

    func login() {

        let app = XCUIApplication()
        addUIInterruptionMonitor(withDescription: "“FPNsDEV-CDEV” Would Like to Send You Notifications") { (alert) -> Bool in
            let button = alert.buttons["Allow"]
            if button.exists {
                button.tap()
                return true
            }
            return false
        }

        let allow = XCUIApplication().alerts["“FPNsDEV-CDEV” Would Like to Send You Notifications"].buttons["Allow"]
        if waitForElementToAppear(allow) {
            allow.tap()
        }

        app.swipeUp()
        app.buttons["loginButton_1"].tap()

        let user = EnvironmentServiceUITests.getValueForKey("kAdalTestUser")
        let password = EnvironmentServiceUITests.getValueForKey("kAdalTestPassword")

        let webViewsQuery = app.webViews
        sleep(3)

        let mailPredicate = NSPredicate(format: "label CONTAINS 'mail'")
        let emailOrPhoneTextField = webViewsQuery.textFields.element(matching: mailPredicate)
        if waitForElementToAppear(emailOrPhoneTextField) {
            emailOrPhoneTextField.tap()
            sleep(1)
            emailOrPhoneTextField.typeText(user)
            let nextButton = webViewsQuery.buttons["Next"]
            _ = waitForElementToAppear(nextButton)
            nextButton.tap()

        } else {
            let buttonPredicate = NSPredicate(format: "label CONTAINS '\(user)'")
            webViewsQuery.buttons.element(matching: buttonPredicate) .tap()
        }
        sleep(1)

        let passwordSecureTextField = webViewsQuery.secureTextFields["Password"]
        _ = waitForElementToAppear(passwordSecureTextField)
        passwordSecureTextField.tap()
        sleep(1)
        passwordSecureTextField.typeText(password)
        sleep(1)
        let signInButton = webViewsQuery.buttons["Sign in"]
        _ = waitForElementToAppear(signInButton)
        signInButton.tap()
        sleep(1)
    }

    func logout() {
        let app = XCUIApplication()

        app.navigationBars["Config"].buttons["Sign-Out"].tap()
        sleep(3)
    }

    func testEnvironmentOnConfig() {

        let app = XCUIApplication()
        sleep(3)
        let tablesQuery = app.tables
        let cell00Cell = tablesQuery.cells["Cell_0_0"]
        _ = waitForElementToAppear(cell00Cell)
        cell00Cell.tap()
        let environment = cell00Cell.staticTexts["value"]
        _ = waitForElementToAppear(environment)
        XCTAssertEqual(environment.label, "DEV")
        screenshot(named: "On Test Environment")
    }

    func testBundleOnConfig() {
        let app = XCUIApplication()
        sleep(3)
        let tablesQuery = app.tables
        let cell01Cell = tablesQuery.cells["Cell_0_1"]
        _ = waitForElementToAppear(cell01Cell)
        cell01Cell.tap()
        let environment = cell01Cell.staticTexts["value"]
        _ = waitForElementToAppear(environment)
        XCTAssertEqual(environment.label, "com.bjss.dvsa.officerfpns-DEV")
        screenshot(named: "On Test BundleID")
    }
}
