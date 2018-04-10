//
//  WhistleReachability.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 23/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import Reachability
import Whisper

protocol WhistleReachabilityDelegate: class {

    var reachability: Reachability? { get }

    func startReachability()
    func stopReachability()
    func attachObserver(observer: WhistleReachabilityObserver)
    func removeObserver(observer: WhistleReachabilityObserver)
    func removeAllObserver()
}

protocol WhistleReachabilityObserver: class {

    typealias NetworkReachable = (Reachability) -> Void
    typealias NetworkUnreachable = (Reachability) -> Void

    var name: String { get }
    var whenReachable: NetworkReachable? { get }
    var whenUnreachable: NetworkUnreachable? { get }
}

class WhistleReachability: WhistleReachabilityDelegate {

    typealias NetworkReachable = (Reachability) -> Void
    typealias NetworkUnreachable = (Reachability) -> Void

    var reachability: Reachability?

    static let shared = WhistleReachability()

    private var observerArray = NSMapTable<NSString, AnyObject>(keyOptions: [.strongMemory], valueOptions: [.weakMemory])

    internal lazy var whenReachable: NetworkReachable = { reachability in
        guard let enumerator = self.observerArray.objectEnumerator() else { return }
        for observer in enumerator {
            if let observer = observer as? WhistleReachabilityObserver {
                observer.whenReachable?(reachability)
            }
        }
    }

    internal lazy var whenUnreachable: NetworkUnreachable = { reachability in
        guard let enumerator = self.observerArray.objectEnumerator() else { return }
        for observer in enumerator {
            if let observer = observer as? WhistleReachabilityObserver {
                observer.whenUnreachable?(reachability)
            }
        }
    }

    func attachObserver(observer: WhistleReachabilityObserver) {
        observerArray.setObject(observer, forKey: observer.name as NSString)
    }

    func removeObserver(observer: WhistleReachabilityObserver) {
        observerArray.removeObject(forKey: observer.name as NSString)
    }

    func removeAllObserver() {
        observerArray.removeAllObjects()
    }

    init() {
        reachability  = Reachability()
        reachability?.whenReachable = { [weak self] reachability in
            log.info("whenReachable")
            self?.show(isOnline: true)
            self?.whenReachable(reachability)
        }
        reachability?.whenUnreachable = { [weak self]  reachability in
            log.info("whenUnreachable")
            self?.show(isOnline: false)
            self?.whenUnreachable(reachability)
        }

        guard let reachability = reachability else {
            return
        }

        if reachability.connection != .none {
            log.info("first !isReachable")
            self.show(isOnline: false)
            self.whenUnreachable(reachability)
        } else {
            log.info("first isReachable")
            self.show(isOnline: true)
            self.whenUnreachable(reachability)
        }
    }

    deinit {
        reachability = nil
        removeAllObserver()
    }

    func startReachability() {
        do {
            try reachability?.startNotifier()
        } catch {
            log.info("Unable to start notifier")
        }
    }

    func stopReachability() {
        reachability?.stopNotifier()
    }

    func show(isOnline: Bool) {
        if isOnline {
            DispatchQueue.main.async {
                Whisper.hide(whistleAfter: 0)
            }
        } else {
            DispatchQueue.main.async {
                let murmur = Murmur(title: "You are offline. Some features may be unavailable.", backgroundColor: .orange, titleColor: .white)
                Whisper.show(whistle: murmur, action: .present)
            }
        }
    }
}
