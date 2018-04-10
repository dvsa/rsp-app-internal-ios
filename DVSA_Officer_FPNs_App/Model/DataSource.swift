//
//  DataSource.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 09/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

enum DataSourceError: LocalizedError {
    case duplicateKey

    public var failureReason: String? {
        switch self {
        case .duplicateKey:
            return "A token already exists for this reference number."
        }
    }

    public var errorDescription: String? {
        switch self {
        case .duplicateKey:
            return "Duplicate"
        }
    }
}

protocol DataSource: class {
    //swiftlint:disable:next type_name
    associatedtype T
    //swiftlint:disable:next type_name
    associatedtype K

    func list() -> [T]?
    func item(for key: K) -> T?
    func insert(item: T) throws
    func update(item: T) throws
    func delete(item: T) throws
    func clean() throws
}

struct OpResultItem<T> {
    let item: T
    let succeded: Bool
}

struct OpResultItems<T> {
    let items: [OpResultItem<T>]?
}

protocol AsynchDataSource {
    //swiftlint:disable:next type_name
    associatedtype T
    //swiftlint:disable:next type_name
    associatedtype K

    /**
        Create item T

        - Parameter item: item to create
        - Parameter completion: returns created item or nil
    */
    func create(item: T, completion: @escaping (T?) -> Void)

    /**
        Read item with key

     - Parameter key: item key
     - Parameter completion: returns item with a key or nil
     */
    func read(for key: K, completion: @escaping (T?) -> Void)

    /**
        Update item with key

     - Parameter item: item to update
     - Parameter completion: returns item in case of success or nil in case of error
     */
    func update(item: T, completion: @escaping (T?) -> Void)

    /**
        Delete item with key

     - Parameter item: item to delete
     - Parameter completion: returns item in case of success or nil in case of error
     */
    func delete(item: T, completion: @escaping (T?) -> Void)

    /**
        List all items

     - Parameter completion: returns items in case of success or nil in case of error
     */
    func list(datasource: NextIndexDatasource, completion: @escaping ([T]?) -> Void)

    /**
        Update items

     - Parameter items: items to update
     - Parameter completion: returns OpResultItems in case of success or nil in case of error
     */
    func update(items: [T], completion: @escaping (OpResultItems<T>?) -> Void)
}
