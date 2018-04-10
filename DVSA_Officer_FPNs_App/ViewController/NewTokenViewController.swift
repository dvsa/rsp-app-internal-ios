//
//  NewTokenViewController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 09/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import IQKeyboardManagerSwift
import Whisper

class NewTokenViewController: BaseSiteChangeViewController {

    weak var newTokenDelegate: NewTokenDelegate?

    @IBOutlet weak var penaltyTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var refNumberTextField: UITextField!
    @IBOutlet weak var vehicleRegTextField: UITextField!
    @IBOutlet weak var dateTimeTextField: UITextField!
    @IBOutlet weak var penaltyAmountTextField: UITextField!
    @IBOutlet weak var scanButton: DesignableButton!
    @IBOutlet weak var createButton: DesignableButton!

    @IBOutlet weak var referenceStackView: UIStackView!

    @IBOutlet var imReference1TextField: UITextField!
    @IBOutlet var imReference2TextField: UITextField!
    @IBOutlet var im0Label: UILabel!
    @IBOutlet var im1Label: UILabel!
    @IBOutlet var im2Label: UILabel!
    @IBOutlet weak var imReferenceWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var refInvalidInfoBtn: UIButton!
    @IBOutlet weak var regInvalidInfoBtn: UIButton!
    @IBOutlet weak var dateInvalidInfoBtn: UIButton!
    @IBOutlet weak var amtInvalidInfoBtn: UIButton!

    @IBOutlet var roundedViews: [DesignableView]!

    var clearAllButton: UIBarButtonItem?

    let maxIMWidthConstraint: CGFloat = 180

