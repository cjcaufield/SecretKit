//
//  SGRowData.swift
//  TermKit
//
//  Created by Colin Caufield on 2016-01-13.
//  Copyright © 2016 Secret Geometry. All rights reserved.
//

import Foundation

public let BASIC_CELL_ID        = "BasicCell"
public let LABEL_CELL_ID        = "LabelCell"
public let TEXT_FIELD_CELL_ID   = "TextFieldCell"
public let SWITCH_CELL_ID       = "SwitchCell"
public let SLIDER_CELL_ID       = "SliderCell"
public let TIME_LABEL_CELL_ID   = "TimeLabelCell"
public let TIME_PICKER_CELL_ID  = "TimePickerCell"
public let PICKER_LABEL_CELL_ID = "PickerLabelCell"
public let PICKER_CELL_ID       = "PickerCell"
public let DATE_LABEL_CELL_ID   = "DateLabelCell"
public let DATE_PICKER_CELL_ID  = "DatePickerCell"
public let SEGMENTED_CELL_ID    = "SegmentedCell"
public let TEXT_VIEW_CELL_ID    = "TextViewCell"
public let COLOR_CELL_ID        = "ColorCell"
public let OTHER_CELL_ID        = "OtherCell"

public enum SGRowDataTargetType {
    case ViewController
    case Object
}

public class SGRowData: Equatable {
    
    public var cellIdentifier: String
    public var title: String
    public var modelPath: String?
    public var targetType: SGRowDataTargetType
    public var action: Selector?
    public var segueName: String?
    public var checked: Bool?
    public var range: NSRange
    public var expandable = false
    public var hidden = false
    
    public init(cellIdentifier: String = OTHER_CELL_ID,
                title: String = "",
                modelPath: String? = nil,
                targetType: SGRowDataTargetType = .Object,
                action: Selector? = nil,
                segueName: String? = nil,
                checked: Bool? = nil,
                range: NSRange = NSMakeRange(0, 1),
                expandable: Bool = false,
                hidden: Bool = false) {
            
        self.cellIdentifier = cellIdentifier
        self.title = title
        self.modelPath = modelPath
        self.targetType = targetType
        self.action = action
        self.segueName = segueName
        self.checked = checked
        self.range = range
        self.expandable = expandable
        self.hidden = hidden
    }
}

public func ==(a: SGRowData, b: SGRowData) -> Bool {
    return ObjectIdentifier(a) == ObjectIdentifier(b)
}

public class SGSliderRowData : SGRowData {
    
    /*
    public init(title: String = "",
                targetType: SGRowDataTargetType = .Object,
                modelPath: String? = nil,
                range: NSRange = NSMakeRange(0, 1)) {
        
        super.init(cellIdentifier: SLIDER_CELL_ID,
                   title: title,
                   targetType: targetType,
                   modelPath: modelPath)
        
        self.range = range
    }
    */
}

public class SGSectionData {
    
    public var rows = [SGRowData]()
    public var title = ""
    
    public init(_ rows: SGRowData..., title: String = "") {
        self.rows = rows
    }
}

public class SGTableData {
    
    public var sections = [SGSectionData]()
    
    public init() {
        // nothing
    }
    
    public init(_ sections: SGSectionData...) {
        self.sections = sections
    }
}
