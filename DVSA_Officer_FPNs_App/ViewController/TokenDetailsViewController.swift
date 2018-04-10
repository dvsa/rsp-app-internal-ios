//
//  TokenDetailsViewController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 19/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit

class TokenDetailsViewController: UIViewController, ReachabilityObserverDelegate {

    //Header
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var registrationNoLabel: UILabel!
    @IBOutlet weak var paymentStatusLabel: UILabel!
    @IBOutlet weak var paidImageView: UIImageView!
    @IBOutlet weak var titleSeparatorLine: UIView!

    //Payment Token
    @IBOutlet weak var paymentTokenDescriptionLabel: UILabel!
    @IBOutlet weak var paymentTokenLabel: UILabel!
    @IBOutlet weak var notifyStatusLabel: UILabel!

    //Penalty details
    @IBOutlet weak var penaltyDetailsDescriptionLabel: UILabel!

    @IBOutlet weak var descritpionStackView: UIStackView!
    @IBOutlet weak var referenceNoDescriptionLabel: UILabel!
    @IBOutlet weak var penaltyAmountDescriptionLabel: UILabel!
    @IBOutlet weak var siteLocationDescriptionLabel: UILabel!
    @IBOutlet weak var penaltyTypeDescriptionLabel: UILabel!
    @IBOutlet weak var penaltyDateDescriptionLabel: UILabel!
    @IBOutlet weak var emptyDescriptionLabel: UILabel!
    @IBOutlet weak var paymentDateDescriptionLabel: UILabel!
    @IBOutlet weak var authorizationCodeDescriptionLabel: UILabel!

    @IBOutlet weak var separatorPenaltyDetails: UIView!

    @IBOutlet weak var valueStackView: UIStackView!
    @IBOutlet weak var referenceNoLabel: UILabel!
    @IBOutlet weak var penaltyAmountLabel: UILabel!
    @IBOutlet weak var siteLocationLabel: UILabel!
    @IBOutlet weak var penaltyTypeLabel: UILabel!
    @IBOutlet weak var penaltyDateLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var paymentDateLabel: UILabel!
    @IBOutlet weak var authorizationCodeLabel: UILabel!

    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var sendBySMSButton: DesignableButton!
    @IBOutlet weak var sendByEmailButton: DesignableButton!
    @IBOutlet weak var cancelTokenButton: DesignableButton!

    //Revoked info
    @IBOutlet weak var cancelledTokenInfo: UILabel!

    lazy var reachabilityObserver = ReachabilityObserver(name: "TokenDetailsViewController", delegate: self)

    var viewModel: TokenDetailsViewModel? {
        didSet {
            if self.isViewLoaded {
                self.updateUI()
            }
        }
    }
    weak var newTokenDelegate: NewTokenDetailsDelegate?

    @IBAction func didTapSendSMS(_ sender: Any) {
        self.newTokenDelegate?.didTapSendSMS()
    }

    @IBAction func didTapSendEmail(_ sender: Any) {
        self.newTokenDelegate?.didTapSendEmail()
    }

    @IBAction func didTapCancelToken(_ sender: Any) {
        self.newTokenDelegate?.didTapRevokeToken()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
        self.enableUITest()
        self.applyStyle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reachabilityObserver.startObserveReachability()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.reachabilityObserver.stopObserveReachability()
    }

    func applyStyle() {

        paymentTokenDescriptionLabel.text = "Payment code"
        penaltyDetailsDescriptionLabel.text = "Penalty details"

        referenceNoDescriptionLabel.text = "Reference:"
        penaltyAmountDescriptionLabel.text = "Amount:"
        siteLocationDescriptionLabel.text = "Location:"
        penaltyTypeDescriptionLabel.text = "Type:"
        penaltyDateDescriptionLabel.text = "Issued on:"
        emptyDescriptionLabel.text = " "
        emptyLabel.text = " "
        paymentDateDescriptionLabel.text = "Paid on:"
        authorizationCodeDescriptionLabel.text = "Auth. code:"

        sendBySMSButton.setTitle("Send payment code by SMS", for: .normal)
        sendByEmailButton.setTitle("Send payment code by e-mail", for: .normal)
        cancelTokenButton.setTitle("Cancel payment code", for: .normal)

        StyleManager.greenButton(button: sendBySMSButton)
        StyleManager.greenButton(button: sendByEmailButton)
        StyleManager.grayButton(button: cancelTokenButton)

        separatorPenaltyDetails.backgroundColor = UIColor.lightGray
    }

