//
//  TokensListViewModel.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 06/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit
import RealmSwift

class TokensListViewModel: BodyObjectListViewModel {

    internal var synchmanager: SynchronizationDelegate = SynchronizationManager.shared
    internal var notificationToken: NotificationToken?
    internal var siteChangeNotificationToken: NotificationToken?
    internal weak var refreshUIDelegate: RefreshTableDelegate?
    internal var siteFilterPredicate: NSPredicate?
    internal var preferences: PreferencesDataSourceProtocol = PreferencesDataSource.shared

    override init(datasource: ObjectsDataSource) {

        let siteCode = preferences.site()?.code
        super.init(datasource: datasource, filterOptions: {$0.value?.siteCode == siteCode })

        notificationToken = datasource.observe { [weak self] (items) in
            self?.model.items = items
            if let siteCode = self?.preferences.site()?.code {
                self?.model.items = self?.model.items?.filter { $0.value?.siteCode == siteCode }
            }

            self?.refreshUIDelegate?.refreshTable()
        }
        siteChangeNotificationToken = preferences.observePreferenceChange(completion: { (userPreference) in

            guard let userPreference = userPreference else {
                return
            }
            let code = userPreference.isMobile ? userPreference.mobileLocation?.code : userPreference.siteLocation?.code
            self.model.items = self.datasource.list()?.filter { $0.value?.siteCode == code }
            self.refreshUIDelegate?.refreshTable()
        })
    }

    func lastUpdate() -> String {
        let date = synchmanager.lastUpdate
        return "Last sync: \(date?.dvsaLastSyncDateTimeString ?? "")"
    }

    deinit {
        notificationToken?.invalidate()
        siteChangeNotificationToken?.invalidate()
    }

    internal func refreshData() {
        try? synchmanager.synchronize { _ in
            self.refreshUIDelegate?.refreshTable()
        }
    }

    func bodyObject(at indexPath: IndexPath) -> BodyObject? {
        return self.model.item(at: indexPath.row)
    }

    internal func updateNotificationVisibility(indexPath: IndexPath) {
        if let bodyObject = self.model.item(at: indexPath.row) {
            try? datasource.hideNotification(for: bodyObject.key)
        }
    }

    internal func updateOverriddenVisibility(indexPath: IndexPath) {
        if let bodyObject = self.model.item(at: indexPath.row) {
            try? datasource.hideOverridden(for: bodyObject.key)
        }
    }

    internal func whisperMessageTitle() -> String {
        return "Overridden by previously created payment code"
    }

    internal func whisperMessageBody() -> String {
        return "Payment code details have been changed following an update from the server."
    }
}
