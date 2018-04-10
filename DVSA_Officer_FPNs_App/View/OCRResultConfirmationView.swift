//
//  OCRResultConfirmationView.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 23/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

class OCRConfirmationResultView: UIView {

    internal weak var delegate: OCRCameraSessionProtocol?
    internal var resultIndexPath: IndexPath = IndexPath(row: 0, section: 0)

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var confirmImageView: UIImageView!

    func setupContents(title: String, value: String, sessionDelegate: OCRCameraSessionProtocol, image: UIImage, indexPath: IndexPath) {
        titleLabel.text = title
        valueLabel.text = value
        confirmImageView.image = image
        delegate = sessionDelegate
        resultIndexPath = indexPath
    }

    @IBAction func retryButtonTapped(_ sender: Any) {
        delegate?.retryButtonTapped()
    }

    @IBAction func confirmButtonTapped(_ sender: Any) {
        delegate?.confirmButtonTapped(indexPath: resultIndexPath, value: valueLabel.text ?? "")
    }
}
