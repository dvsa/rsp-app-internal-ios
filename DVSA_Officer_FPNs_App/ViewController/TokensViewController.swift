//
//  TokensViewController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 24/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit
import Whisper

protocol TokenDetailsDelegate: class {
    func showTokenDetails(model: BodyObject)
}

protocol RefreshTableDelegate: class {
    func refreshTable()
}

protocol OverrideTokenMessageDelegate: class {
    func showOverriddenMessage()
}

class TokensViewController: BaseSiteChangeViewController, ReachabilityObserverDelegate {

    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var noDataTextView: UIView?

    @IBOutlet weak var newTokenButton: DesignableButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var lastSyncLabel: UILabel!

    weak var switchTabDelegate: SwitchTabDelegate?
    weak var tokenDetailsDelegate: TokenDetailsDelegate?

    lazy var reachabilityObserver = ReachabilityObserver(name: "TokensViewController", delegate: self)

    internal var viewModel = TokensListViewModel(datasource: PersistentDataSource())
    lazy var tableRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                 action: #selector(TokensViewController.handleRefresh(refreshControl:)),
                                 for: UIControlEvents.valueChanged)
        return refreshControl
    }()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.viewModel.refreshUIDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Payment codes"
        self.tableView?.isAccessibilityElement = true
        self.tableView?.accessibilityIdentifier = "tokensTable"
        self.tableView?.addSubview(self.tableRefreshControl)
        self.lastSyncLabel.text = viewModel.lastUpdate()
        self.viewModel.refreshData()
        self.updateVisibility()
        self.applyStyle()
    }

    func applyStyle() {
        StyleManager.greenButton(button: self.newTokenButton)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reachabilityObserver.startObserveReachability()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.reachabilityObserver.stopObserveReachability()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func handleRefresh(refreshControl: UIRefreshControl) {
        self.viewModel.refreshData()
    }

    internal func updateVisibility() {
        self.tableView?.isHidden = self.viewModel.count() == 0
        self.noDataTextView?.isHidden = self.viewModel.count() > 0
    }

    @IBAction func didTapRefresh(_ sender: Any) {
        self.viewModel.refreshData()
    }

    @IBAction func didTapNewToken(_ sender: Any) {
        switchTabDelegate?.switchToRoute(route: .newToken)
    }

    func reachabilityDidChange(isReachable: Bool) {
        self.refreshButton.isEnabled = isReachable
    }
}

extension TokensViewController: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.count()
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokensTableViewCell")
        cell?.isAccessibilityElement = true
        cell?.accessibilityIdentifier = "Cell_\(indexPath.section)_\(indexPath.row)"

        if let tokenCell = cell as? TokensTableViewCell,
            let bodyObject = self.viewModel.item(for: indexPath.row) {
            tokenCell.overrideMessageDelegate = self
            tokenCell.setupUI(bodyObject: bodyObject)
            return tokenCell
        }

        return UITableViewCell()
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.updateNotificationVisibility(indexPath: indexPath)
        self.viewModel.updateOverriddenVisibility(indexPath: indexPath)
        self.tableView?.deselectRow(at: indexPath, animated: true)
        if let bodyObject = self.viewModel.bodyObject(at: indexPath) {
            self.tokenDetailsDelegate?.showTokenDetails(model: bodyObject)
        }
    }
}

extension TokensViewController: RefreshTableDelegate {
    func refreshTable() {
        guard self.isViewLoaded else {
            return
        }

        DispatchQueue.main.async {
            self.tableView?.reloadData()
            self.updateVisibility()
            self.lastSyncLabel.text = self.viewModel.lastUpdate()
            self.tableRefreshControl.endRefreshing()
        }
    }
}

extension TokensViewController: OverrideTokenMessageDelegate {

    func showOverriddenMessage() {
        let annoucement = Announcement(title: viewModel.whisperMessageTitle(), subtitle: viewModel.whisperMessageBody(), duration: 3)

        ColorList.Shout.background = .dvsaOrange
        ColorList.Shout.title = UIColor.white
        ColorList.Shout.subtitle = UIColor.white
        ColorList.Shout.dragIndicator = UIColor.white
        Whisper.show(shout: annoucement, to: self)
    }

}
