//
//  BaseViewController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 02/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit

public class BaseViewController: UIViewController, ViewModelLoaderDelegate {

    public var viewModel: ViewModel = BaseViewModel()

    // MARK: - view controller livecycle methods
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel.delegate = self
        self.viewModel.loadData()

        self.addSubviews()
        self.layoutElements()
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        self.configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        self.configure()
    }

    // MARK: Configuration
    public func configure() {

    }

    // MARK: Manage View Stack
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

    // MARK: Manage Constraints
    public func layoutElements() {
        blockNonMainThread()
        if UI_USER_INTERFACE_IDIOM() == .pad {
            layoutElementsiPad()
        } else {
            layoutElementsiPhone()
        }
    }

    public func layoutElementsiPad() {

    }

    public func layoutElementsiPhone() {

    }

    // MARK: - view model delegate
    public func viewModelDidLoad(result: ViewModelLoadResult) {
        blockNonMainThread()
    }
}
