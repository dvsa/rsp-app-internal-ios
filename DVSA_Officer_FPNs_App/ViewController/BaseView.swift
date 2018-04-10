//
//  BaseView.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 02/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit

public class BaseView: UIView {

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        self.configure()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func configure() {
        self.isAccessibilityElement = true
        self.addSubviews()
        self.layoutElements()
    }

    // MARK: - Manage View Stack
    public func addSubviews() {
        blockNonMainThread()
        if UI_USER_INTERFACE_IDIOM() == .pad {
            self.addSubviewsiPad()
        } else {
            self.addSubviewsiPhone()
        }

    }

    public func addSubviewsiPad() {

    }

    public func addSubviewsiPhone() {

    }

    // MARK: - Manage Constraints
    public func layoutElements() {
        blockNonMainThread()
        if UI_USER_INTERFACE_IDIOM() == .pad {
            self.layoutElementsiPad()
        } else {
            self.layoutElementsiPhone()
        }
    }

    public func layoutElementsiPad() {

    }

    public func layoutElementsiPhone() {

    }
}
