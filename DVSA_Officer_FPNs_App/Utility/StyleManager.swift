//
//  StyleManager.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 11/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation
import UIKit
import Compass
import SVProgressHUD

class StyleManager {
    static func applyStyle() {
        UITabBar.appearance().tintColor = UIColor.white
        UITabBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().backgroundColor = UIColor.black
        UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        UIBarButtonItem.appearance().tintColor = .white

        SVProgressHUD.setForegroundColor(.dvsaGreen)
        SVProgressHUD.setDefaultMaskType(.black)
        if let errorImage = UIImage(named: "error") {
            SVProgressHUD.setErrorImage(errorImage)
        }
        if let doneImage = UIImage(named: "done") {
            SVProgressHUD.setSuccessImage(doneImage)
        }
    }

    static func iconNewToken() -> UIImage {
        return UIImage(named: "iconNewToken") ?? UIImage()
    }

    static func iconTokens() -> UIImage {
        return UIImage(named: "iconTokens") ?? UIImage()
    }

    static func iconSettings() -> UIImage {
        return UIImage(named: "iconSettings") ?? UIImage()
    }

    static func iconNotifications() -> UIImage {
        return UIImage(named: "iconNotifications") ?? UIImage()
    }

    static func greenButton(button: DesignableButton) {
        button.cornerRadius = 8.0
        button.disabledTextColor = UIColor.darkGray
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.backgroundColor = UIColor.dvsaGreen
        button.disabledBackgroundColor = UIColor.dvsaLightGray
    }

    static func grayButton(button: DesignableButton) {
        button.cornerRadius = 8.0
        button.disabledTextColor = UIColor.darkGray
        button.setTitleColor(UIColor.dvsaGreen, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.backgroundColor = UIColor.white
        button.normalBackgroundColor = UIColor.white
        button.borderWidth = 1
        button.borderColor = UIColor.dvsaGreen
        button.disabledBackgroundColor = UIColor.dvsaLightGray
    }

    static func roundedBorder(views: [DesignableView]) {
        for view in views {
            roundedBorder(view: view)
        }
    }

    internal static let defaultWidth: CGFloat = 1.5
    internal static let defaultCornerRadius: CGFloat = 8.0
    internal static let defaultBorderColor = UIColor.black

    static func roundedBorder(view: DesignableView) {
        view.borderWidth = defaultWidth
        view.borderColor = defaultBorderColor
        view.cornerRadius = defaultCornerRadius
    }

    static func segmented(segmented: UISegmentedControl) {
        segmented.tintColor = UIColor.black
        segmented.layer.borderWidth = defaultWidth
        segmented.layer.cornerRadius = defaultCornerRadius
        segmented.layer.masksToBounds = true
    }

    static func icon(route: Route) -> UIImage {

        switch route {
        case .tokenList:
            return StyleManager.iconTokens()
        case .newToken:
            return StyleManager.iconNewToken()
        case .settings:
            return StyleManager.iconSettings()
        default:
            return UIImage()
        }
    }
}
