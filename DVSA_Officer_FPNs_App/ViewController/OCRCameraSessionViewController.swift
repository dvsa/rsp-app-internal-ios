//
//  OCRCameraSessionViewController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 18/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import AVFoundation
import CoreGraphics

protocol OCRCameraSessionProtocol: class {
    func clearCell(indexPath: IndexPath)
    func retryButtonTapped()
    func confirmButtonTapped(indexPath: IndexPath, value: String)
}

class OCRCameraSessionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    internal weak var ocrSessionDelegate: OCRSessionDelegate?

    // UI components
    @IBOutlet weak var rangeFinderView: UIView!
    @IBOutlet weak var rangeFinderFocusView: UIView!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resultView: OCRConfirmationResultView!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var arrowView: TriangleView!
    @IBOutlet weak var helperLabel: UILabel!

    // Session variables
    internal var session: AVCaptureSession = AVCaptureSession()
    internal var videoDataOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    internal var backCamera: AVCaptureDevice? = AVCaptureDevice.default(for: AVMediaType.video)
    internal var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    internal var viewModel: OCRCameraSessionViewModel?
    internal var sessionRunning: Bool = false

    /** UI life cycles */

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    internal func initAccessiblityIDs() {
        scanButton.accessibilityIdentifier = "scanButton"
        scanButton.isAccessibilityElement = true
        flashButton.accessibilityIdentifier = "flashButton"
        flashButton.isAccessibilityElement = true
        arrowView.accessibilityIdentifier = "arrowView"
        arrowView.isAccessibilityElement = true
        helperLabel.accessibilityIdentifier = "helperLabel"
        helperLabel.isAccessibilityElement = true
    }

    static func instantiate(delegate: OCRSessionDelegate, viewModel: OCRCameraSessionViewModel) -> OCRCameraSessionViewController {
        let newViewController = OCRCameraSessionViewController.instantiateFromStoryboard(UIStoryboard.mainStoryboard())
        newViewController.ocrSessionDelegate = delegate
        newViewController.viewModel = viewModel
        return newViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        setupNavBar()
        initAccessiblityIDs()

        rangeFinderFocusView.layer.borderWidth = 1
        rangeFinderFocusView.layer.borderColor = UIColor.white.cgColor
        arrowView.fillColor = UIColor.dvsaOrange.cgColor
        helperLabel.backgroundColor = .dvsaOrange

        setupSession()
        session.startRunning()
        setupFocus()
    }

    override func viewWillDisappear(_ animated: Bool) {
        session.stopRunning()
        toggleDeviceFlash(turnOn: false)
        super.viewWillDisappear(animated)
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice.current.userInterfaceIdiom == .pad {
            session.sessionPreset = AVCaptureSession.Preset.photo
        } else {
            session.sessionPreset = AVCaptureSession.Preset.hd1920x1080
        }
    }

    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        videoPreviewLayer?.frame = rangeFinderView.bounds
    }

    internal func setupNavBar() {
        let cancelItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelButtonTapped))
        cancelItem.accessibilityIdentifier = "cancelButton"
        cancelItem.isAccessibilityElement = true
        self.navigationItem.leftBarButtonItem = cancelItem
    }

    internal func setupTable() {
        tableView.selectRow(at: IndexPath(row: 0, section: 0),
                            animated: false,
                            scrollPosition: .top)
        self.navigationItem.title = DetailsRowData.refNumber.resultViewTitle
    }

    /** Session setup */

    internal func setupSession() {
        setupInput()
    }

    /// Setup AVInput
    internal func setupInput() {
        if let camera = backCamera, let input = try? AVCaptureDeviceInput(device: camera),
            session.canAddInput(input) {
            session.addInput(input)
            setupOutput()
        }
    }

    /// Setup AVOutput
    internal func setupOutput() {
        let cameraQueue = DispatchQueue(label: "CameraQueue")
        videoDataOutput.setSampleBufferDelegate(self, queue: cameraQueue)
        videoDataOutput.alwaysDiscardsLateVideoFrames = true

        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            setupPreview()
        }
    }

    /// Setup preview rangefinder
    internal func setupPreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait

        if let unwrappedPreivewLayer = videoPreviewLayer {
            rangeFinderView.layer.addSublayer(unwrappedPreivewLayer)
        }
    }

    /// Setup focus points
    internal func setupFocus() {
        do {
            try backCamera?.lockForConfiguration()

            if let camera = backCamera, camera.isFocusModeSupported(.continuousAutoFocus) {
                backCamera?.focusMode = .continuousAutoFocus
                backCamera?.unlockForConfiguration()
            } else if let camera = backCamera, camera.isFocusPointOfInterestSupported {
                backCamera?.focusPointOfInterest = CGPoint(x: 0.5, y: 0.5)
                backCamera?.focusMode = .autoFocus
            }
            backCamera?.unlockForConfiguration()
        } catch {
            NSLog("Error locking camera when setting focus")
        }
    }

    /** AVCaptureVideoDataOutputSampleBufferDelegate methods */

    /// handles output, this is called for every frame
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        if sessionRunning {

            // got one frame, will process the frame and pause the sampling to save battery
            sessionRunning = false

            // completion block closure for frame buffer
            let block: (UIImage) -> Void = { image in
                log.info("expensive call!")
                if let indexPath = self.tableView.indexPathForSelectedRow,
                    let result = self.viewModel?.getTextFromImage(image: image, indexPath: indexPath),
                    TokenValidator.validateDateAndRef(string: result, indexPath: indexPath) {
                    self.showResultView(resultImage: image, resultText: result)
                } else {
                    // if no result found, should continue the frame sampling
                    self.sessionRunning = self.scanButton.isHighlighted
                }
            }

            // Process frame buffer
            ImageBufferUtils.processImageBuffer(sampleBuffer: sampleBuffer, completionBlock: block)
        }

    }

    /** UI actions */

    /// handles "Done" button event in the navigation bar, should save changes and back to previous view controller
    @IBAction func doneButtonTapped(_ sender: Any) {
        ocrSessionDelegate?.didTapDoneOCRSession(model: viewModel?.model)
    }

    /// handles "Cancel" button event in the navigation bar,, should cancel changes and back to previous view controller
    @objc func cancelButtonTapped() {
        ocrSessionDelegate?.didTapCancelOCRSession()
    }

    /// handles "Scan" button tapped event, should start OCR on tap
    @IBAction func scanButtonTapped(_ sender: Any) {
        log.info("session start")
        sessionRunning = true

    }

    /// handles "Scan" button tapped stopped event, should end OCR on tap, tracing Touch Up Inside/Outside gesture
    @IBAction func scanButtonTapEnded(_ sender: Any) {
        log.info("session end, cancel tap")
        sessionRunning = false
    }

    /// handles the flash button tap event, toggle back camera flash
    @IBAction func flashButtonTapped(_ sender: UIButton) {
        toggleDeviceFlash(turnOn: !flashButton.isSelected)
    }

    internal func toggleDeviceFlash(turnOn: Bool) {
        if let device = AVCaptureDevice.default(for: .video),
            device.hasTorch {
            do {
                try device.lockForConfiguration()
                if turnOn {
                    device.torchMode = .on
                    flashButton.isSelected = true
                } else {
                    device.torchMode = .off
                    flashButton.isSelected = false
                }
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        }
    }

    /// displays the result view with a quick ease in animation to simulate flash effect of camera
    internal func showResultView(resultImage: UIImage, resultText: String) {
        log.info("session end, got result")
        sessionRunning = false

        if let indexPath = tableView.indexPathForSelectedRow,
            let title = viewModel?.resultTitleForSelectedIndex(indexPath: indexPath) {
            resultView.setupContents(title: title,
                                     value: resultText,
                                     sessionDelegate: self,
                                     image: resultImage,
                                     indexPath: indexPath)
        }
        resultView.alpha = 0
        resultView.isHidden = false

        UIView.animate(withDuration: 0.1,
                       delay: 0.0,
                       options: [.curveEaseIn],
                       animations: {
                        self.resultView.alpha = 1.0
                        },
                       completion: {_ in })
    }

    internal func updateCellValue(at indexPath: IndexPath) {
        // Changing the text in the cell label only
        // Avoiding reload cell, because reloading cell will cancel selection
        if let cell = tableView.cellForRow(at: indexPath) as? OCRCameraSessionTableCell,
            let value = viewModel?.cellValueForSelectedIndex(indexPath: indexPath) {
            cell.setValueLabel(text: value)
        }
    }

    internal func toggleHelperView(indexPath: IndexPath) {
        if DetailsRowData(rawValue: indexPath.row) == .vehicleReg {
            arrowView.isHidden = false
            helperLabel.isHidden = false
        } else {
            arrowView.isHidden = true
            helperLabel.isHidden = true
        }
    }

}