    internal func addToStackView(label: UILabel, stackView: UIStackView) {
        if label.superview == nil {
            stackView.addArrangedSubview(label)
        }
        label.isHidden = false
    }

    internal func removeFromStackView(label: UILabel) {
        label.isHidden = true
    }

    internal func updateVisibleFields(isPaid: Bool, isEnabled: Bool) {

        if isPaid {
            updatePaidVisibleFields()
        } else {
            updateUnpaidVisibleFields()
        }

        if !isEnabled {
            updateDisabledVisibleFields()
        }
    }

    internal func updatePaidVisibleFields() {

        paidImageView.image = UIImage(named: "icon-paid")
        paidImageView.isHidden  = false
        headerView.backgroundColor = UIColor.dvsaGreen.withAlphaComponent(0.1)
        buttonsStackView.isHidden = true
        separatorPenaltyDetails.isHidden = false
        titleSeparatorLine.isHidden = false
        cancelledTokenInfo.isHidden = true

        addToStackView(label: emptyLabel, stackView: valueStackView)
        addToStackView(label: paymentDateLabel, stackView: valueStackView)
        addToStackView(label: authorizationCodeLabel, stackView: valueStackView)
        addToStackView(label: emptyDescriptionLabel, stackView: descritpionStackView)
        addToStackView(label: paymentDateDescriptionLabel, stackView: descritpionStackView)
        addToStackView(label: authorizationCodeDescriptionLabel, stackView: descritpionStackView)

    }

    internal func updateUnpaidVisibleFields() {

        paidImageView.image = UIImage(named: "icon-paid")
        paidImageView.isHidden  = true
        headerView.backgroundColor = UIColor.white
        buttonsStackView.isHidden = false
        separatorPenaltyDetails.isHidden = true
        titleSeparatorLine.isHidden = false
        cancelledTokenInfo.isHidden = true

        removeFromStackView(label: emptyLabel)
        removeFromStackView(label: paymentDateLabel)
        removeFromStackView(label: authorizationCodeLabel)
        removeFromStackView(label: emptyDescriptionLabel)
        removeFromStackView(label: paymentDateDescriptionLabel)
        removeFromStackView(label: authorizationCodeDescriptionLabel)

    }

    internal func updateDisabledVisibleFields() {

        paidImageView.image = UIImage(named: "InvalidInfo")
        paidImageView.isHidden  = false
        headerView.backgroundColor = .dvsaPinkBackground
        buttonsStackView.isHidden = true
        separatorPenaltyDetails.isHidden = true
        titleSeparatorLine.isHidden = true
        cancelledTokenInfo.isHidden = false

        removeFromStackView(label: emptyLabel)
        removeFromStackView(label: paymentDateLabel)
        removeFromStackView(label: authorizationCodeLabel)
        removeFromStackView(label: emptyDescriptionLabel)
        removeFromStackView(label: paymentDateDescriptionLabel)
        removeFromStackView(label: authorizationCodeDescriptionLabel)

    }

    func updateUI() {

        guard isViewLoaded else {
            return
        }

        guard let viewModel = viewModel else {
            self.title = ""
            updateVisibleFields(isPaid: false, isEnabled: true)
            registrationNoLabel.text = ""
            paymentStatusLabel.text = ""
            paymentStatusLabel.textColor = .black
            paymentTokenLabel.text = ""
            notifyStatusLabel.text = ""
            referenceNoLabel.text = ""
            penaltyAmountLabel.text = ""
            siteLocationLabel.text = ""
            penaltyTypeLabel.text = ""
            penaltyDateLabel.text = ""
            paymentDateLabel.text = ""
            authorizationCodeLabel.text = ""
            return
        }

        self.title = viewModel.title
        updateVisibleFields(isPaid: viewModel.isPaid, isEnabled: viewModel.isEnabled)
        registrationNoLabel.text = viewModel.registrationNo
        paymentStatusLabel.text = viewModel.paymentStatus
        paymentStatusLabel.textColor = viewModel.titleTextColor
        paymentTokenLabel.text = viewModel.paymentToken
        notifyStatusLabel.text = viewModel.notifyStatus
        referenceNoLabel.text = viewModel.referenceNo
        penaltyAmountLabel.text = viewModel.penaltyAmount
        siteLocationLabel.text = viewModel.siteLocation
        penaltyTypeLabel.text = viewModel.penaltyType
        penaltyDateLabel.text = viewModel.penaltyDate
        paymentDateLabel.text = viewModel.paymentDate
        authorizationCodeLabel.text = viewModel.authorizationCode

        self.applyStyle()
    }

