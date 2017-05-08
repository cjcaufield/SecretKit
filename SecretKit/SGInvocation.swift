//
//  SGInvocation.swift
//  TermKit
//
//  Created by Colin Caufield on 2016-02-03.
//  Copyright © 2016 Secret Geometry. All rights reserved.
//

import Foundation

open class SGInvocation<Signature> {
    
    open var target: AnyObject?
    open var selector: Selector?
    open var arguments = [AnyObject?]()
    open var contextInfo: UnsafeMutableRawPointer? = nil
    
    public init() {
        // nothing
    }
    
    public init(target: AnyObject,
                selector: Selector,
                arguments: [AnyObject?] = [],
                contextInfo: UnsafeMutableRawPointer? = nil) {
        
        self.target = target
        self.selector = selector
        self.contextInfo = contextInfo
    }
    
    open var argumentCount: Int {
        return 0 // implement
    }
    
    open func invoke() {
        /*
        if let target = self.target, selector = self.selector {
        
            let Class: AnyClass = object_getClass(self.target!)
            let method = class_getMethodImplementation(Class, self.selector!)
            let function = unsafeBitCast(method, Signature.self)
            
            switch self.argumentCount {
            case 0:
                function(target, selector)
            case 1:
                function(target, selector, self.arguments[0])
            case 2:
                function(target, selector, self.arguments[0], self.arguments[1])
            case 3:
                function(target, selector, self.arguments[0], self.arguments[1], self.arguments[2])
            case 4:
                function(target, selector, self.arguments[0], self.arguments[1], self.arguments[2], self.arguments[3])
            default:
                assert(false)
            }
        }
        */
    }
}
