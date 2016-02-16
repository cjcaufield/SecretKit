//
//  SGColorView.swift
//  SecretKit
//
//  Created by Colin Caufield on 2016-01-14.
//  Copyright © 2016 Secret Geometry. All rights reserved.
//

import UIKit

class SGColorView: UIView {
    
    var color = UIColor.blackColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initCommon()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initCommon()
    }
    
    func initCommon() {
        self.opaque = false
    }
    
    override func drawRect(rect: CGRect) {
        
        let inner = rect.insetBy(dx: 1.0, dy: 1.0)
        
        var fill = getRGBAForColor(self.color)
        let light = fill[0] > 0.9 && fill[1] > 0.9 && fill[2] > 0.9
        
        var stroke = fill
        if light {
            stroke = [ 0.8, 0.8, 0.8, 1.0 ]
        }
        
        let context = UIGraphicsGetCurrentContext()
        CGContextAddEllipseInRect(context, inner)
        CGContextSetStrokeColor(context, stroke)
        CGContextSetFillColor(context, fill)
        CGContextSetLineWidth(context, 1.5)
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
    }
}