    var viewModel: NewTokenViewModel {
        didSet {
            bindToViewModel(animated: false)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        self.viewModel = NewTokenViewModel()
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.viewModel = NewTokenViewModel()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.commonInit()
    }

    func commonInit() {
        clearAllButton = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearAll))
    }

    func enableUITest() {
        self.penaltyTypeSegmentedControl.accessibilityIdentifier = "penaltyTypeSegmentedControll"
        self.refNumberTextField.accessibilityIdentifier = "refNumberTextField"
        self.vehicleRegTextField.accessibilityIdentifier = "vehicleRegTextField"
        self.dateTimeTextField.accessibilityIdentifier = "dateTimeTextField"
        self.penaltyAmountTextField.accessibilityIdentifier = "penaltyAmountTextField"
        self.imReference1TextField.accessibilityIdentifier = "imReference1TextField"
        self.imReference2TextField.accessibilityIdentifier = "imReference2TextField"
        self.im0Label.accessibilityIdentifier = "im0Label"
        self.im1Label.accessibilityIdentifier = "im1Label"
        self.im2Label.accessibilityIdentifier = "im2Label"
        self.scanButton.accessibilityIdentifier = "scanButton"
        self.createButton.accessibilityIdentifier = "createButton"
        self.amtInvalidInfoBtn.accessibilityIdentifier = "invalidAmountInfoButton"
        self.refInvalidInfoBtn.accessibilityIdentifier = "invalidRefInfoButton"
        self.regInvalidInfoBtn.accessibilityIdentifier = "invalidRegInfoButton"
        self.dateInvalidInfoBtn.accessibilityIdentifier = "invalidDateInfoButton"

        self.penaltyTypeSegmentedControl.isAccessibilityElement = true
        self.refNumberTextField.isAccessibilityElement = true
        self.vehicleRegTextField.isAccessibilityElement = true
        self.dateTimeTextField.isAccessibilityElement = true
        self.penaltyAmountTextField.isAccessibilityElement = true
        self.imReference1TextField.isAccessibilityElement = true
        self.imReference2TextField.isAccessibilityElement = true
        self.im0Label.isAccessibilityElement = true
        self.im1Label.isAccessibilityElement = true
        self.im2Label.isAccessibilityElement = true
        self.scanButton.isAccessibilityElement = true
        self.createButton.isAccessibilityElement = true
        self.amtInvalidInfoBtn.isAccessibilityElement = true
        self.refInvalidInfoBtn.isAccessibilityElement = true
        self.regInvalidInfoBtn.isAccessibilityElement = true
        self.dateInvalidInfoBtn.isAccessibilityElement = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "New payment code"
        self.imReferenceWidthConstraint.constant = 0
        self.applyStyle()
        self.enableUITest()
        self.createButton.setTitle("Create code", for: .normal)
        self.scanButton.setTitle("Scan details", for: .normal)
        self.navigationItem.leftBarButtonItem = clearAllButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindToViewModel(animated: false)
    }

    func applyStyle() {
        StyleManager.segmented(segmented: penaltyTypeSegmentedControl)
        StyleManager.greenButton(button: createButton)
        StyleManager.grayButton(button: scanButton)
        StyleManager.roundedBorder(views: roundedViews)
    }

    internal func bindToViewModel(animated: Bool) {

        guard self.isViewLoaded else { return }

        let components = viewModel.immobReferenceComponents()
        if components.count == 3 {
            refNumberTextField.text = components[0]
            imReference1TextField.text = components[1]
            imReference2TextField.text = components[2]
        } else {
            refNumberTextField.text = viewModel.model.referenceNo
            imReference1TextField.text = ""
            imReference2TextField.text = ""
        }
        penaltyTypeSegmentedControl.selectedSegmentIndex = Int(viewModel.model.penaltyType.rawValue)
        if viewModel.model.penaltyType == .immobilization {
            imReference1TextField.ignoreSwitchingByNextPrevious = false
            imReference2TextField.ignoreSwitchingByNextPrevious = false
        } else {
            imReference1TextField.ignoreSwitchingByNextPrevious = true
            imReference2TextField.ignoreSwitchingByNextPrevious = true
        }
        vehicleRegTextField.text = viewModel.model.vehicleRegNo
        dateTimeTextField.text = viewModel.model.dateTime?.dvsaDateString
        penaltyAmountTextField.text = viewModel.model.penaltyAmount

        var duration: TimeInterval = 0.2
        if viewModel.model.penaltyType == .immobilization {
            duration = 0.3
            self.imReferenceWidthConstraint.constant = maxIMWidthConstraint
        } else {
            self.imReferenceWidthConstraint.constant = 0
        }
        if animated {
            UIView.animate(withDuration: duration) {
                self.view.layoutIfNeeded()
            }
        }
        updateUIWithValidation(self)
    }

    @IBAction func dateTimeStartEditing(sender: UITextField) {

        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        datePickerView.maximumDate = Date.todayUTC
        datePickerView.minimumDate = Calendar.utc.date(byAdding: .day, value: -29, to: Date.todayUTC)
        datePickerView.locale = Locale(identifier: "en_GB")
        datePickerView.timeZone = TimeZone(abbreviation: "UTC")
        sender.inputView = datePickerView
        datePickerView.date = viewModel.model.dateTime ?? Date.todayUTC
        setDateTime(date: datePickerView.date)
        datePickerView.addTarget(self, action: #selector(self.dateTimePickerEndEditing(sender:)), for: UIControlEvents.valueChanged)
    }

    @objc func dateTimePickerEndEditing(sender: UIDatePicker) {
        setDateTime(date: sender.date)
    }

    private func setDateTime(date: Date) {
        dateTimeTextField.text = date.dvsaDateString
        viewModel.updateDateTime(dateTime: date.dateOnlyUTC)
    }

    @IBAction func refNumberChanged(_ sender: Any) {
        if self.penaltyTypeSegmentedControl.selectedSegmentIndex == Int(PenaltyType.immobilization.rawValue) {

            let field0 = refNumberTextField.text ?? ""
            let field1 = imReference1TextField.text ?? ""
            let field2 = imReference2TextField.text ?? ""
            let referenceNo = "\(field0)-\(field1)-\(field2)-IM"
            viewModel.updateRefNumber(refNumber: referenceNo)
        } else {
            viewModel.updateRefNumber(refNumber: refNumberTextField.text)
        }
    }

    @IBAction func vehicleRegChanged(_ sender: Any) {
        viewModel.updateVehicleReg(vehicleRegNo: vehicleRegTextField.text)
    }

    @IBAction func penaltyAmountChanged(_ sender: Any) {
        viewModel.updatePenaltyAmount(penaltyAmount: penaltyAmountTextField.text)
    }

    @IBAction func segmentedControlIndexChanged( sender: UISegmentedControl) {
        viewModel.updateDocumentType(index: sender.selectedSegmentIndex)
        viewModel.updateRefNumber(refNumber: "")
        bindToViewModel(animated: true)
    }

    internal func setColor(text: String?, isValid: Bool) -> UIColor {

        if text == "" {
            return .black
        }
        guard text != nil else {
            return .black
        }
        return isValid ? .black : .red
    }

    @IBAction func updateUIWithValidation(_ sender: Any) {

        guard self.isViewLoaded else { return }

        if viewModel.model.penaltyType == .immobilization {
            refNumberTextField.textColor = setColor(text: refNumberTextField.text,
                                                    isValid: TokenValidator.isValidIMReference(text: refNumberTextField.text, component: 0))
            imReference1TextField.textColor = setColor(text: imReference1TextField.text,
                                                    isValid: TokenValidator.isValidIMReference(text: imReference1TextField.text, component: 1))
            imReference2TextField.textColor = setColor(text: imReference2TextField.text,
                                                    isValid: TokenValidator.isValidIMReference(text: imReference2TextField.text, component: 2))

            refInvalidInfoBtn.isHidden = (refNumberTextField.textColor == .black || refNumberTextField.text!.isEmpty) &&
                (imReference1TextField.textColor == .black || imReference1TextField.text!.isEmpty) &&
                (imReference2TextField.textColor == .black || imReference2TextField.text!.isEmpty)
        } else {
            refNumberTextField.textColor = setColor(text: refNumberTextField.text, isValid: viewModel.isRefValid)
            imReference1TextField.textColor = .black
            imReference2TextField.textColor = .black

            refInvalidInfoBtn.isHidden = viewModel.isRefValid || refNumberTextField.text!.isEmpty
        }

        vehicleRegTextField.textColor = setColor(text: vehicleRegTextField.text, isValid: viewModel.isVehRegValid)
        regInvalidInfoBtn.isHidden = viewModel.isVehRegValid || vehicleRegTextField.text!.isEmpty

        dateTimeTextField.textColor = setColor(text: dateTimeTextField.text, isValid: viewModel.isDateValid)
        dateInvalidInfoBtn.isHidden = viewModel.isDateValid || dateTimeTextField.text!.isEmpty

        penaltyAmountTextField.textColor = setColor(text: penaltyAmountTextField.text, isValid: viewModel.isAmountValid)
        amtInvalidInfoBtn.isHidden = viewModel.isAmountValid || penaltyAmountTextField.text!.isEmpty

        createButton.isEnabled = viewModel.isValidDocument()
    }

    @IBAction func didTapCreate(_ sender: Any) {
        newTokenDelegate?.didTapCreateToken()
    }

    @IBAction func scanButtonTapped(_ sender: Any) {
        newTokenDelegate?.didTapStartOCRSession()
    }

    @objc func clearAll() {
        self.viewModel = NewTokenViewModel()
    }

    @IBAction func invalidInfoBtnTapped(_ sender: UIButton) {
        let annoucement = Announcement(title: viewModel.invalidInfoMessage(), duration: 5)

        ColorList.Shout.background = UIColor.red
        ColorList.Shout.title = UIColor.white
        ColorList.Shout.subtitle = UIColor.white
        ColorList.Shout.dragIndicator = UIColor.white
        Whisper.show(shout: annoucement, to: self)
    }
}
