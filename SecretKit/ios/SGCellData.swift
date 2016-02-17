//
//  SGRowData.swift
//  TermKit
//
//  Created by Colin Caufield on 2016-01-13.
//  Copyright © 2016 Secret Geometry. All rights reserved.
//

import Foundation

public let BASIC_CELL_ID        = "BasicCell"
let LABEL_CELL_ID        = "LabelCell"
let TEXT_FIELD_CELL_ID   = "TextFieldCell"
let SWITCH_CELL_ID       = "SwitchCell"
let SLIDER_CELL_ID       = "SliderCell"
let TIME_LABEL_CELL_ID   = "TimeLabelCell"
let TIME_PICKER_CELL_ID  = "TimePickerCell"
let PICKER_LABEL_CELL_ID = "PickerLabelCell"
let PICKER_CELL_ID       = "PickerCell"
let DATE_LABEL_CELL_ID   = "DateLabelCell"
let DATE_PICKER_CELL_ID  = "DatePickerCell"
let SEGMENTED_CELL_ID    = "SegmentedCell"
let TEXT_VIEW_CELL_ID    = "TextViewCell"
let COLOR_CELL_ID        = "ColorCell"
let OTHER_CELL_ID        = "OtherCell"

enum SGRowDataTargetType {
    case ViewController
    case Object
}

class SGRowData: Equatable {
    
    var cellIdentifier: String
    var title: String
    var modelPath: String?
    var targetType: SGRowDataTargetType
    var action: Selector?
    var segueName: String?
    var checked: Bool?
    var range: NSRange
    var expandable = false
    var hidden = false
    
    init(cellIdentifier: String = OTHER_CELL_ID,
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

func ==(a: SGRowData, b: SGRowData) -> Bool {
    return ObjectIdentifier(a) == ObjectIdentifier(b)
}

class SGSliderRowData : SGRowData {
    
    /*
    init(title: String = "",
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

class SGSectionData {
    
    var rows = [SGRowData]()
    var title = ""
    
    init(_ rows: SGRowData..., title: String = "") {
        self.rows = rows
    }
}

class SGTableData {
    
    var sections = [SGSectionData]()
    
    init() {
        // nothing
    }
    
    init(_ sections: SGSectionData...) {
        self.sections = sections
    }
}
