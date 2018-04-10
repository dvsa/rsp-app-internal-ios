//
//  UIStoryboard+Extensions.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 04/05/2016.
//  Copyright © 2016 Andrea Scuderi. All rights reserved.
//

import UIKit

protocol StoryboardInstantiable: class {
    static var storyboardIdentifier: String {get}
    static func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> Self
}

extension UIViewController: StoryboardInstantiable {
    static var storyboardIdentifier: String {
        // Get the name of current class
        let classString = NSStringFromClass(self)
        let components = classString.components(separatedBy: ".")
        assert(components.count > 0, "Failed extract class name from \(classString)")
        return components.last!
    }

    class func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> Self {
        return instantiateFromStoryboard(storyboard, type: self)
    }
}

extension UIViewController {

    // Thanks to generics, return automatically the right type
    fileprivate class func instantiateFromStoryboard<T: UIViewController>(_ storyboard: UIStoryboard, type: T.Type) -> T! {
        return storyboard.instantiateViewController(withIdentifier: self.storyboardIdentifier) as? T
    }
}

extension UIStoryboard {

    class func mainStoryboard() -> UIStoryboard! {

        guard let mainStoryboardName = Bundle.main.infoDictionary?["UIMainStoryboardFile"] as? String else {
            assertionFailure("No UIMainStoryboardFile found in main bundle")
            return nil
        }

        return UIStoryboard(name: mainStoryboardName, bundle: Bundle.main)
    }
}
