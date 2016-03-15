//
//  SGDynamicTableViewController.swift
//  Skiptracer
//
//  Created by Colin Caufield on 4/17/15.
//  Copyright (c) 2015 Secret Geometry, Inc. All rights reserved.
//

import UIKit

public class SGDynamicTableViewController: UITableViewController,
                                           UITextFieldDelegate,
                                           UITextViewDelegate,
                                           UIPickerViewDelegate,
                                           UIPickerViewDataSource {
    
    // MARK: Properties
    
    public var tableData = SGTableData()
    public var revealedCellIndexPath: NSIndexPath?
    public var hasRegisteredObservers = false
    public var showDoneButton = false
    public var autosave = false
    
    // MARK: Title
    
    public var titleString: String {
        return self.title ?? "Untitled"
    }
    
    public func refreshTitle() {
        self.title = self.titleString ?? "Untitled"
    }
    
    // MARK: Object
    
    public var object: AnyObject? {
        willSet {
            self.unregisterObservers()
        }
        didSet {
            if self.object != nil {
                self.registerObservers()
            }
            if self.tableView != nil {
                self.configureView()
            }
        }
    }
    
    // MARK: Lifecycle
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let bundle = NSBundle(forClass: SGDynamicTableViewController.self)
        
        self.registerCellNib(DATE_PICKER_CELL_ID,   bundle: bundle)
        self.registerCellNib(PICKER_CELL_ID,        bundle: bundle)
        self.registerCellNib(LABEL_CELL_ID,         bundle: bundle)
        self.registerCellNib(SWITCH_CELL_ID,        bundle: bundle)
        self.registerCellNib(SLIDER_CELL_ID,        bundle: bundle)
        self.registerCellNib(TEXT_FIELD_CELL_ID,    bundle: bundle)
        self.registerCellNib(TEXT_VIEW_CELL_ID,     bundle: bundle)
        self.registerCellNib(TIME_PICKER_CELL_ID,   bundle: bundle)
        self.registerCellNib(SEGMENTED_CELL_ID,     bundle: bundle)
        self.registerCellNib(COLOR_CELL_ID,         bundle: bundle)
        
        self.tableData = self.makeTableData()
        assert(self.dataMatchesTable)
        
        self.registerObservers()
        self.configureView()
        
        self.tableView.alwaysBounceVertical = false
    }
    
    public func registerCellNib(name: String, bundle: NSBundle? = nil) {
        let nib = UINib(nibName: name, bundle: bundle)
        self.tableView.registerNib(nib, forCellReuseIdentifier: name)
    }
    
    public func makeTableData() -> SGTableData {
        return SGTableData()
    }
    
    public func refreshData() {
        self.refreshTitle()
        self.tableView.reloadData()
    }
    
    public func configureView() {
        
        if self.showDoneButton {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done:")
        }
        
        if self.title == nil || self.title == "" {
            self.title = self.object?.name ?? "Untitled"
        }
    }
    
    public func done(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    deinit {
        self.unregisterObservers()
    }
    
    // MARK: Key-Value Coding
    
    public func registerObservers() {
        
        if self.hasRegisteredObservers {
            return
        }
        
        if self.object == nil || self.tableData.sections.count == 0 {
            return
        }
        
        for section in self.tableData.sections {
            for data in section.rows {
                if let path = data.modelPath {
                    self.object?.addObserver(
                        self,
                        forKeyPath: path,
                        options: NSKeyValueObservingOptions([.New, .Old]),
                        context: nil
                    )
                }
            }
        }
        
        self.hasRegisteredObservers = true
    }
    
    public func unregisterObservers() {
        
        if !self.hasRegisteredObservers {
            return
        }
        
        if self.object == nil || self.tableData.sections.count == 0 {
            return
        }
        
        for section in self.tableData.sections {
            for data in section.rows {
                if let path = data.modelPath {
                    self.object?.removeObserver(
                        self,
                        forKeyPath: path,
                        context: nil
                    )
                }
            }
        }
        
        self.hasRegisteredObservers = false
    }
    
    public func path(path1: NSString?, isAncestorOf path2: NSString?) -> Bool {
        
        if path1 == nil || path2 == nil {
            return false
        }
        
        let comps1 = path1!.componentsSeparatedByString(".")
        let comps2 = path2!.componentsSeparatedByString(".")
        
        for var i = 0; i < comps1.count; i++ {
            if comps1[i] != comps2[i] {
                return false
            }
        }
        
        return true
    }
    
    public override func observeValueForKeyPath(keyPath: String?,
                                                ofObject object: AnyObject?,
                                                change: [String : AnyObject]?,
                                                context: UnsafeMutablePointer<Void>) {
        
        for section in self.tableData.sections {
            for data in section.rows {
                if self.path(keyPath, isAncestorOf: data.modelPath) {
                    self.dataModelWillChange(data)
                    self.dataModelDidChange(data)
                    if let indexPath = self.indexPathForData(data) {
                        self.configureCellAtIndexPath(indexPath)
                    }
                }
            }
        }
    }
    
    public func dataModelWillChange(data: SGRowData) {
        // empty
    }
    
    public func dataModelDidChange(data: SGRowData) {
        // empty
    }
    
    // MARK: TextFields
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        if let data = self.dataForControl(textField) {
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    self.dataModelWillChange(data)
                    target.setValue(textField.text, forKeyPath: path)
                    self.dataModelDidChange(data)
                }
                if autosave {
                    SGData.shared.save()
                }
            }
        }
    }
    
    // MARK: TextViews
    
    public func textViewDidEndEditing(textView: UITextView) {
        if let data = self.dataForControl(textView) {
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    self.dataModelWillChange(data)
                    target.setValue(textView.text, forKeyPath: path)
                    self.dataModelDidChange(data)
                }
                if autosave {
                    SGData.shared.save()
                }
            }
        }
    }
    
    // MARK: Switches
    
    public func switchDidChange(toggle: UISwitch) {
        if let data = self.dataForControl(toggle) {
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    self.dataModelWillChange(data)
                    target.setValue(toggle.on, forKeyPath: path)
                    self.dataModelDidChange(data)
                }
                if autosave {
                    SGData.shared.save()
                }
            }
        }
    }
    
    // MARK: Sliders
    
    public func sliderDidChange(slider: UISlider) {
        if let data = self.dataForControl(slider) {
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    self.dataModelWillChange(data)
                    target.setValue(slider.value, forKeyPath: path)
                    self.dataModelDidChange(data)
                }
                if autosave {
                    SGData.shared.save()
                }
            }
        }
    }
    
    // MARK: PickerViews
    
    public func configurePicker(picker: UIPickerView, forModelPath path: String?) {
        //
    }
    
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ""
    }
    
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //
    }
    
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 0
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
    
    // MARK: DatePickers
    
    public func datePickerDidChange(picker: UIDatePicker) {
        
        // Update the model.
        
        if let data = self.dataForControl(picker) {
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    let countdown = (picker.datePickerMode == .CountDownTimer)
                    let value: AnyObject = (countdown) ? picker.countDownDuration : picker.date
                    self.dataModelWillChange(data)
                    target.setValue(value, forKeyPath: path)
                    self.dataModelDidChange(data)
                }
                if autosave {
                    SGData.shared.save()
                }
            }
        }
        
        // Update the cell above.
        
        if let path = self.revealedCellIndexPath?.previous() {
            if let cell = self.tableView.cellForRowAtIndexPath(path) {
                self.configureCell(cell, atIndexPath: path)
            }
        }
    }
    
    // MARK: SegmentedControls
    
    public func configureSegmentedControl(control: UISegmentedControl, forModelPath path: String?) {
        //
    }
    
    public func segmentedControlDidChange(control: UISegmentedControl) {
        if let data = self.dataForControl(control) {
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    self.dataModelWillChange(data)
                    target.setValue(control.selectedSegmentIndex, forKeyPath: path)
                    self.dataModelDidChange(data)
                }
                if autosave {
                    SGData.shared.save()
                }
            }
        }
    }
    
    // MARK: TableViewController
    
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.tableData.sections.count
    }
    
    public override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        // CJC todo: don't hardcode these.
            
        switch self.cellIdentifierForIndexPath(indexPath) {
                
            case TIME_PICKER_CELL_ID:
                return 216.0
            
            case DATE_PICKER_CELL_ID:
                return 216.0
            
            case TEXT_VIEW_CELL_ID:
                return 178.0
            
            case PICKER_CELL_ID:
                return 162.0

            default:
                return self.tableView.rowHeight
        }
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: NSInteger) -> NSInteger {
        
        var numRows = self.tableData.sections[section].rows.count
        
        if section == self.revealedCellIndexPath?.section {
            numRows++
        }
        
        return numRows
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellID = self.cellIdentifierForIndexPath(indexPath)
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier(cellID)
        if cell == nil {
            if cellID == BASIC_CELL_ID {
                cell = UITableViewCell(style: .Default, reuseIdentifier: cellID)
                cell?.textLabel?.font = cell?.textLabel?.font.fontWithSize(16.0)
            } else {
                cell = UITableViewCell(style: .Value1, reuseIdentifier: cellID)
                cell?.textLabel?.font = cell?.textLabel?.font.fontWithSize(16.0)
                cell?.detailTextLabel?.font = cell?.detailTextLabel?.font.fontWithSize(16.0)
            }
        }
        
        self.configureCell(cell!, atIndexPath: indexPath)
        return cell!
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let cell = self.tableView.cellForRowAtIndexPath(indexPath) {
            
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            if self.canExpandCell(cell, atIndexPath: indexPath) {
                self.displayRevealedCellForRowAtIndexPath(indexPath)
            }
            else if let data = self.dataForIndexPath(indexPath) {
                
                if let action = data.action {
                    if self.respondsToSelector(action) {
                        self.performSelector(action, withObject: cell)
                    }
                }
                
                self.didSelectData(data)
                
                if let segueName = data.segueName {
                    self.performSegueWithIdentifier(segueName, sender: cell)
                }
            }
        }
    }
    
    // MARK: Data
    
    public var dataMatchesTable: Bool {
        
        // TODO: Add logic to handle hidden rows.
        
        // Check for mismatched section count.
        if self.tableView.numberOfSections != self.tableData.sections.count {
            return false
        }
        
        // Check for mismatched row counts.
        var index = 0
        for section in self.tableData.sections {
            if self.tableView.numberOfRowsInSection(index) != section.rows.count {
                return false
            }
            index++
        }
        
        return true
    }
    
    public func didSelectData(data: SGRowData) {
        // nothing
    }
    
    // MARK: Mapping
    
    public func targetForData(data: SGRowData) -> AnyObject? {
        return (data.targetType == .Object) ? self.object : self
    }
    
    public func cellForControl(control: UIView) -> UITableViewCell? {
        return control.superview?.superview as? UITableViewCell
    }
    
    public func dataForControl(control: UIView) -> SGRowData? {
        
        if let cell = self.cellForControl(control) {
            return self.dataForCell(cell);
        }
        
        return nil
    }
    
    public func dataForCell(cell: UITableViewCell) -> SGRowData? {
    
        if let path = self.tableView.indexPathForCell(cell) {
            return self.dataForIndexPath(path)
        }
    
        return nil
    }
    
    public func cellForData(data: SGRowData) -> UITableViewCell? {
        
        if let indexPath = self.indexPathForData(data) {
            return self.tableView.cellForRowAtIndexPath(indexPath)
        }
        
        return nil
    }
    
    public func cellForModelPath(modelPath: String) -> UITableViewCell? {
        
        var s = 0
        var r = 0
        
        for section in self.tableData.sections {
            for data in section.rows {
                if modelPath == data.modelPath {
                    let indexPath = NSIndexPath(forRow: r, inSection: s)
                    return self.tableView.cellForRowAtIndexPath(indexPath)
                }
                r++
            }
            r = 0
            s++
        }
        
        return nil
    }
    
    public func dataForIndexPath(indexPath: NSIndexPath) -> SGRowData? {
        
        let modelPath = self.dynamicIndexPath(indexPath)
        if modelPath.section < self.tableData.sections.count {
            let section = self.tableData.sections[modelPath.section]
            if modelPath.row < section.rows.count {
                return section.rows[modelPath.row]
            }
        }
        
        return nil
    }
    
    public func indexPathForData(dataToFind: SGRowData) -> NSIndexPath? {
        
        var s = 0
        var r = 0
        
        for section in self.tableData.sections {
            for data in section.rows {
                if data == dataToFind {
                    return NSIndexPath(forRow: r, inSection: s)
                }
                r++
            }
            r = 0
            s++
        }
        
        return nil
    }
    
    public func enabledStateForModelPath(modelPath: String?) -> Bool {
        return true
    }
    
    public func cellIdentifierForIndexPath(indexPath: NSIndexPath) -> String {
        
        let id = self.dataForIndexPath(indexPath)!.cellIdentifier
        
        if indexPath == self.revealedCellIndexPath {
            
            switch id {
                
                case PICKER_LABEL_CELL_ID:
                    return PICKER_CELL_ID
                
                case DATE_LABEL_CELL_ID:
                    return DATE_PICKER_CELL_ID
                
                case TIME_LABEL_CELL_ID:
                    return TIME_PICKER_CELL_ID
                
                default:
                    break
            }
        }
        
        return id ?? OTHER_CELL_ID
    }
    
    // MARK: Configuration
    
    public func configureCell(cell: UITableViewCell) {
        if let path = self.tableView.indexPathForCell(cell) {
            self.configureCell(cell, atIndexPath: path)
        }
    }
    
    public func configureCellAtIndexPath(path: NSIndexPath) {
        if let cell = self.tableView.cellForRowAtIndexPath(path) {
            self.configureCell(cell, atIndexPath: path)
        }
    }
    
    public func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        
        let data = self.dataForIndexPath(indexPath)!
        
        switch (cell.reuseIdentifier ?? "") {
            
        case BASIC_CELL_ID:
            
            var text = ""
            
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value: AnyObject = target.valueForKeyPath(path) {
                        text = "\(value)"
                    }
                }
            }
            
            cell.textLabel?.text = text
            
            if data.segueName != nil {
                cell.accessoryType = .DisclosureIndicator
            }
            else if data.checked == true {
                cell.accessoryType = .Checkmark
            }
            else {
                cell.accessoryType = .None
            }
        
        case OTHER_CELL_ID:
            
            cell.textLabel?.text = data.title
            //cell.selectionStyle = .None
            
            if data.segueName != nil {
                cell.accessoryType = .DisclosureIndicator
            }
            else if data.checked == true {
                cell.accessoryType = .Checkmark
            }
            else {
                cell.accessoryType = .None
            }
            
        case PICKER_LABEL_CELL_ID:
        
            cell.textLabel?.text = data.title
            
            var text = "Untitled"
            
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let name = target.valueForKeyPath(path) as? String {
                        text = name
                    }
                }
            }
        
            cell.detailTextLabel?.text = text
        
        case DATE_LABEL_CELL_ID:
            
            cell.textLabel?.text = data.title
            
            var date = NSDate()
            
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value = target.valueForKeyPath(path) as? NSDate {
                        date = value
                    }
                }
            }
        
            cell.detailTextLabel?.text = SGFormatter.dateStringFromDate(date)
        
        case TIME_LABEL_CELL_ID:
            
            cell.textLabel?.text = data.title
            
            var length = 0.0
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value = target.valueForKeyPath(path) as? NSTimeInterval {
                        length = value
                    }
                }
            }
            
            let timeString = SGFormatter.stringFromLength(length)
            
            cell.detailTextLabel?.text = timeString
            
        case LABEL_CELL_ID:
            
            var text = ""
            
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value: AnyObject = target.valueForKeyPath(path) {
                        text = "\(value)"
                    }
                }
            }
            
            let textLabel = cell.viewWithTag(1) as? UILabel
            let detailTextLabel = cell.viewWithTag(2) as? UILabel
            
            textLabel?.text = data.title
            detailTextLabel?.text = text
            
            if data.segueName != nil {
                cell.accessoryType = .DisclosureIndicator
            }
            else if data.checked == true {
                cell.accessoryType = .Checkmark
            }
            else {
                cell.accessoryType = .None
            }
            
        case COLOR_CELL_ID:
            
            let colorView = cell.viewWithTag(2) as! SGColorView
            
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value = target.valueForKeyPath(path) as? UIColor {
                        colorView.color = value
                    }
                }
            }
            
            let label = cell.viewWithTag(1) as! UILabel
            label.text = data.title
            
            cell.accessoryType = .DisclosureIndicator
        
        case TEXT_FIELD_CELL_ID:
            
            let label = cell.viewWithTag(1) as! UILabel
            label.text = data.title
            
            var text = "Untitled"
            
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value = target.valueForKeyPath(path) as? String {
                        text = value
                    }
                }
            }
            
            let textField = cell.viewWithTag(2) as! UITextField
            textField.text = text
            textField.delegate = self
        
        case TEXT_VIEW_CELL_ID:
            
            var text = ""
            
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value = target.valueForKeyPath(path) as? String {
                        text = value
                    }
                }
            }
            
            let textView = cell.viewWithTag(2) as! UITextView
            textView.text = text
            textView.delegate = self
            
        case SWITCH_CELL_ID:
            
            let label = cell.viewWithTag(1) as! UILabel
            label.text = data.title
            
            var on = false
            
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value = target.valueForKeyPath(path) as? Bool {
                        on = value
                    }
                }
            }
            
            let toggle = cell.viewWithTag(2) as! UISwitch
            toggle.on = on
            
            toggle.addTarget(self, action: "switchDidChange:", forControlEvents: .ValueChanged)
            
        case SLIDER_CELL_ID:
            
            let label = cell.viewWithTag(1) as! UILabel
            label.text = data.title
            
            var number: Float = 0.0
            
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value = target.valueForKeyPath(path) as? Float {
                        number = value
                    }
                }
            }
            
            let slider = cell.viewWithTag(2) as! UISlider
            slider.minimumValue = Float(data.range.location)
            slider.maximumValue = Float(data.range.location + data.range.length)
            slider.value = number
            
            slider.addTarget(self, action: "sliderDidChange:", forControlEvents: .ValueChanged)
            
        case PICKER_CELL_ID:
            
            let picker = cell.viewWithTag(2) as! UIPickerView
            picker.delegate = self
            self.configurePicker(picker, forModelPath: data.modelPath)
        
        case DATE_PICKER_CELL_ID:
            
            var date = NSDate()
            
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value = target.valueForKeyPath(path) as? NSDate {
                        date = value
                    }
                }
            }
            
            let picker = cell.viewWithTag(2) as! UIDatePicker
            picker.setDate(date, animated: false)
            
            picker.addTarget(self, action: "datePickerDidChange:", forControlEvents: .ValueChanged)
            
        case TIME_PICKER_CELL_ID:
            
            var length = 0.0
            
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value = target.valueForKeyPath(path) as? NSTimeInterval {
                        length = value
                    }
                }
            }
            
            let picker = cell.viewWithTag(2) as! UIDatePicker
            picker.countDownDuration = length
            
            picker.addTarget(self, action: "datePickerDidChange:", forControlEvents: .ValueChanged)
            
        case SEGMENTED_CELL_ID:
            
            let control = cell.viewWithTag(2) as! UISegmentedControl
            
            var index = 0
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value = target.valueForKeyPath(path) as? Int {
                        index = Int(value)
                    }
                }
            }
 
            self.configureSegmentedControl(control, forModelPath: data.modelPath)
            control.selectedSegmentIndex = index
            control.addTarget(self, action: "segmentedControlDidChange:", forControlEvents: .ValueChanged)
            
        default:
            break
        }
        
        let enabled = self.enabledStateForModelPath(data.modelPath)
        self.setEnabled(enabled, forCell: cell)
    }
    
    public func setEnabled(enabled: Bool, forCell cell: UITableViewCell) {
        cell.userInteractionEnabled = enabled
        cell.textLabel?.enabled = enabled
        cell.detailTextLabel?.enabled = enabled
    }
    
    public func refreshSection(section: Int) {
        for i in 0 ..< self.tableView.numberOfRowsInSection(section) {
            let path = NSIndexPath(forRow: i, inSection: 0)
            if let cell = self.tableView.cellForRowAtIndexPath(path) {
                self.configureCell(cell)
            }
        }
    }
    
    // MARK: Hide/Show
    
    public func dynamicIndexPath(indexPath: NSIndexPath) -> NSIndexPath {
        
        if let path = self.revealedCellIndexPath {
            if (path.section == indexPath.section && path.row <= indexPath.row) {
                return indexPath.previous()
            }
        }
        
        return indexPath
    }
    
    public func targetedCell() -> NSIndexPath? {
        if let path = self.revealedCellIndexPath {
            return path.previous()
        } else {
            return self.tableView.indexPathForSelectedRow
        }
    }
    
    public func hasRevealedCell() -> Bool {
        return self.revealedCellIndexPath != nil
    }
    
    public func canExpandCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) -> Bool {
        let hasRevealableCellBelow = (cell.reuseIdentifier == TIME_LABEL_CELL_ID) // CJC: revisit
        let canModify = true // CJC: revisit
        return hasRevealableCellBelow && canModify
    }
    
    public func hasRevealedCellForIndexPath(indexPath: NSIndexPath) -> Bool {
        
        if let thisCell = self.tableView.cellForRowAtIndexPath(indexPath) {
            if let nextCell = self.tableView.cellForRowAtIndexPath(indexPath.next()) {
                
                let thisID = thisCell.reuseIdentifier
                let nextID = nextCell.reuseIdentifier
                
                if thisID == TIME_LABEL_CELL_ID {
                    return nextID == TIME_PICKER_CELL_ID
                }
                
                if thisID == DATE_LABEL_CELL_ID {
                    return nextID == DATE_PICKER_CELL_ID
                }
                
                if thisID == PICKER_LABEL_CELL_ID {
                    return nextID == PICKER_CELL_ID
                }
            }
        }
        
        return false
    }
    
    public func updateRevealedControl() {
        if let path = self.revealedCellIndexPath {
            if let cell = self.tableView.cellForRowAtIndexPath(path) {
                self.configureCell(cell, atIndexPath: path)
            }
        }
    }
    
    public func toggleRevealedCellForSelectedIndexPath(indexPath: NSIndexPath) {
        
        self.tableView.beginUpdates()
        
        let indexPaths = [indexPath.next()]
        
        if self.hasRevealedCellForIndexPath(indexPath) {
            self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        } else {
            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        }
        
        self.tableView.endUpdates()
    }
    
    public func displayRevealedCellForRowAtIndexPath(indexPath: NSIndexPath) {
        
        self.tableView.beginUpdates()
        
        var before = false
        var sameCellClicked = false
        
        if let path = self.revealedCellIndexPath {
            before = path.row < indexPath.row
            sameCellClicked = (path.previous() == indexPath)
            self.tableView.deleteRowsAtIndexPaths([path], withRowAnimation: .Fade)
            self.revealedCellIndexPath = nil
        }
        
        if !sameCellClicked {
            let path = (before) ? indexPath.previous() : indexPath
            self.toggleRevealedCellForSelectedIndexPath(path)
            self.revealedCellIndexPath = path.next()
        }
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.tableView.endUpdates()
        
        self.updateRevealedControl()
    }
}
