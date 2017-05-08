//
//  SGColorPickerView.swift
//  SecretKit
//
//  Created by Colin Caufield on 2016-01-14.
//  Copyright © 2016 Secret Geometry. All rights reserved.
//

import UIKit

public class SGColorPicker: UIControl {
    
    public var selectedColor = UIColor.white
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
        
        self.isOpaque = false
        
        let path = Bundle.main.path(forResource: "HSV", ofType: "png")
        self.image = UIImage(contentsOfFile: path!)
    }
    
    public override func draw(_ rect: CGRect) {
        
        self.image?.draw(in: rect)
        
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
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.handleTouches(touches)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.handleTouches(touches)
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        // nothing
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // nothing
    }
    
    public func handleTouches(_ touches: Set<UITouch>) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            self.selectedColor = self.getPixelColorAtPoint(point)
            self.sendActions(for: .valueChanged)
        }
    }
    
    public func getPixelColorAtPoint(_ point: CGPoint) -> UIColor{
        
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        self.layer.render(in: context!)
        
        let r = CGFloat(pixel[0]) / 255.0
        let g = CGFloat(pixel[1]) / 255.0
        let b = CGFloat(pixel[2]) / 255.0
        let a = CGFloat(pixel[3]) / 255.0
        
        let color = UIColor(red: r, green: g, blue: b, alpha: a);
        
        pixel.deallocate(capacity: 4)
        return color
    }
}