    // swiftlint:disable:next function_body_length cyclomatic_complexity
    func enableUITest() {

        registrationNoLabel.accessibilityIdentifier = "registrationNoLabel"
        paymentStatusLabel.accessibilityIdentifier = "paymentStatusLabel"
        paidImageView.accessibilityIdentifier = "paidImageView"

        paymentTokenDescriptionLabel.accessibilityIdentifier = "paymentTokenDescriptionLabel"
        paymentTokenLabel.accessibilityIdentifier = "paymentTokenLabel"
        notifyStatusLabel.accessibilityIdentifier = "notifyStatusLabel"

        referenceNoDescriptionLabel.accessibilityIdentifier = "referenceNoDescriptionLabel"
        penaltyAmountDescriptionLabel.accessibilityIdentifier = "penaltyAmountDescriptionLabel"
        siteLocationDescriptionLabel.accessibilityIdentifier = "siteLocationDescriptionLabel"
        penaltyTypeDescriptionLabel.accessibilityIdentifier = "penaltyTypeDescriptionLabel"
        penaltyDateDescriptionLabel.accessibilityIdentifier = "penaltyDateDescriptionLabel"
        emptyDescriptionLabel.accessibilityIdentifier = "emptyDescriptionLabel"
        paymentDateDescriptionLabel.accessibilityIdentifier = "paymentDateDescriptionLabel"
        authorizationCodeDescriptionLabel.accessibilityIdentifier = "authorizationCodeDescriptionLabel"

        sendBySMSButton.accessibilityIdentifier = "sendBySMSButton"
        sendByEmailButton.accessibilityIdentifier = "sendByEmailButton"
        cancelTokenButton.accessibilityIdentifier = "cancelTokenButton"

        referenceNoLabel.accessibilityIdentifier = "referenceNoLabel"
        penaltyAmountLabel.accessibilityIdentifier = "penaltyAmountLabel"
        siteLocationLabel.accessibilityIdentifier = "siteLocationLabel"
        penaltyTypeLabel.accessibilityIdentifier = "penaltyTypeLabel"
        penaltyDateLabel.accessibilityIdentifier = "penaltyDateLabel"
        emptyLabel.accessibilityIdentifier = "emptyLabel"
        paymentDateLabel.accessibilityIdentifier = "paymentDateLabel"
        authorizationCodeLabel.accessibilityIdentifier = "authorizationCodeLabel"

        registrationNoLabel.isAccessibilityElement = true
        paymentStatusLabel.isAccessibilityElement = true
        paidImageView.isAccessibilityElement = true

        paymentTokenDescriptionLabel.isAccessibilityElement = true
        paymentTokenLabel.isAccessibilityElement = true
        notifyStatusLabel.isAccessibilityElement = true

        referenceNoDescriptionLabel.isAccessibilityElement = true
        penaltyAmountDescriptionLabel.isAccessibilityElement = true
        siteLocationDescriptionLabel.isAccessibilityElement = true
        penaltyTypeDescriptionLabel.isAccessibilityElement = true
        penaltyDateDescriptionLabel.isAccessibilityElement = true
        emptyDescriptionLabel.isAccessibilityElement = true
        paymentDateDescriptionLabel.isAccessibilityElement = true
        authorizationCodeDescriptionLabel.isAccessibilityElement = true

        sendBySMSButton.isAccessibilityElement = true
        sendByEmailButton.isAccessibilityElement = true
        cancelTokenButton.isAccessibilityElement = true

        referenceNoLabel.isAccessibilityElement = true
        penaltyAmountLabel.isAccessibilityElement = true
        siteLocationLabel.isAccessibilityElement = true
        penaltyTypeLabel.isAccessibilityElement = true
        penaltyDateLabel.isAccessibilityElement = true
        emptyLabel.isAccessibilityElement = true
        paymentDateLabel.isAccessibilityElement = true
        authorizationCodeLabel.isAccessibilityElement = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func reachabilityDidChange(isReachable: Bool) {
        if isReachable {
            self.sendBySMSButton.isEnabled = true
            self.sendByEmailButton.isEnabled = true
            self.cancelTokenButton.isEnabled = true
        } else {
            self.sendBySMSButton.isEnabled = false
            self.sendByEmailButton.isEnabled = false
            self.cancelTokenButton.isEnabled = false
        }
    }
}