// Extension for OCRCameraSessionProtocol

extension OCRCameraSessionViewController: OCRCameraSessionProtocol {

    /// handle the "Cross" button tapped event in cells
    func clearCell(indexPath: IndexPath) {
        viewModel?.clearValueAtIndex(indexPath: indexPath)
        updateCellValue(at: indexPath)
    }

    /// handle the "Retry" button event in the result view
    func retryButtonTapped() {
        resultView.isHidden = true
    }

    /// handle the "Confirm" button event in the result view
    func confirmButtonTapped(indexPath: IndexPath, value: String) {
        resultView.isHidden = true
        viewModel?.changeValueAtIndex(indexPath: indexPath, value: value)
        updateCellValue(at: indexPath)

        if let nextIndex = viewModel?.getNextEmptyFieldIndex(),
            let deselectIndex = tableView.indexPathForSelectedRow {
            // need to call the delegate methods "didDeselectRowAt" and "didSelectRowAt"
            // because selectRow method will NOT trigger table delegate methods.
            tableView.selectRow(at: nextIndex, animated: false, scrollPosition: .top)
            tableView(tableView, didDeselectRowAt: deselectIndex)
            tableView(tableView, didSelectRowAt: nextIndex)
        }
    }
}

// Extension for UITableView

extension OCRCameraSessionViewController: UITableViewDataSource, UITableViewDelegate {

    /*---- UITableView's UITableViewDataSource and UITableViewDelegate ----*/

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfRows ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "OCRSessionDetailsCell")

        if let OCRCell = cell as? OCRCameraSessionTableCell {

            if tableView.indexPathForSelectedRow == indexPath {
                OCRCell.setSelected(true, animated: false)
                self.navigationItem.title = DetailsRowData(rawValue: indexPath.row)?.resultViewTitle
            }

            OCRCell.setupCell(title: viewModel?.cellTitleForSelectedIndex(indexPath: indexPath) ?? "",
                           value: viewModel?.cellValueForSelectedIndex(indexPath: indexPath) ?? "",
                           indexPath: indexPath,
                           delegate: self)

            OCRCell.accessibilityIdentifier = String(format: "tableCellSection%dRow%d",
                                                     indexPath.section,
                                                     indexPath.row)
            OCRCell.isAccessibilityElement = true
        }
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? OCRCameraSessionTableCell {
            cell.labelBackground.backgroundColor = UIColor.dvsaOCRSelected
            self.navigationItem.title = DetailsRowData(rawValue: indexPath.row)?.resultViewTitle
            toggleHelperView(indexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? OCRCameraSessionTableCell {
            cell.labelBackground.backgroundColor = UIColor.dvsaOCRNormal
        }
    }
}
