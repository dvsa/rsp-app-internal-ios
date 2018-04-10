//
//  SettingsBundleManager.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 26/02/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

class SettingsBundleManager {
    struct SettingsBundleKey {
        static let build = "dvsa_build_preference"
        static let version = "dvsa_version_preference"
    }

    class func setVersionAndBuildNumber() {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as? String ?? "--"
        let build = dictionary["CFBundleVersion"] as? String ?? "--"
        UserDefaults.standard.set(version, forKey: SettingsBundleKey.version)
        UserDefaults.standard.set(build, forKey: SettingsBundleKey.build)
        UserDefaults.standard.synchronize()
    }

    class func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as? String ?? "--"
        let build = dictionary["CFBundleVersion"] as? String ?? "--"
        return "version \(version) (build \(build))"
    }
}
