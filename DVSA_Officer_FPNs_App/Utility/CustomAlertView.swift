//
//  CustomAlertView.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 29/03/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit

protocol CustomAlertViewDelegate: class {
    func didTapOK()
}

class CustomAlertView: DesignableView {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var okButton: DesignableButton!
    @IBOutlet weak var imageView: UIImageView!

    weak var delegate: CustomAlertViewDelegate?

    @IBAction func didTapOK(_ sender: AnyObject) {
        self.delegate?.didTapOK()
    }
}
