//
//  APIDataManagerSpecs.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 03/01/2018.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class NextIndexDatasourceMock: NextIndexDatasource {

    var done = TestDone()

    internal var currentOperation = NextIndexOperation()

    var newOffset: TimeInterval?

    func reset() {
        done["reset"] = true
        currentOperation = NextIndexOperation()
    }

    func updateOffsetIfNeeded(offset: TimeInterval?) {

        done["updateOffsetIfNeeded"] = true

        if let offset = offset,
            offset < currentOperation.currentOffset,
            currentOperation.isStarted == false,
            currentOperation.nextID == nil,
            currentOperation.nextOffset == nil {
            let newNextIndexOp = NextIndexOperation(currentOffset: offset, nextOffset: nil, nextID: nil, isStarted: false)
            self.setNextIndexOperation(operation: newNextIndexOp)
        }
    }

    func setNextIndexOperation(operation: NextIndexOperation) {
        done["setNextIndexOperation"] = true
        currentOperation = operation
    }

    func updateNextIndexOperation() {

        done["updateNextIndexOperation"] = true

        if !currentOperation.isStarted && currentOperation.nextID == nil,
            let offset = newOffset {
            let nextOperation = NextIndexOperation(currentOffset: offset, nextOffset: nil, nextID: nil, isStarted: false)
            setNextIndexOperation(operation: nextOperation)
        }
    }

    func getNextIndexOperation() -> NextIndexOperation {
        return currentOperation
    }
}

class APIDataManagerSpecs: QuickSpec {

    //swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        var dataManager: APIDataManager?
        var apiServiceMock: APIServiceMock!
        var nextIndexDatasource: NextIndexDatasource!

