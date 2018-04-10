//
//  SetLocationFlowController.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 24/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import RealmSwift
import Compass

protocol SetLocationDelegate: class {
    func didConfirmLocation(site: SiteObject?, mobileAddress: String?)
    func didTapChangeLocation()
}

class SetLocationFlowController: FlowController {

    internal let configure: FlowConfigurable
    internal var preferences: PreferencesDataSourceProtocol
    internal var setLocationVC: SetLocationViewController?
    internal var siteLocationVC: SiteListTableViewController?
    internal var mobileLocationVC: ListTableViewController<SiteObjectList>?

    internal var datasource: ObjectsDataSource
    internal var notificationToken: NotificationToken?
    internal var navigationController = UINavigationController()
    internal var storyboard: UIStoryboard! = UIStoryboard.mainStoryboard()
    internal var synchManager: SynchronizationDelegate = SynchronizationManager.shared

    required init(configure: FlowConfigurable) {
        self.configure = configure
        self.preferences = PreferencesDataSource.shared
        self.datasource = PersistentDataSource()
    }

    deinit {
        notificationToken?.invalidate()
    }

    func start() {

        notificationToken = datasource.observeSites { [weak self] (items) in
            if let viewModel = self?.siteLocationVC?.viewModel as? SiteObjectListViewModel {
                let items = items ?? [SiteObject]()
                viewModel.update(items: items)
            }
        }

        if let sites = self.datasource.sites(), sites.count != 0 {
            log.info("Site list is present")
        } else {
            log.info("Site list loaded from local reource")
            self.datasource.updateSite(from: "AWSSites")
        }

        createSetLocationViewController()
        createSelectSiteLocation()
        navigationController.setViewControllers([setLocationVC!], animated: false)

        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)

        navigationController.topViewController?.navigationItem.backBarButtonItem = backButton

        guard let tabBarController = self.configure.navigationController?.viewControllers.first else {
            return
        }

        tabBarController.present(navigationController, animated: true) {

        }
    }

    private func createSetLocationViewController() {

        setLocationVC = SetLocationViewController.instantiateFromStoryboard(storyboard)
        setLocationVC?.viewModel = UserPreferencesViewModel(datasource: preferences)
        setLocationVC?.setLocationDelegate = self

    }

    func createSelectSiteLocation() {
        siteLocationVC = SiteListTableViewController.instantiateFromStoryboard(storyboard!)
    }

    lazy var navigationHandler: ((Location) -> Void)? = { (location) in

    }
}

extension SetLocationFlowController: SetLocationDelegate {
    func didConfirmLocation(site: SiteObject?, mobileAddress: String?) {

        if let site = site {

            if site.code > 0 {
                _ = preferences.updateSite(site: site)
            }
            if site.code < 0,
                let mobileAddress = mobileAddress {
                _ = preferences.updateMobileSite(site: site, mobileAddress: mobileAddress)
            }
        } else {
            log.error("ERROR: Site is nil")
        }
        setLocationVC?.dismiss(animated: true) {

        }
    }

    func didTapChangeLocation() {

        let isMobile = setLocationVC?.viewModel?.isMobile ?? false
        let viewModel = SiteObjectListViewModel(datasource: datasource, isMobile: isMobile)

        if !isMobile {
            guard let siteLocationVC = siteLocationVC else {
                return
            }
            let configureTable = ConfigureOrderedTable(styleTable: UITableViewStyle.plain,
                                                       title: "Select fixed site",
                                                       delegate: self,
                                                       collationStringSelector: #selector(getter: SiteObject.name),
                                                       cellStyle: UITableViewCellStyle.default,
                                                       reuseIdentifier: "SiteListTableViewCell")

            siteLocationVC.setup(viewModel: viewModel, configure: configureTable) { item, cell in

                guard !item.isInvalidated else {
                    return
                }

                cell.textLabel?.text = item.name
            }
            navigationController.pushViewController(siteLocationVC, animated: true)
        } else {

            let configureTable = ConfigureTable(styleTable: .plain,
                                                title: "Select enforcement area",
                                                delegate: self,
                                                cellStyle: .default,
                                                reuseIdentifier: "MobileSiteListTableViewCell")
            mobileLocationVC = ListTableViewController<SiteObjectList>(viewModel: viewModel, configure: configureTable) { item, cell in
                cell.textLabel?.text = item.name
                cell.textLabel?.isAccessibilityElement = true
                cell.textLabel?.accessibilityIdentifier = "name"
            }

            guard let mobileLocationVC = mobileLocationVC else {
                return
            }
            navigationController.pushViewController(mobileLocationVC, animated: true)
        }
    }
}

extension SetLocationFlowController: ListTableViewControllerDelegate {

    func refreshData(completion: @escaping (Bool) -> Void) {
        synchManager.sites(completion: completion)
    }

    func didSelect(key: Int) {
        navigationController.popViewController(animated: true)
        let selectedSite = preferences.getSite(code: key)
        if let code = selectedSite?.code {
            if code > 0 {
                setLocationVC?.viewModel?.temporarySiteLocation = selectedSite
            }
            if code < 0 {
                setLocationVC?.viewModel?.temporaryMobileLocation = selectedSite
            }
        } else {
            setLocationVC?.viewModel?.temporarySiteLocation = selectedSite
            setLocationVC?.viewModel?.temporaryMobileLocation = selectedSite
        }
        setLocationVC?.updateUI()
    }
}
