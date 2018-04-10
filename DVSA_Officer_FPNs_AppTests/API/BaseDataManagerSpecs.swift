//
//  BaseDataManagerSpecs.swift
//  DVSA_Officer_FPNs_AppTests
//
//  Created by Andrea Scuderi on 29/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Quick
import Nimble
@testable import DVSA_Officer_FPNs_App

class BaseDataManagerSpecs: QuickSpec {

    //swiftlint:disable:next function_body_length cyclomatic_complexity
    override func spec() {

        describe("DataManager") {

            var dataManager: BaseAPIDataManager?
            var nextIndexDatasource: NextIndexDatasource!

            beforeEach {
                dataManager = BaseAPIDataManager()
                nextIndexDatasource = NextIndexDatasourceMock()
            }

            context("read") {
                context("valid response") {
                    it("should return nil") {
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
                    it("should return nil") {
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
                    it("should return nil") {
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
                    it("should return nil") {
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
                    it("should return nil") {
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
                    it("should return nil") {
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
                    it("should return nil") {
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
