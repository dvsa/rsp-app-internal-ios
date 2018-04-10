//
//  BaseViewModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 02/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

public protocol ViewModel: class {
    weak var delegate: ViewModelLoaderDelegate? { get set }
    func loadData()
}

public enum ViewModelLoadResult {
    case success(ViewModel)
    case error(Error)
}

public protocol ViewModelLoaderDelegate: class {
    func viewModelDidLoad(result: ViewModelLoadResult)
}

open class BaseViewModel: NSObject, ViewModel {

    public weak var delegate: ViewModelLoaderDelegate?

    public convenience init(delegate: ViewModelLoaderDelegate?) {
        self.init()
        self.delegate = delegate
    }

    public func loadData() {
        delegate?.viewModelDidLoad(result: .success(self))
    }
}
