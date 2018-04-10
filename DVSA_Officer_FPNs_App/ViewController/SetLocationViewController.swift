//
//  SetLocationViewController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 23/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit

class SetLocationViewController: UIViewController {

    @IBOutlet weak var selectLabel: UILabel!
    @IBOutlet weak var selectLocationLabel: UILabel!
    @IBOutlet weak var confirmLocationButton: UIButton!
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var locationTypeSegmented: UISegmentedControl!
    @IBOutlet weak var locationTypeLabel: UILabel!
    @IBOutlet weak var mobileAddressLabel: UILabel!
    @IBOutlet weak var mobileLocationTextField: UITextField!
    @IBOutlet weak var mobileAddressStackView: UIStackView!

    @IBOutlet var borderedView: DesignableView!
    weak var setLocationDelegate: SetLocationDelegate?

    var tapGesture: UITapGestureRecognizer?

    @IBAction func didTapSelectLocation(_ sender: Any) {
        self.setLocationDelegate?.didTapChangeLocation()
    }

    @IBAction func didTapConfirmLocation(_ sender: Any) {

        guard let viewModel = viewModel else {
            return
        }
        if viewModel.isMobile {
            let site = viewModel.temporaryMobileLocation
            self.setLocationDelegate?.didConfirmLocation(site: site, mobileAddress: viewModel.temporaryMobileAddress)
        } else {
            let site = viewModel.temporarySiteLocation
            self.setLocationDelegate?.didConfirmLocation(site: site, mobileAddress: nil)
        }
    }

    @IBAction func didChangeLocationType(_ sender: Any) {
        viewModel?.isMobile = self.locationTypeSegmented.selectedSegmentIndex != 0
        updateUI()
    }

    @IBAction func mobileLocationTextFieldChanged(_ sender: Any) {
        guard let viewModel = self.viewModel else {
            return
        }

        viewModel.temporaryMobileAddress = self.mobileLocationTextField.text
        self.confirmLocationButton.isHidden = !viewModel.isValid()
    }

    //Observer

    var viewModel: UserPreferencesViewModel? {
        didSet {
            if self.isViewLoaded {
                self.updateUI()
            }
        }
    }

    let defaultSiteText = "Site Location"
    let defaultMobileText = "Mobile Location"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Site Location"
        self.selectLocationLabel.text = defaultSiteText
        self.confirmLocationButton.setTitle("Confirm Location", for: .normal)
        self.applyStyle()
        self.enableUITest()
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSelectLocation(_:)))
        self.roundedView.addGestureRecognizer(self.tapGesture!)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let viewModel = self.viewModel {
            self.locationTypeSegmented.selectedSegmentIndex = viewModel.isMobile ? 1 : 0
        } else {
            self.locationTypeSegmented.selectedSegmentIndex = 0
        }
        self.updateUI()
    }

    func applyStyle() {

        self.roundedView.layer.cornerRadius = 8
        self.roundedView.backgroundColor = UIColor.dvsaLightGray

        StyleManager.roundedBorder(view: borderedView)
        self.confirmLocationButton.layer.cornerRadius = 8
        self.confirmLocationButton.setTitleColor(UIColor.white, for: .normal)
        self.confirmLocationButton.backgroundColor = UIColor.dvsaGreen

        StyleManager.segmented(segmented: locationTypeSegmented)
    }

    func enableUITest() {
        self.roundedView.accessibilityIdentifier = "selectView"
        self.roundedView.isAccessibilityElement = true

        self.confirmLocationButton.accessibilityIdentifier = "confirmLocationButton"
        self.confirmLocationButton.isAccessibilityElement = true

        self.selectLocationLabel.accessibilityIdentifier = "selectLocationLabel"
        self.selectLocationLabel.isAccessibilityElement = true

        self.locationTypeSegmented.accessibilityIdentifier = "locationTypeSegmented"
        self.locationTypeSegmented.isAccessibilityElement = true
        self.locationTypeLabel.accessibilityIdentifier = "locationTypeLabel"
        self.locationTypeLabel.isAccessibilityElement = true
        self.mobileAddressLabel.accessibilityIdentifier = "mobileAddressLabel"
        self.mobileAddressLabel.isAccessibilityElement = true
        self.mobileLocationTextField.accessibilityIdentifier = "mobileLocationTextField"
        self.mobileLocationTextField.isAccessibilityElement = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateUI() {
        if isViewLoaded {

            guard let viewModel = viewModel else {
                self.confirmLocationButton.isHidden = true
                return
            }

            self.locationTypeSegmented.selectedSegmentIndex = viewModel.isMobile ? 1 : 0
            self.mobileAddressLabel.text = "Mobile location"

            var text = ""
            if viewModel.isMobile {
                self.locationTypeLabel.text = "Enforcement area"
                if let mobileAddress = viewModel.temporaryMobileAddress {
                    self.mobileLocationTextField.text = viewModel.isMobile ? mobileAddress : ""
                } else {
                    self.mobileLocationTextField.text = ""
                }
                if let name = viewModel.temporaryMobileLocation?.name {
                    text = name
                } else {
                    text = viewModel.isMobile ? defaultMobileText : defaultSiteText
                }
            } else {
                self.locationTypeLabel.text = "Fixed site"
                if let name = viewModel.temporarySiteLocation?.name {
                    text = name
                } else {
                    text = viewModel.isMobile ? defaultMobileText : defaultSiteText
                }
                self.mobileLocationTextField.text = ""
            }
            self.mobileAddressStackView.isHidden = !viewModel.isMobile
            self.selectLocationLabel.text = text
            self.confirmLocationButton.isHidden = !viewModel.isValid()
            self.selectLocationLabel.setNeedsDisplay()
        }
    }

}
