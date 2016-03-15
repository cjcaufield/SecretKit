//
//  SGColorPickerView.swift
//  SecretKit
//
//  Created by Colin Caufield on 2016-01-14.
//  Copyright © 2016 Secret Geometry. All rights reserved.
//

import UIKit

public class SGColorPicker: UIControl {
    
    public var selectedColor = UIColor.whiteColor()
    public var selectedRow: Int?
    public var selectedCol: Int?
    public var rowCount = 32
    public var colCount = 8
    public var image: UIImage?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initCommon()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initCommon()
    }
    
    public func initCommon() {
        
        self.opaque = false
        
        let path = NSBundle.mainBundle().pathForResource("HSV", ofType: "png")
        self.image = UIImage(contentsOfFile: path!)
    }
    
    public override func drawRect(rect: CGRect) {
        
        self.image?.drawInRect(rect)
        
        /*
        let context = UIGraphicsGetCurrentContext()
        
        let cellWidth = rect.size.width / CGFloat(colCount)
        let cellHeight = rect.size.height / CGFloat(rowCount)
        
        let strokeColor = UIColor.redColor()
        
        for i in 0 ..< colCount {
            for j in 0 ..< rowCount {
                
                let cellRect = CGRect(
                    x: CGFloat(i) * cellWidth,
                    y: CGFloat(j) * cellHeight,
                    width: cellWidth,
                    height: cellHeight)
                
                let xf = CGFloat(i) / CGFloat(colCount)
                let yf = CGFloat(j) / CGFloat(rowCount)
                
                let fillColor = UIColor(red: xf, green: 1.0, blue: yf, alpha: 1.0)
                
                CGContextSetFillColorWithColor(context, fillColor.CGColor)
                CGContextFillRect(context, cellRect)
                
                CGContextSetStrokeColorWithColor(context, strokeColor.CGColor)
                CGContextSetLineWidth(context, 1.0)
                CGContextStrokeRect(context, cellRect)
            }
        }
        */
        
        // OLD
        /*
        let inner = rect.insetBy(dx: 1.0, dy: 1.0)
        
        var fill: [CGFloat] = [ 0, 0, 0, 0 ]
        color.getRed(&fill[0], green: &fill[1], blue: &fill[2], alpha: &fill[3])
        
        let light = fill[0] > 0.9 && fill[1] > 0.9 && fill[2] > 0.9
        
        var stroke = fill
        if light {
            stroke = [ 0.5, 0.5, 0.5, 1.0 ]
        }
        
        
        CGContextAddEllipseInRect(context, inner)
        CGContextSetStrokeColor(context, stroke)
        CGContextSetFillColor(context, fill)
        CGContextSetLineWidth(context, 1.0)
        CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
        */
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.handleTouches(touches)
    }
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.handleTouches(touches)
    }
    
    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        // nothing
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // nothing
    }
    
    public func handleTouches(touches: Set<UITouch>) {
        if let touch = touches.first {
            let point = touch.locationInView(self)
            self.selectedColor = self.getPixelColorAtPoint(point)
            self.sendActionsForControlEvents(.ValueChanged)
        }
    }
    
    public func getPixelColorAtPoint(point: CGPoint) -> UIColor{
        
        let pixel = UnsafeMutablePointer<CUnsignedChar>.alloc(4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, bitmapInfo.rawValue)
        
        CGContextTranslateCTM(context, -point.x, -point.y)
        self.layer.renderInContext(context!)
        
        let r = CGFloat(pixel[0]) / 255.0
        let g = CGFloat(pixel[1]) / 255.0
        let b = CGFloat(pixel[2]) / 255.0
        let a = CGFloat(pixel[3]) / 255.0
        
        let color = UIColor(red: r, green: g, blue: b, alpha: a);
        
        pixel.dealloc(4)
        return color
    }
}
