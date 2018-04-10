//
//  SendNotificationViewController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 26/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit
import Whisper
import SVProgressHUD

class SendNotificationViewController: UIViewController {

    @IBOutlet weak var addressTextLabel: UILabel!
    @IBOutlet weak var addressValueTextField: UITextField!
    @IBOutlet weak var addressExampleLabel: UILabel!
    @IBOutlet weak var invalidInfoButton: UIButton!

    @IBOutlet var roundedView: DesignableView!
    @IBOutlet weak var sendButton: DesignableButton!

    @IBOutlet weak var dimmedView: UIView!
    @IBOutlet weak var customAlertView: CustomAlertView!

    weak var sendNotificationDelegate: SendNotificationDelegate?

    var viewModel: DriverNotificationViewModel? {
        didSet {
            if self.isViewLoaded {
                self.updateUI()
            }
        }
    }

    @IBAction func didTapSend(_ sender: Any) {

        guard let viewModel = viewModel,
            let address = addressValueTextField.text else {
            return
        }
        SVProgressHUD.show()
        viewModel.send(address: address) { [weak self] (success) in
            log.info("Send \(viewModel.type) \(success)")
            SVProgressHUD.dismiss(withDelay: 0)
            DispatchQueue.main.async {
                if success {
                    self?.customAlertView.messageLabel.text = "Payment code sent"
                    self?.customAlertView.imageView.image = UIImage(named: "done")
                    self?.customAlertView.okButton.backgroundColor = .dvsaGreen
                    self?.dimmedView.isHidden = false
                } else {
                    self?.customAlertView.messageLabel.text = "There was a problem sending the payment code"
                    self?.customAlertView.imageView.image = UIImage(named: "error")
                    self?.customAlertView.okButton.backgroundColor = .dvsaRed
                    self?.dimmedView.isHidden = false
                }
            }
        }
    }

    @IBAction func addressTextFieldDidChange(_ sender: Any) {

        guard let textField = sender as? UITextField else {
            return
        }
        updateSendButton(address: textField.text)
    }

    @IBAction func invalidInfoButtonTapped(_ sender: Any) {
        guard let viewModel = viewModel else {
            return
        }

        let annoucement = Announcement(title: viewModel.invalidInfoMessage(), duration: 5)

        ColorList.Shout.background = UIColor.red
        ColorList.Shout.title = UIColor.white
        ColorList.Shout.subtitle = UIColor.white
        ColorList.Shout.dragIndicator = UIColor.white
        Whisper.show(shout: annoucement, to: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Send payment code"

        self.updateUI()
        self.applyStyle()
        self.enableUITest()
        self.customAlertView.delegate = self
        self.dimmedView.isHidden = true
        self.dimmedView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }

    func applyStyle() {
        StyleManager.greenButton(button: sendButton)
        StyleManager.roundedBorder(view: roundedView)
    }

    func enableUITest() {
        self.addressTextLabel.accessibilityIdentifier = "addressTextLabel"
        self.addressValueTextField.accessibilityIdentifier = "addressValueTextField"
        self.sendButton.accessibilityIdentifier = "sendButton"
        self.invalidInfoButton.accessibilityIdentifier = "invalidInfoButton"
        self.addressExampleLabel.accessibilityIdentifier = "addressExampleLabel"

        self.addressTextLabel.isAccessibilityElement = true
        self.addressValueTextField.isAccessibilityElement = true
        self.sendButton.isAccessibilityElement = true
        self.invalidInfoButton.isAccessibilityElement = true
        self.addressExampleLabel.isAccessibilityElement = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateUI() {
        guard let viewModel = viewModel else {
            return
        }

        switch viewModel.type {
        case .sms:
            self.addressTextLabel.text = "SMS payment code details to"
            self.title = "Send payment code by SMS"
            self.sendButton.setTitle("Send payment code", for: .normal)
            self.addressValueTextField.keyboardType = .phonePad
            self.addressExampleLabel.text = "e.g. 00487777123456"

        case .email:
            self.addressTextLabel.text = "E-mail payment code details to"
            self.title = "Send payment code by e-mail"
            self.sendButton.setTitle("Send payment code", for: .normal)
            self.addressValueTextField.keyboardType = .emailAddress
            self.addressExampleLabel.text = "e.g. username@example.com"
        }
        updateSendButton(address: self.addressValueTextField.text)
    }

    func updateSendButton(address: String?) {
        let containsValue = (address != nil) && (address != "")
        let nonEmptyAddress = address ?? ""
        let validAddress = viewModel?.isValid(address: nonEmptyAddress) ?? false
        self.sendButton.isEnabled = containsValue && validAddress
        let shouldHideInvalidHelper = !containsValue || validAddress
        updateInvalidHelperUI(hideUI: shouldHideInvalidHelper)
    }

    internal func updateInvalidHelperUI(hideUI: Bool) {
        if hideUI {
            self.invalidInfoButton.isHidden = true
            self.addressValueTextField.textColor = .black
        } else {
            self.invalidInfoButton.isHidden = false
            self.addressValueTextField.textColor = .dvsaRed
        }
    }
}

extension SendNotificationViewController: CustomAlertViewDelegate {

    func didTapOK() {
        UIView.animate(withDuration: 0.5, animations: {
            self.dimmedView.isHidden = true
        }, completion: { (_) in
            self.sendNotificationDelegate?.didSendNotification()
        })
    }
}
