//
//  NewTokenDetailsViewController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 26/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit
import Reachability

class NewTokenDetailsViewController: UIViewController, ReachabilityObserverDelegate {

    @IBOutlet weak var tokenTextLabel: UILabel!
    @IBOutlet weak var tokenValueLabel: UILabel!
    @IBOutlet weak var paymentTextLabel: UILabel!
    @IBOutlet weak var paymentValueLabel: UILabel!

    @IBOutlet weak var sendSMSButton: DesignableButton!
    @IBOutlet weak var sendEmailButton: DesignableButton!

    weak var createTokenDelegate: CreateTokenDetailsDelegate?
    weak var newTokenDelegate: NewTokenDetailsDelegate?

    lazy var reachabilityObserver = ReachabilityObserver(name: "NewTokenDetailsViewController", delegate: self)

    var viewModel: NewTokenDetailsViewModel? {
        didSet {
            if self.isViewLoaded {
                self.updateUI()
            }
        }
    }

    @IBAction func didTapSendSMS(_ sender: Any) {
        self.newTokenDelegate?.didTapSendSMS()
    }

    @IBAction func didTapSendEmail(_ sender: Any) {
        self.newTokenDelegate?.didTapSendEmail()
    }

    @objc func didTapDone(_ sender: Any) {
        self.createTokenDelegate?.didTapDone()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New payment code"
        self.updateUI()
        self.applyStyle()
        self.enableUITest()
        self.tokenTextLabel.text = "Payment code created:"
        self.paymentValueLabel.text = "https://www.roadside-payment.service.gov.uk"
        self.sendSMSButton.setTitle("Send payment code by SMS", for: .normal)
        self.sendEmailButton.setTitle("Send payment code by e-mail", for: .normal)
    }

    func applyStyle() {
        StyleManager.greenButton(button: self.sendSMSButton)
        StyleManager.greenButton(button: self.sendEmailButton)
    }

    func enableUITest() {
        self.tokenTextLabel.accessibilityIdentifier = "tokenTextLabel"
        self.tokenValueLabel.accessibilityIdentifier = "tokenValueLabel"
        self.paymentTextLabel.accessibilityIdentifier = "paymentTextLabel"
        self.paymentValueLabel.accessibilityIdentifier = "paymentValueLabel"
        self.sendSMSButton.accessibilityIdentifier = "sendSMSButton"
        self.sendEmailButton.accessibilityIdentifier = "sendEmailButton"

        self.tokenTextLabel.isAccessibilityElement = true
        self.tokenValueLabel.isAccessibilityElement = true
        self.paymentTextLabel.isAccessibilityElement = true
        self.paymentValueLabel.isAccessibilityElement = true
        self.sendSMSButton.isAccessibilityElement = true
        self.sendEmailButton.isAccessibilityElement = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let selector = #selector(NewTokenDetailsViewController.didTapDone(_:))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: selector)
        self.navigationItem.rightBarButtonItem = doneButton
        self.reachabilityObserver.startObserveReachability()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.reachabilityObserver.stopObserveReachability()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateUI() {
        if let viewModel = viewModel {
            self.tokenValueLabel.text = viewModel.sharableToken
        } else {
            self.tokenValueLabel.text = ""
        }
    }

    func reachabilityDidChange(isReachable: Bool) {
        if isReachable {
            self.sendSMSButton.isEnabled = true
            self.sendEmailButton.isEnabled = true
        } else {
            self.sendSMSButton.isEnabled = false
            self.sendEmailButton.isEnabled = false
        }
    }
}
