//
//  Utilities.swift
//  Skiptracer
//
//  Created by Colin Caufield on 5/24/15.
//  Copyright (c) 2015 Secret Geometry, Inc. All rights reserved.
//

import Foundation

func removeNils<T>(array: [T?]) -> [T] {
    
    var newArray = [T]()
    for item in array {
        if item != nil {
            newArray.append(item!)
        }
    }
    return newArray
}

func safeCompare<T>(a: T?, b: T?, fn: (T, T) -> T) -> T? {
    
    let items = removeNils([a, b])
    switch items.count {
        case 1: return items[0]
        case 2: return fn(a!, b!)
        default: return items.first // can be nil
    }
}

func safeMin<T: Comparable>(a: T?, b: T?) -> T? {
    return safeCompare(a, b: b, fn: min)
}

func safeMax<T: Comparable>(a: T?, b: T?) -> T? {
    return safeCompare(a, b: b, fn: max)
}

func safeEarliestDate(dates: [NSDate?]) -> NSDate? {
    
    var earliest: NSDate?
    for date in removeNils(dates) {
        if earliest == nil {
            earliest = date
        } else {
            earliest = earliest!.earlierDate(date)
        }
    }
    return earliest
}

#if os(iOS)
    
    import CoreGraphics
    import UIKit

    func getRGBAForColor(color: UIColor) -> [CGFloat] {
        var rgba: [CGFloat] = [ 0, 0, 0, 0 ]
        color.getRed(&rgba[0], green: &rgba[1], blue: &rgba[2], alpha: &rgba[3])
        return rgba
    }

    func getColorForRGBA(rgba: [CGFloat]) -> UIColor {
        let a = (rgba.count < 3) ? 1.0 : rgba[3]
        return UIColor(red: rgba[0], green: rgba[1], blue: rgba[2], alpha: a)
    }

#endif
