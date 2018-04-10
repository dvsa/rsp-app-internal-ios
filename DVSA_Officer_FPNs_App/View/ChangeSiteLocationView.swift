//
//  ChangeSiteLocationView.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 24/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit

class ChangeSiteLocationView: UIView {

    weak var setLocationDelegate: SetLocationDelegate?

    @IBOutlet weak var siteLabel: UILabel!
    @IBOutlet weak var changeButton: UIButton!
    @IBAction func didTapChangeButton(_ sender: Any) {
        self.setLocationDelegate?.didTapChangeLocation()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }

    func commonInit() {
        self.siteLabel.accessibilityIdentifier = "siteLabel"
        self.changeButton.accessibilityIdentifier = "changeButton"

        self.siteLabel.isAccessibilityElement = true
        self.changeButton.isAccessibilityElement = true
    }

    var viewModel: PreferencesDataSourceProtocol = PreferencesDataSource.shared

    func updateUI() {
        var text = ""
        if let name = viewModel.site() {
            text = name.name
        } else {

        }

        let semiBoldAttributes = [
           NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]

        let lightAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .light)
        ]

        let attributedTextLabel = NSAttributedString(string: "Site: ", attributes: lightAttributes)
        let attributedTextValue = NSAttributedString(string: text, attributes: semiBoldAttributes)
        let attributedText = NSMutableAttributedString(attributedString: attributedTextLabel)
        attributedText.append(attributedTextValue)
        siteLabel.attributedText = attributedText
    }
}
