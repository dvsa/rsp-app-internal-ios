//
//  SettingsViewController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 25/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit

class SettingsViewController: BaseSiteChangeViewController {

    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var sendLogButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!

    var mailHelper: MailHelper?
    weak var authUIDelegate: AuthUIPresenterFlow?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        mailHelper = MailHelper(hostViewController: self)
        versionLabel.text = SettingsBundleManager.version()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendLogTapped(_ sender: UIButton) {
        mailHelper?.showSendLogMailViewController()
    }

    @IBAction func logOutTapped(_ sender: UIButton) {
        authUIDelegate?.logout()
    }
}