        describe("APIDataManager") {
            beforeEach {
               dataManager = APIDataManager()
               apiServiceMock = APIServiceMock()
               nextIndexDatasource = NextIndexDatasourceMock()
            }
            context("apiService") {
                it("should be a DVSAMobileBackendDevClient") {
                    expect(dataManager?.apiService as? AWSMobileBackendAPIClient).toNot(beNil())
                }
            }

            context("read") {
                context("valid response") {
                    it("should return a model") {
                        apiServiceMock.isValidModel = true
                        dataManager?.apiService = apiServiceMock

                        var model: AWSBodyModel?
                        dataManager?.read(for: "820500000877") { (result) in
                            model = result
                        }
                        expect(model).toNotEventually(beNil())
                    }
                }

                context("invalid response") {
                    it("should return nil") {
                        apiServiceMock.isValidModel = false
                        dataManager?.apiService = apiServiceMock

                        var model: AWSBodyModel?
                        dataManager?.read(for: "820500000877") { (result) in
                            model = result
                        }
                        expect(model).toEventually(beNil())
                    }
                }

                context("error") {
                    it("should return nil") {
                        apiServiceMock.setupWithError()
                        dataManager?.apiService = apiServiceMock

                        var model: AWSBodyModel?
                        dataManager?.read(for: "820500000877") { (result) in
                            model = result
                        }
                        expect(model).toEventually(beNil())
                    }
                }
            }

            context("create") {
                context("valid response") {
                    it("should return a model") {
                        apiServiceMock.isValidModel = true
                        dataManager?.apiService = apiServiceMock

                        var model: AWSBodyModel?
                        dataManager?.create(item: DataMock.shared.bodyModel!) { (result) in
                            model = result
                        }
                        expect(model).toNotEventually(beNil())
                    }
                }

                context("invalid response") {
                    it("should return nil") {
                        apiServiceMock.isValidModel = false
                        dataManager?.apiService = apiServiceMock

                        var model: AWSBodyModel?
                        dataManager?.create(item: DataMock.shared.bodyModel!) { (result) in
                            model = result
                        }
                        expect(model).toEventually(beNil())
                    }
                }

                context("error") {
                    it("should return nil") {
                        apiServiceMock.setupWithError()
                        dataManager?.apiService = apiServiceMock

                        var model: AWSBodyModel?
                         dataManager?.create(item: DataMock.shared.bodyModel!) { (result) in
                            model = result
                        }
                        expect(model).toEventually(beNil())
                    }
                }
            }

            context("update") {
                context("valid response") {
                    it("should return a model") {
                        apiServiceMock.isValidModel = true
                        dataManager?.apiService = apiServiceMock

                        var model: AWSBodyModel?
                        dataManager?.update(item: DataMock.shared.bodyModel!) { (result) in
                            model = result
                        }
                        expect(model).toNotEventually(beNil())
                    }
                }

                context("invalid response") {
                    it("should return nil") {
                        apiServiceMock.isValidModel = false
                        dataManager?.apiService = apiServiceMock

                        var model: AWSBodyModel?
                        dataManager?.update(item: DataMock.shared.bodyModel!) { (result) in
                            model = result
                        }
                        expect(model).toEventually(beNil())
                    }
                }

                context("error") {
                    it("should return nil") {
                        apiServiceMock.setupWithError()
                        dataManager?.apiService = apiServiceMock

                        var model: AWSBodyModel?
                        dataManager?.update(item: DataMock.shared.bodyModel!) { (result) in
                            model = result
                        }
                        expect(model).toEventually(beNil())
                    }
                }
            }

            context("delete") {
                context("valid response") {
                    it("should return a model") {
                        apiServiceMock.isValidModel = true
                        dataManager?.apiService = apiServiceMock

                        var model: AWSBodyModel?
                        dataManager?.delete(item: DataMock.shared.bodyModel!) { (result) in
                            model = result
                        }
                        expect(model).toNotEventually(beNil())
                    }
                }

                context("invalid response") {
                    it("should return nil") {
                        apiServiceMock.isValidModel = false
                        dataManager?.apiService = apiServiceMock

                        var model: AWSBodyModel?
                        dataManager?.delete(item: DataMock.shared.bodyModel!) { (result) in
                            model = result
                        }
                        expect(model).toEventually(beNil())
                    }
                }

                context("error") {
                    it("should return nil") {
                        apiServiceMock.setupWithError()
                        dataManager?.apiService = apiServiceMock

                        var model: AWSBodyModel?
                        dataManager?.delete(item: DataMock.shared.bodyModel!) { (result) in
                            model = result
                        }
                        expect(model).toEventually(beNil())
                    }
                }

            }

            context("list") {
                context("valid response") {
                    it("should return a model") {
                        apiServiceMock.isValidModel = true
                        dataManager?.apiService = apiServiceMock

                        var model: [AWSBodyModel]?
                        dataManager?.list(datasource: nextIndexDatasource) { (result) in
                            model = result
                        }
                        expect(model).toNotEventually(beNil())
                    }
                }

                context("invalid response") {
                    it("should return nil") {
                        apiServiceMock.isValidModel = false
                        dataManager?.apiService = apiServiceMock

                        var model: [AWSBodyModel]?
                        dataManager?.list(datasource: nextIndexDatasource) { (result) in
                            model = result
                        }
                        expect(model).toEventually(beNil())
                    }
                }

                context("error") {
                    it("should return nil") {
                        apiServiceMock.setupWithError()
                        dataManager?.apiService = apiServiceMock

                        var model: [AWSBodyModel]?
                        dataManager?.list(datasource: nextIndexDatasource) { (result) in
                            model = result
                        }
                        expect(model).toEventually(beNil())
                    }
                }
            }

            context("updateItems") {
                context("valid response") {
                    it("should return a model") {
                        apiServiceMock.isValidModel = true
                        dataManager?.apiService = apiServiceMock

                        let items = DataMock.shared.bodyListModel!.items!
                        var model: OpResultItems<AWSBodyModel>?
                        dataManager?.update(items: items) { (result) in
                            model = result
                        }
                        expect(model).toNotEventually(beNil())
                    }
                }

                context("invalid response") {
                    it("should return nil") {
                        apiServiceMock.isValidModel = false
                        dataManager?.apiService = apiServiceMock

                        let items = DataMock.shared.bodyListModel!.items!
                        var model: OpResultItems<AWSBodyModel>?
                        dataManager?.update(items: items) { (result) in
                            model = result
                        }
                        expect(model).toEventually(beNil())
                    }
                }

                context("error") {
                    it("should return nil") {
                        apiServiceMock.setupWithError()
                        dataManager?.apiService = apiServiceMock

                        let items = DataMock.shared.bodyListModel!.items!
                        var model: OpResultItems<AWSBodyModel>?
                        dataManager?.update(items: items) { (result) in
                            model = result
                        }
                        expect(model).toEventually(beNil())
                    }
                }
            }

            context("sites") {
                context("valid response") {
                    it("should return a model") {
                        apiServiceMock.isValidModel = true
                        dataManager?.apiService = apiServiceMock

                        var model: [AWSSiteModel]?
                        dataManager?.sites { (result) in
                            model = result
                        }
                        expect(model).toNotEventually(beNil())
                    }
                }

                context("invalid response") {
                    it("should return nil") {
                        apiServiceMock.isValidModel = false
                        dataManager?.apiService = apiServiceMock

                        var model: [AWSSiteModel]?
                        dataManager?.sites { (result) in
                            model = result
                        }
                        expect(model).toEventually(beNil())
                    }
                }

                context("error") {
                    it("should return nil") {
                        apiServiceMock.setupWithError()
                        dataManager?.apiService = apiServiceMock

                        var model: [AWSSiteModel]?
                        dataManager?.sites { (result) in
                            model = result
                        }
                        expect(model).toEventually(beNil())
                    }
                }
            }
        }
    }
}
