//
//  UIColor+Extensions.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Andrea Scuderi on 10/01/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import Foundation

public extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: NSCharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let alpha, red, green, blue: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (1, 1, 1, 0)
        }
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: CGFloat(alpha) / 255)
    }

    @objc static var dvsaGreen: UIColor {
        return UIColor(hexString: "1F8374")
    }

    @objc static var dvsaBlu: UIColor {
        return UIColor(hexString: "0161A1")
    }

    @objc static var dvsaLightGray: UIColor {
        return UIColor(hexString: "f3f3f3")
    }

    @objc static var dvsaOCRNormal: UIColor {
        return UIColor(hexString: "f8f8f8")
    }

    @objc static var dvsaOrange: UIColor {
        return UIColor(hexString: "#f47738")
    }

    @objc static var dvsaOCRSelected: UIColor {
        return UIColor(hexString: "#c5d8d5")
    }

    @objc static var dvsaRed: UIColor {
        return UIColor(hexString: "#df3034")
    }

    @objc static var dvsaPinkBackground: UIColor {
        return UIColor(red: 223.0/255.0,
                       green: 48.0/255.0,
                       blue: 52.0/255.0,
                       alpha: 0.3)
    }

    @objc static var dvsaOrangeBackground: UIColor {
        return UIColor(red: 244.0/255.0,
                       green: 119.0/255.0,
                       blue: 56.0/255.0,
                       alpha: 0.2)
    }
}
