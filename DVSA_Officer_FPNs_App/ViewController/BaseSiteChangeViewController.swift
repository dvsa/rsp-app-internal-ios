//
//  BaseSiteChangeViewController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 25/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit

protocol BaseSiteChangeViewDelegate: class {
    weak var changeSiteLocationView: ChangeSiteLocationView! { get set }
    weak var setLocationDelegate: SetLocationDelegate? { get set }
}

class BaseSiteChangeViewController: UIViewController, BaseSiteChangeViewDelegate {

    @IBOutlet weak var changeSiteLocationView: ChangeSiteLocationView!

    weak var setLocationDelegate: SetLocationDelegate?

    var whistleReachability: WhistleReachabilityDelegate =  WhistleReachability.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        self.changeSiteLocationView.setLocationDelegate = setLocationDelegate
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterForegroud),
                                               name: Notification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: Notification.Name.UIApplicationDidEnterBackground,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeSiteLocationView.updateUI()
        whistleReachability.startReachability()
    }

    @objc func didEnterForegroud() {
        whistleReachability.startReachability()
    }

    @objc func didEnterBackground() {
        whistleReachability.stopReachability()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateUI() {
        self.changeSiteLocationView.updateUI()
    }

}
