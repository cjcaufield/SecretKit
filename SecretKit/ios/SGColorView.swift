//
//  SGColorView.swift
//  SecretKit
//
//  Created by Colin Caufield on 2016-01-14.
//  Copyright © 2016 Secret Geometry. All rights reserved.
//

import UIKit

public class SGColorView: UIView {
    
    public var color = UIColor.black {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initCommon()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initCommon()
    }
    
    public func initCommon() {
        self.isOpaque = false
    }
    
    public override func draw(_ rect: CGRect) {
        
        let inner = rect.insetBy(dx: 1.0, dy: 1.0)
        
        var fill = getRGBA(forColor: self.color)
        let light = fill[0] > 0.9 && fill[1] > 0.9 && fill[2] > 0.9
        
        var stroke = fill
        if light {
            stroke = [ 0.8, 0.8, 0.8, 1.0 ]
        }
        
        let context = UIGraphicsGetCurrentContext()
        context!.addEllipse(in: inner)
        context!.setStrokeColor(stroke)
        context!.setFillColor(fill)
        context!.setLineWidth(1.5)
        context!.drawPath(using: CGPathDrawingMode.fillStroke)
    }
}
