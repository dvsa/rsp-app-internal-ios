//
//  DataManager.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 27/11/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

class BaseAPIDataManager: AsynchDataSource {
    func create(item: AWSBodyModel, completion: @escaping (AWSBodyModel?) -> Void) {
        completion(nil)
    }

    func read(for key: String, completion: @escaping (AWSBodyModel?) -> Void) {
        completion(nil)
    }

    func update(item: AWSBodyModel, completion: @escaping (AWSBodyModel?) -> Void) {
        completion(nil)
    }

    func delete(item: AWSBodyModel, completion: @escaping (AWSBodyModel?) -> Void) {
        completion(nil)
    }

    func list(datasource: NextIndexDatasource, completion: @escaping ([AWSBodyModel]?) -> Void) {
        completion(nil)
    }

    func update(items: [AWSBodyModel], completion: @escaping (OpResultItems<AWSBodyModel>?) -> Void) {
        completion(nil)
    }

    func sites(completion: @escaping ([AWSSiteModel]?) -> Void) {
        completion(nil)
    }

    typealias T = AWSBodyModel
    typealias K = String
}

class APIDataManager: BaseAPIDataManager {

    static let shared = APIDataManager()

    typealias T = AWSBodyModel
    typealias K = String

    var apiService: APIServiceProtcol = AWSMobileBackendAPIClient.default()

    override func read(for key: String, completion: @escaping (AWSBodyModel?) -> Void) {
        apiService.documentIDGet(key: key).continueWith {(task) -> Void in
            if task.error == nil {
                if let model = task.result as? AWSBodyModel {
                    log.info("Received AWSBodyModel")
                    completion(model)
                } else {
                    log.warning("AWSBodyModel is nil")
                    completion(nil)
                }
            } else {
                log.error(task.error)
                completion(nil)
            }
            return
        }
    }

    override func create(item: AWSBodyModel, completion: @escaping (AWSBodyModel?) -> Void) {

        guard let key = item.key else {
            completion(nil)
            return
        }
        apiService.documentIDPut(key: key, body: item).continueWith {(task) -> Void in

            if task.error == nil {
                if let item = task.result as? AWSBodyModel {
                    log.info("Received AWSBodyModel")
                    completion(item)
                } else {
                    log.warning("AWSBodyModel is nil")
                    completion(nil)
                }
            } else {
                log.error(task.error)
                completion(nil)
            }
            return
        }
    }

    override func update(item: AWSBodyModel, completion: @escaping (AWSBodyModel?) -> Void) {

        guard let key = item.key else {
            completion(nil)
            return
        }
        apiService.documentIDPost(key: key, body: item).continueWith {(task) -> Void in
            if task.error == nil {
                if let item = task.result as? AWSBodyModel {
                    log.info("Received AWSBodyModel")
                    completion(item)
                } else {
                    log.warning("AWSBodyModel is nil")
                    completion(nil)
                }
            } else {
                log.error(task.error)
                completion(nil)
            }
            return
        }
    }

    override func delete(item: AWSBodyModel, completion: @escaping (AWSBodyModel?) -> Void) {

        guard let key = item.key else {
            completion(nil)
            return
        }
        apiService.documentIDDelete(key: key, body: item).continueWith {(task) -> Void in
            if task.error == nil {
                if let item = task.result as? AWSBodyModel {
                    log.info("Received AWSBodyModel")
                    completion(item)
                } else {
                    log.warning("AWSBodyModel is nil")
                    completion(nil)
                }
            } else {
                log.error(task.error)
                completion(nil)
            }
            return
        }
    }

    func taskDocumentGet(operation: NextIndexOperation,
                         datasource: NextIndexDatasource,
                         completion: @escaping ([AWSBodyModel]?) -> Void) -> AWSTask<AnyObject>? {

        let currentOffset = operation.currentOffset

        return apiService.documentsGet(offset: currentOffset, nextOffset: operation.nextOffset, nextID: operation.nextID)
            .continueWith { (task) -> AWSTask<AnyObject>? in
                if task.error == nil {
                    if let model = task.result as? AWSBodyListModel {
                        log.info("Received AWSBodyListModel")
                        completion(model.items)

                        let finished = model.nextOperation?.nextID == nil
                        let nextOperation = NextIndexOperation(currentOffset: currentOffset,
                                                              nextOffset: model.nextOperation?.nextOffset?.timeIntervalSince1970,
                                                              nextID: model.nextOperation?.nextID,
                                                              isStarted: !finished)
                        datasource.setNextIndexOperation(operation: nextOperation)
                        log.info("currentOffset: \(nextOperation.currentOffset)")
                        log.info("exclusiveStartKey: \(nextOperation.nextID ?? "nil")")
                        log.info("isStarted: \(nextOperation.isStarted)")
                        if !finished {
                            return self.taskDocumentGet(operation: nextOperation, datasource: datasource, completion: completion)
                        } else {
                            return nil
                        }
                    } else {
                        log.warning("AWSBodyListModel is nil")
                        completion(nil)
                    }
                } else {
                    log.error(task.error)
                    completion(nil)
                }
                return nil
            }
    }

    override func list(datasource: NextIndexDatasource, completion: @escaping ([AWSBodyModel]?) -> Void) {

        let downloadOp = datasource.getNextIndexOperation()

        log.verbose(downloadOp)
        log.info("list")

        let task = taskDocumentGet(operation: downloadOp, datasource: datasource, completion: completion)
        task?.continueWith { (task) -> Void in
            if let error = task.error {
                log.error(error)
            } else {
                log.info("list finished")
                datasource.updateNextIndexOperation()
            }
            return
        }
    }

    override func update(items: [AWSBodyModel], completion: @escaping (OpResultItems<AWSBodyModel>?) -> Void) {

        let list = AWSBodyListModel()!
        list.items = items
        apiService.documentsPost(body: list).continueWith { (task) -> Void in

            if task.error == nil {
                if let model = task.result as? AWSOperationResultListModel {
                    log.info("Received AWSOperationResultListModel")
                    let opResultItems = model.toOpResultItems()
                    completion(opResultItems)
                } else {
                    log.warning("AWSOperationResultListModel is nil")
                    completion(nil)
                }
            } else {
                log.error(task.error)
                completion(nil)
            }
            return
        }
    }

    override func sites(completion: @escaping ([AWSSiteModel]?) -> Void) {

        apiService.sitesGet().continueWith { (task) -> Void in
            if task.error == nil {
                if let model = task.result as? AWSSiteListModel {
                    log.info("Received AWSSiteListModel")
                    completion(model.items)
                } else {
                    log.warning("AWSSiteListModel is nil")
                    completion(nil)
                }
            } else {
                log.error(task.error)
                completion(nil)
            }
            return
        }
    }
}
