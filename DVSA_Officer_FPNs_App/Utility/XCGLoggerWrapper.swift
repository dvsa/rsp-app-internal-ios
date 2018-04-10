//
//  XCGLoggerWrapper.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 05/03/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

@objc class XCGLoggerWrapper: NSObject {

    @objc static let shared = XCGLoggerWrapper()

    internal var logger = log

    //A severe error occurred, we are likely about to crash now
    @objc func severe(value: NSObject) {
        log.severe(value)
    }

    //An error occurred, but it's recoverable, just info about what happened
    @objc func error(value: NSObject) {
        log.error(value)
    }

    //A warning message, may indicate a possible error
    @objc func warning(value: NSObject) {
        log.warning(value)
    }

    //An info message, probably useful to power users looking in console.app
    @objc func info(value: NSObject) {
        log.info(value)
    }

    //A debug message
    @objc func debug(value: NSObject) {
        log.debug(value)
    }

    //A verbose message, usually useful when working on a specific problem
    @objc func verbose(value: NSObject) {
        log.verbose(value)
    }
}
