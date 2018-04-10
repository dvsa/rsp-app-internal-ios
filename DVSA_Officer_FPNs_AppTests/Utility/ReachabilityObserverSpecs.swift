//
//  ReachabilityObserverSpecs.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 08/03/2018.
// Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
import Reachability

@testable import DVSA_Officer_FPNs_App

class WhistleReachabilityMock: WhistleReachabilityDelegate {

    var done = TestDone()

    var reachability: Reachability?

    func startReachability() {
        done["startReachability"] = true
    }

    func stopReachability() {
        done["stopReachability"] = true
    }

    func attachObserver(observer: WhistleReachabilityObserver) {
        done["attachObserver"] = true
    }

    func removeObserver(observer: WhistleReachabilityObserver) {
        done["removeObserver"] = true
    }

    func removeAllObserver() {
        done["removeAllObserver"] = true
    }

}

class ReachabilityObserverDelegateMock: ReachabilityObserverDelegate {

    var done = TestDone()
    var isReachable: Bool?

    func reachabilityDidChange(isReachable: Bool) {
        done["reachabilityDidChange"] = true
        self.isReachable = isReachable
    }
}

class ReachabilityObserverSpecs: QuickSpec {
    override func spec() {

        describe("ReachabilityObserver") {
            var whistleReachability: WhistleReachabilityMock!
            var reachabilityObserver: ReachabilityObserver?
            var delegateMock: ReachabilityObserverDelegateMock!

            beforeEach {
                whistleReachability = WhistleReachabilityMock()
                delegateMock = ReachabilityObserverDelegateMock()
                reachabilityObserver = ReachabilityObserver(name: "name", delegate: delegateMock)
                reachabilityObserver?.whistleReachability = whistleReachability
            }

            context("init") {
                it("should set the name and delegate") {
                    expect(reachabilityObserver).toNot(beNil())
                    expect(reachabilityObserver?.name).to(equal("name"))
                    expect(reachabilityObserver?.delegate).toNot(beNil())
                }
            }

            context("startObserveReachability") {
                it("should call attachObserver and reachabilityDidChange") {
                    reachabilityObserver?.startObserveReachability()
                    expect(whistleReachability.done["attachObserver"]).to(beTrue())
                    expect(delegateMock.done["reachabilityDidChange"]).to(beTrue())
                }
            }

            context("stopObserveReachability") {
                it("should call removeObserver") {
                    reachabilityObserver?.stopObserveReachability()
                    expect(whistleReachability.done["removeObserver"]).to(beTrue())
                }
            }

            context("whenReachable") {
                it("should call reachabilityDidChange true") {
                    reachabilityObserver?.whenReachable?(Reachability()!)
                    expect(delegateMock.done["reachabilityDidChange"]).to(beTrue())
                    expect(delegateMock.isReachable).to(beTrue())
                }
            }

            context("whenUnreachable") {
                it("should call reachabilityDidChange false") {
                    reachabilityObserver?.whenUnreachable?(Reachability()!)
                    expect(delegateMock.done["reachabilityDidChange"]).to(beTrue())
                    expect(delegateMock.isReachable).toNot(beTrue())
                }
            }
        }
    }
}
