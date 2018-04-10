//
//  ListViewModel.swift
//  ExampleMVVMFlow
//
//  Created by apple on 03/07/16.
//  Copyright © 2016 Rodrigo Reis. All rights reserved.
//

import Foundation

class ListViewModel<T: ListModel>:BaseViewModel {
    var model: T

    init(model: T) {
        self.model = model
    }

    func count() -> Int {
        return model.all().count
    }

    func item(for index: Int) -> T.Model? {
        return model.item(at: index)
    }
}
