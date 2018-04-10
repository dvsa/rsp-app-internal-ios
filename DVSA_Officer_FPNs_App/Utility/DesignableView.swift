//
//  DesignableView.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 23/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

@IBDesignable
class DesignableView: UIView {

    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }

}

@IBDesignable
class DesignableButton: UIButton {

    var disabledBorderWidth: CGFloat = 0

    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0.5 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable var disabledTextColor: UIColor = UIColor.darkGray {
        didSet {
            self.setTitleColor(disabledTextColor, for: .disabled)
        }
    }

    @IBInspectable var disabledBackgroundColor: UIColor = UIColor.dvsaLightGray

    @IBInspectable var normalBackgroundColor: UIColor = UIColor.dvsaGreen

    override var isEnabled: Bool {
        didSet {
            self.backgroundColor = isEnabled ? normalBackgroundColor : disabledBackgroundColor
            self.layer.borderWidth = isEnabled ? borderWidth : disabledBorderWidth
        }
    }
}
