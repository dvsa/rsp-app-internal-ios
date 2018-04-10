//
//  ListTableViewController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 02/10/2017.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit
import SVProgressHUD

struct ConfigureTable {
    let styleTable: UITableViewStyle
    let title: String
    weak var delegate: ListTableViewControllerDelegate?
    let cellStyle: UITableViewCellStyle
    let reuseIdentifier: String
}

class ListTableViewController<M: ListModel>: UITableViewController {

    typealias PopulateCellBlock = (M.Model, UITableViewCell) -> Void

    var viewModel: ListViewModel<M>?
    var populateCell: PopulateCellBlock?
    var configure: ConfigureTable?

    lazy var tableRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                 action: #selector(SiteListTableViewController.handleRefresh(refreshControl:)),
                                 for: UIControlEvents.valueChanged)
        return refreshControl
    }()

    @objc func handleRefresh(refreshControl: UIRefreshControl) {

        refreshControl.beginRefreshing()
        configure?.delegate?.refreshData { _ in
            DispatchQueue.main.async {
                refreshControl.endRefreshing()
            }
        }
    }

    init(viewModel: ListViewModel<M>, configure: ConfigureTable, populateCell: @escaping PopulateCellBlock) {
        self.viewModel = viewModel
        self.populateCell = populateCell
        self.configure = configure
        super.init(style: configure.styleTable)
        self.title = configure.title
    }

    func setup(viewModel: ListViewModel<M>, configure: ConfigureTable, populateCell: @escaping PopulateCellBlock) {
        self.viewModel = viewModel
        self.populateCell = populateCell
        self.configure = configure
        self.title = configure.title
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.addSubview(self.tableRefreshControl)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.count() ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let reuseIdentifier = configure?.reuseIdentifier ?? "ListTableViewControllerCell"
        var cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: configure?.cellStyle ?? .default, reuseIdentifier: reuseIdentifier)
        }
        guard let tableCell = cell else {
            return UITableViewCell()
        }

        if let item = viewModel?.item(for: indexPath.row) {
            populateCell?(item, tableCell)
        }
        tableCell.isAccessibilityElement = true
        tableCell.accessibilityIdentifier = "Cell_\(indexPath.section)_\(indexPath.row)"
        return tableCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = viewModel?.item(for: indexPath.row) as? ModelWithKey else {
            return
        }
        configure?.delegate?.didSelect(key: item.key())
    }

}
