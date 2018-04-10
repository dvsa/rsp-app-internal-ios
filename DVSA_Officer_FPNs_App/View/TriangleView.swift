//
//  TriangleView.swift
//  DVSA_Officer_FPNs_App
//
//  Created by Yue Chen on 19/03/2018.
//  Copyright © 2018 Driver & Vehicle Standards Agency. All rights reserved.
//  Copyright © 2018 BJSS. All rights reserved.
//

import UIKit

class TriangleView: UIView {

    var fillColor: CGColor?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {

        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY))
        context.closePath()

        if let color = fillColor {
            context.setFillColor(color)
        }
        context.fillPath()
    }
}
