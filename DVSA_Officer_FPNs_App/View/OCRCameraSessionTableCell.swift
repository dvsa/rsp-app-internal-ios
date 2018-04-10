//
//  OCRCameraSessionTableCell.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 23/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

class OCRCameraSessionTableCell: UITableViewCell {

    internal var cellIndex: IndexPath = IndexPath(row: 0, section: 0)
    internal weak var tableDelegate: OCRCameraSessionProtocol?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var labelBackground: DesignableView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupCell(title: String, value: String, indexPath: IndexPath, delegate: OCRCameraSessionProtocol) {
        cellIndex = indexPath
        tableDelegate = delegate
        titleLabel.text = title
        setValueLabel(text: value)
        selectionStyle = .none
        labelBackground.backgroundColor = isSelected ? UIColor.dvsaOCRSelected : UIColor.dvsaOCRNormal
        setupAccessibilityIDs()
    }

    internal func setupAccessibilityIDs() {
        titleLabel.accessibilityIdentifier = String(format: "cellTitleAtSecion%dRow%d", cellIndex.section, cellIndex.row)
        valueLabel.accessibilityIdentifier = String(format: "cellValueAtSecion%dRow%d", cellIndex.section, cellIndex.row)
        titleLabel.isAccessibilityElement = true
        valueLabel.isAccessibilityElement = true
    }

    func setValueLabel(text: String) {
        valueLabel.text = text
    }

    @IBAction func clearTapped(_ sender: Any) {
        tableDelegate?.clearCell(indexPath: cellIndex)
    }
}
