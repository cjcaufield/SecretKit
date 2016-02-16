//
//  SGInvocation.swift
//  TermKit
//
//  Created by Colin Caufield on 2016-02-03.
//  Copyright © 2016 Secret Geometry. All rights reserved.
//

import Foundation

class SGInvocation<Signature> {
    
    var target: AnyObject?
    var selector: Selector?
    var arguments = [AnyObject?]()
    var contextInfo: UnsafeMutablePointer<Void> = nil
    
    init() {
        // nothing
    }
    
    init(target: AnyObject, selector: Selector, arguments: [AnyObject?] = [], contextInfo: UnsafeMutablePointer<Void> = nil) {
        
        self.target = target
        self.selector = selector
        self.contextInfo = contextInfo
    }
    
    var argumentCount: Int {
        return 0 // implement
    }
    
    func invoke() {
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