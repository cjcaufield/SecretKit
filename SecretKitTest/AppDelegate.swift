//
//  AppDelegate.swift
//  SecretKitTest
//
//  Created by Colin Caufield on 2016-02-17.
//  Copyright © 2016 Secret Geometry, Inc. All rights reserved.
//

import Cocoa
import SecretKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(note: NSNotification) {
        
        let nums: [Int?] = [0, nil, 1, nil, 2, nil, 3]
        print(nums)
        
        let just = removeNils(nums)
        print(just)
    }
}


