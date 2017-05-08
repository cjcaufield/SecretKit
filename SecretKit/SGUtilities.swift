//
//  Utilities.swift
//  SecretKit
//
//  Created by Colin Caufield on 5/24/15.
//  Copyright (c) 2015 Secret Geometry, Inc. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    public mutating func remove(object: Element) {
        
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
}

public func removeNils<T>(_ array: [T?]) -> [T] {
    
    var newArray = [T]()
    for item in array {
        if item != nil {
            newArray.append(item!)
        }
    }
    return newArray
}

public func safeCompare<T>(_ a: T?, b: T?, fn: (T, T) -> T) -> T? {
    
    let items = removeNils([a, b])
    switch items.count {
        case 1: return items[0]
        case 2: return fn(a!, b!)
        default: return items.first // can be nil
    }
}

public func safeMin<T: Comparable>(_ a: T?, b: T?) -> T? {
    return safeCompare(a, b: b, fn: min)
}

public func safeMax<T: Comparable>(_ a: T?, b: T?) -> T? {
    return safeCompare(a, b: b, fn: max)
}

public func safeEarliestDate(_ dates: [Date?]) -> Date? {
    
    var earliest: Date?
    for date in removeNils(dates) {
        if earliest == nil {
            earliest = date
        } else {
            earliest = (earliest! as NSDate).earlierDate(date)
        }
    }
    return earliest
}

#if os(iOS)
    
    import CoreGraphics
    import UIKit

    public func getRGBA(forColor color: UIColor) -> [CGFloat] {
        var rgba: [CGFloat] = [ 0, 0, 0, 0 ]
        color.getRed(&rgba[0], green: &rgba[1], blue: &rgba[2], alpha: &rgba[3])
        return rgba
    }

    public func getColor(forRGBA rgba: [CGFloat]) -> UIColor {
        let a = (rgba.count < 3) ? 1.0 : rgba[3]
        return UIColor(red: rgba[0], green: rgba[1], blue: rgba[2], alpha: a)
    }

#endif
