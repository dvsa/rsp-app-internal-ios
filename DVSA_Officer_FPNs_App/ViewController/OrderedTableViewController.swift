//
//  OrderedTableViewController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 09/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit

struct ConfigureOrderedTable {
    let styleTable: UITableViewStyle
    let title: String
    weak var delegate: ListTableViewControllerDelegate?
    var collationStringSelector: Selector
    let cellStyle: UITableViewCellStyle
    let reuseIdentifier: String
}

protocol ListTableViewControllerDelegate: class {
    func didSelect(key: Int)
    func refreshData(completion: @escaping (Bool) -> Void)
}

class OrderedTableViewController<M: ListModel>: UITableViewController {

    typealias PopulateCellBlock = (M.Model, UITableViewCell) -> Void

    let collation = UILocalizedIndexedCollation.current()
    var sections: [[M.Model]] = []

    var viewModel: ListViewModel<M>? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            self.sections = sections(viewModel: viewModel)
            self.tableView.reloadData()
        }
    }

    var populateCell: PopulateCellBlock?
    var configure: ConfigureOrderedTable?

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

    init(viewModel: ListViewModel<M>, configure: ConfigureOrderedTable, populateCell: @escaping PopulateCellBlock) {

        self.configure = configure
        self.viewModel = viewModel
        self.populateCell = populateCell
        super.init(style: configure.styleTable)
        self.title = configure.title
        self.sections = sections(viewModel: viewModel)
    }

    func setup(viewModel: ListViewModel<M>, configure: ConfigureOrderedTable, populateCell: @escaping PopulateCellBlock) {

        self.configure = configure
        self.viewModel = viewModel
        self.populateCell = populateCell
        self.title = configure.title
        self.sections = sections(viewModel: viewModel)
    }

    func sections(viewModel: ListViewModel<M>) ->  [[M.Model]] {
        guard let configure = self.configure else {
            return []
        }
        let selector = configure.collationStringSelector
        let items = viewModel.model.all()
        guard let sortedObjects = collation.sortedArray(from: items, collationStringSelector: selector) as? [M.Model] else {
            return []
        }
        var sections = Array(repeating: [M.Model](), count: collation.sectionTitles.count)
        for object in sortedObjects {
            let sectionNumber = collation.section(for: object, collationStringSelector: selector)
            sections[sectionNumber].append(object)
        }
        return sections
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        return collation.sectionTitles[section]
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return collation.sectionIndexTitles
    }

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
      return collation.section(forSectionIndexTitle: index)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView?.addSubview(self.tableRefreshControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let reuseIdentifier = configure?.reuseIdentifier ?? "OrderedTableViewControllerCell"
        var cell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: configure?.cellStyle ?? .default, reuseIdentifier: reuseIdentifier)
        }
        guard let tableCell = cell else {
            return UITableViewCell()
        }

        let item = sections[indexPath.section][indexPath.row]
        populateCell?(item, tableCell)
        tableCell.isAccessibilityElement = true
        tableCell.accessibilityIdentifier = "Cell_\(indexPath.section)_\(indexPath.row)"
        return tableCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let item = sections[indexPath.section][indexPath.row] as? ModelWithKey else {
            return
        }
        configure?.delegate?.didSelect(key: item.key())
    }
}
