//
//  ReachabilityObserver.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 08/03/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

protocol ReachabilityObserverDelegate: class {
    func reachabilityDidChange(isReachable: Bool)
}

class ReachabilityObserver: WhistleReachabilityObserver {

    var name: String
    weak var delegate: ReachabilityObserverDelegate?
    var whistleReachability: WhistleReachabilityDelegate =  WhistleReachability.shared

    init(name: String, delegate: ReachabilityObserverDelegate) {
        self.name = name
        self.delegate = delegate
    }

    func startObserveReachability() {

        whistleReachability.attachObserver(observer: self)

        guard let reachability = whistleReachability.reachability else {
            self.delegate?.reachabilityDidChange(isReachable: true)
            return
        }

        if reachability.connection != .none {
            self.delegate?.reachabilityDidChange(isReachable: true)
        } else {
            self.delegate?.reachabilityDidChange(isReachable: false)
        }
    }

    func stopObserveReachability() {
        whistleReachability.removeObserver(observer: self)
    }

    lazy var whenReachable: WhistleReachabilityObserver.NetworkReachable? = { _ in
        self.delegate?.reachabilityDidChange(isReachable: true)
    }

    lazy var whenUnreachable: WhistleReachabilityObserver.NetworkUnreachable? = { _ in
        self.delegate?.reachabilityDidChange(isReachable: false)
    }
}
