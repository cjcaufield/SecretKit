//
//  SGViewController.swift
//  SecretKit
//
//  Created by Colin Caufield on 4/4/15.
//  Copyright (c) 2015 Secret Geometry, Inc. All rights reserved.
//

import UIKit

open class SGViewController: UIViewController {

    open var timer: Timer?
    open var timerInterval = 1.0
    open var shouldUseTimer = false
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.addObservers()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        if self.shouldUseTimer {
            self.createTimer()
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        if self.shouldUseTimer {
            self.destroyTimer()
        }
    }
    
    open func addObservers() {
        // nothing
    }
    
    open func removeObservers() {
        // nothing
    }
    
    open func createTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: self.timerInterval, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
    }
    
    open func destroyTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    open func timerUpdate() {
        // nothing
    }
}
