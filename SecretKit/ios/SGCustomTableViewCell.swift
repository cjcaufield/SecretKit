//
//  CustomTableViewCell.swift
//  SecretKit
//
//  Created by Colin Caufield on 4/4/15.
//  Copyright (c) 2015 Secret Geometry, Inc. All rights reserved.
//

import UIKit

open class SGCustomTableViewCell: UITableViewCell {

    open override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.preservesSuperviewLayoutMargins = true
    }
}
