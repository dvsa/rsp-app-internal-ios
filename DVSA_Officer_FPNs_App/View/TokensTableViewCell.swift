//
//  TokensTableViewCell.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 06/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit

class TokensTableViewCell: UITableViewCell {

    @IBOutlet weak var regNoLabel: UILabel!
    @IBOutlet weak var titleBackground: DesignableView!
    @IBOutlet weak var refLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var newNotificationIcon: UIImageView!
    @IBOutlet weak var separatorLine: UIView!

    weak var overrideMessageDelegate: OverrideTokenMessageDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        regNoLabel.isAccessibilityElement = true
        regNoLabel.accessibilityIdentifier = "registrationLabel"
        refLabel.isAccessibilityElement = true
        refLabel.accessibilityIdentifier = "referenceLabel"
        amountLabel.isAccessibilityElement = true
        amountLabel.accessibilityIdentifier = "amountLabel"
        statusLabel.isAccessibilityElement = true
        statusLabel.accessibilityIdentifier = "statusLabel"
        statusImageView.isAccessibilityElement = true
        statusImageView.accessibilityIdentifier = "statusIcon"
        newNotificationIcon.isAccessibilityElement = true
        newNotificationIcon.accessibilityIdentifier = "notificationIcon"
        separatorLine.isAccessibilityElement = true
        separatorLine.accessibilityIdentifier = "separatorLine"
    }

    internal func setupUI(bodyObject: BodyObject) {

        if let token = bodyObject.value,
            let syncStatus = SynchStatusType(rawValue: bodyObject.status) {
            regNoLabel.text = token.vehicleDetails?.regNo
            refLabel.text = token.referenceNo
            amountLabel.text = "£" + token.penaltyAmount
            removeTapGestureFromImage()
            if let status = PaymentStatus(rawValue: UInt8(token.paymentStatus)),
                setSyncStatusUI(status: syncStatus),
                setChangedStatusUI(status: token.overridden) {
                setPaymentStatusUI(status: status)
            }
        }

        updateNotificationVisibility(bodyObject: bodyObject)
        setRevokeStatus(bodyObject: bodyObject)
    }

    internal func setSyncStatusUI(status: SynchStatusType) -> Bool {
        switch status {
        case .updated:
            return true
        case .pending:
            setupCellUI(titleColor: .clear,
                        statusText: "Not uploaded",
                        statusTextColor: .dvsaOrange,
                        statusImage: UIImage(named: "icon-no-connection"),
                        hideSeparatorLine: false)
            return false
        case .conflicted:
            setupCellUI(titleColor: .dvsaPinkBackground,
                        statusText: "Duplicate",
                        statusTextColor: .dvsaRed,
                        statusImage: nil,
                        hideSeparatorLine: true)
            return false
        }
    }

    internal func setChangedStatusUI(status: Bool) -> Bool {
        if status {
            setupCellUI(titleColor: .dvsaOrangeBackground,
                        statusText: "Details changed",
                        statusTextColor: .dvsaOrange,
                        statusImage: UIImage(named: "icon-overriden"),
                        hideSeparatorLine: true)
            addTapGestureToImage()
            return false
        }
        return true
    }

    internal func setPaymentStatusUI(status: PaymentStatus) {
        if status == .paid {
            setupCellUI(titleColor: .dvsaOCRSelected,
                        statusText: "Paid",
                        statusTextColor: .black,
                        statusImage: UIImage(named: "icon-paid"),
                        hideSeparatorLine: true)
        } else {
            setupCellUI(titleColor: .clear,
                        statusText: "Unpaid",
                        statusTextColor: .black,
                        statusImage: nil,
                        hideSeparatorLine: false)
        }
    }

    internal func setRevokeStatus(bodyObject: BodyObject) {
        if !bodyObject.enabled {
            setupCellUI(titleColor: .dvsaPinkBackground,
                        statusText: "Cancelled",
                        statusTextColor: .dvsaRed,
                        statusImage: UIImage(named: "InvalidInfo"),
                        hideSeparatorLine: true)
        }
    }

    internal func setupCellUI(titleColor: UIColor,
                              statusText: String,
                              statusTextColor: UIColor,
                              statusImage: UIImage?,
                              hideSeparatorLine: Bool) {
        statusLabel.text = statusText
        statusLabel.textColor = statusTextColor
        statusImageView.image = statusImage
        titleBackground.backgroundColor = titleColor
        separatorLine.isHidden = hideSeparatorLine
    }

    internal func updateNotificationVisibility(bodyObject: BodyObject) {
        let moreThan24Hours = Date().hours(from: bodyObject.offset) >= 24
        newNotificationIcon.isHidden = bodyObject.hideNotification || moreThan24Hours
    }

    internal func addTapGestureToImage() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showOverriddenMessage(tapGestureRecognizer:)))
        statusImageView.isUserInteractionEnabled = true
        statusImageView.addGestureRecognizer(tapGestureRecognizer)
    }

    internal func removeTapGestureFromImage() {
        statusImageView.gestureRecognizers = nil
    }

    @objc internal func showOverriddenMessage(tapGestureRecognizer: UITapGestureRecognizer) {
        overrideMessageDelegate?.showOverriddenMessage()
    }
}
