//
//  IndexPathExtensions.swift
//  SecretKit
//
//  Created by Colin Caufield on 4/10/15.
//  Copyright (c) 2015 Secret Geometry, Inc. All rights reserved.
//

import UIKit

public extension IndexPath {
    
    public func previous() -> IndexPath {
        assert(self.row > 0)
        return IndexPath(row: self.row - 1, section: self.section)
    }
    
    public func next() -> IndexPath {
        return IndexPath(row: self.row + 1, section: self.section)
    }
}
