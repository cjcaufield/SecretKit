//
//  SGViewController.swift
//  Skiptracer
//
//  Created by Colin Caufield on 4/4/15.
//  Copyright (c) 2015 Secret Geometry, Inc. All rights reserved.
//

import UIKit

public class SGViewController: UIViewController {

    public var timer: NSTimer?
    public var timerInterval = 1.0
    public var shouldUseTimer = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.addObservers()
    }
    
    public override func viewWillAppear(animated: Bool) {
        if self.shouldUseTimer {
            self.createTimer()
        }
    }
    
    public override func viewDidDisappear(animated: Bool) {
        if self.shouldUseTimer {
            self.destroyTimer()
        }
    }
    
    public func addObservers() {
        // nothing
    }
    
    public func removeObservers() {
        // nothing
    }
    
    public func createTimer() {
        self.timer = NSTimer.scheduledTimerWithTimeInterval(self.timerInterval, target: self, selector: "timerUpdate", userInfo: nil, repeats: true)
    }
    
    public func destroyTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    public func timerUpdate() {
        // nothing
    }
}
