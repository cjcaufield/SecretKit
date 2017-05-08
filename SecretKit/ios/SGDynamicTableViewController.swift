//
//  SGDynamicTableViewController.swift
//  SecretKit
//
//  Created by Colin Caufield on 4/17/15.
//  Copyright (c) 2015 Secret Geometry, Inc. All rights reserved.
//

import UIKit

open class SGDynamicTableViewController: UITableViewController,
                                         UITextFieldDelegate,
                                         UITextViewDelegate,
                                         UIPickerViewDelegate
{
    
    // MARK: Properties
    
    open var tableData = SGTableData()
    open var revealedCellIndexPath: IndexPath?
    open var hasRegisteredObservers = false
    open var showDoneButton = false
    open var autosave = false
    
    // MARK: Title
    
    open var titleString: String {
        return self.title ?? "Untitled"
    }
    
    open func refreshTitle() {
        let title = self.titleString
        if title == "" {
            self.title = "Untitled"
        } else {
            self.title = title
        }
    }
    
    // MARK: Object
    
    open var object: AnyObject? {
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
    
    open override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.refreshTitle()
        
        let bundle = Bundle(for: SGDynamicTableViewController.self)
        
        self.registerCellNib(name: DATE_PICKER_CELL_ID,   bundle: bundle)
        self.registerCellNib(name: PICKER_CELL_ID,        bundle: bundle)
        self.registerCellNib(name: LABEL_CELL_ID,         bundle: bundle)
        self.registerCellNib(name: SWITCH_CELL_ID,        bundle: bundle)
        self.registerCellNib(name: SLIDER_CELL_ID,        bundle: bundle)
        self.registerCellNib(name: TEXT_FIELD_CELL_ID,    bundle: bundle)
        self.registerCellNib(name: TEXT_VIEW_CELL_ID,     bundle: bundle)
        self.registerCellNib(name: TIME_PICKER_CELL_ID,   bundle: bundle)
        self.registerCellNib(name: SEGMENTED_CELL_ID,     bundle: bundle)
        self.registerCellNib(name: COLOR_CELL_ID,         bundle: bundle)
        
        self.tableData = self.makeTableData()
        assert(self.dataMatchesTable)
        
        self.registerObservers()
        self.configureView()
        
        self.tableView.alwaysBounceVertical = false
    }
    
    open func registerCellNib(name: String, bundle: Bundle? = nil) {
        let nib = UINib(nibName: name, bundle: bundle)
        self.tableView.register(nib, forCellReuseIdentifier: name)
    }
    
    open func makeTableData() -> SGTableData {
        return SGTableData()
    }
    
    open func refreshData() {
        self.refreshTitle()
        self.tableView.reloadData()
    }
    
    open func configureView() {
        
        if self.showDoneButton {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        }
        
        if self.title == nil || self.title == "" {
            if let name = self.object?.value(forKey: "name") as? String {
                self.title = name
            } else {
                self.title = "Untitled"
            }
        }
    }
    
    open func done(sender: AnyObject) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    deinit {
        self.unregisterObservers()
    }
    
    // MARK: Key-Value Coding
    
    open func registerObservers() {
        
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
                        options: NSKeyValueObservingOptions([.new, .old]),
                        context: nil
                    )
                }
            }
        }
        
        self.hasRegisteredObservers = true
    }
    
    open func unregisterObservers() {
        
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
    
    open func path(_ path1: String?, isAncestorOf path2: String?) -> Bool {
        
        if path1 == nil || path2 == nil {
            return false
        }
        
        let comps1 = path1!.components(separatedBy: ".")
        let comps2 = path2!.components(separatedBy: ".")
        
        for i in 0 ..< comps1.count {
            if comps1[i] != comps2[i] {
                return false
            }
        }
        
        return true
    }
    
    open override func observeValue(forKeyPath keyPath: String?,
                                      of object: Any?,
                                      change: [NSKeyValueChangeKey : Any]?,
                                      context: UnsafeMutableRawPointer?) {
        
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
    
    open func dataModelWillChange(_ data: SGRowData) {
        // empty
    }
    
    open func dataModelDidChange(_ data: SGRowData) {
        // empty
    }
    
    // MARK: TextFields
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
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
    
    open func textViewDidEndEditing(_ textView: UITextView) {
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
    
    open func switchDidChange(_ toggle: UISwitch) {
        if let data = self.dataForControl(toggle) {
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    self.dataModelWillChange(data)
                    target.setValue(toggle.isOn, forKeyPath: path)
                    self.dataModelDidChange(data)
                }
                if autosave {
                    SGData.shared.save()
                }
            }
        }
    }
    
    // MARK: Sliders
    
    open func sliderDidChange(_ slider: UISlider) {
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
    
    open func configurePickerView(_ picker: UIPickerView, forModelPath path: String?) {
        //
    }
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ""
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //
    }
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 0
    }

    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 0
    }
    
    // MARK: DatePickers
    
    open func datePickerDidChange(_ picker: UIDatePicker) {
        
        // Update the model.
        
        if let data = self.dataForControl(picker) {
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    let countdown = (picker.datePickerMode == .countDownTimer)
                    let value = (countdown) ? picker.countDownDuration as AnyObject : picker.date as AnyObject
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
            if let cell = self.tableView.cellForRow(at: path as IndexPath) {
                self.configureCell(cell, atIndexPath: path)
            }
        }
    }
    
    // MARK: SegmentedControls
    
    open func configureSegmentedControl(_ control: UISegmentedControl, forModelPath path: String?) {
        //
    }
    
    open func segmentedControlDidChange(control: UISegmentedControl) {
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
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return self.tableData.sections.count
    }
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
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
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: NSInteger) -> NSInteger {
        
        var numRows = self.tableData.sections[section].rows.count
        
        if section == self.revealedCellIndexPath?.section {
            numRows += 1
        }
        
        return numRows
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellID = self.cellIdentifierForIndexPath(indexPath)
        
        var cell = self.tableView.dequeueReusableCell(withIdentifier: cellID)
        if cell == nil {
            if cellID == BASIC_CELL_ID {
                cell = UITableViewCell(style: .default, reuseIdentifier: cellID)
                cell?.textLabel?.font = cell?.textLabel?.font.withSize(16.0)
            } else {
                cell = UITableViewCell(style: .value1, reuseIdentifier: cellID)
                cell?.textLabel?.font = cell?.textLabel?.font.withSize(16.0)
                cell?.detailTextLabel?.font = cell?.detailTextLabel?.font.withSize(16.0)
            }
        }
        
        self.configureCell(cell!, atIndexPath: indexPath)
        return cell!
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = self.tableView.cellForRow(at: indexPath as IndexPath) {
            if let data = self.dataForIndexPath(indexPath) {
                if let segueName = data.segueName {
                    self.performSegue(withIdentifier: segueName, sender: cell)
                    return
                }
            }
        }
    }
    
    open override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        if let cell = self.tableView.cellForRow(at: indexPath as IndexPath) {
            
            self.tableView.deselectRow(at: indexPath as IndexPath, animated: true)
            
            if self.canExpandCell(cell, atIndexPath: indexPath) {
                self.displayRevealedCellForRowAtIndexPath(indexPath)
            }
            else if let data = self.dataForIndexPath(indexPath) {
                
                if let action = data.action {
                    if self.responds(to: action) {
                        self.perform(action, with: cell)
                    }
                }
                
                self.didSelectData(data)
                
                if let segueName = data.segueName {
                    self.performSegue(withIdentifier: segueName, sender: cell)
                }
            }
        }
    }
    
    // MARK: Data
    
    open var dataMatchesTable: Bool {
        
        // TODO: Add logic to handle hidden rows.
        
        // Check for mismatched section count.
        if self.tableView.numberOfSections != self.tableData.sections.count {
            return false
        }
        
        // Check for mismatched row counts.
        var index = 0
        for section in self.tableData.sections {
            if self.tableView.numberOfRows(inSection: index) != section.rows.count {
                return false
            }
            index += 1
        }
        
        return true
    }
    
    open func didSelectData(_ data: SGRowData) {
        // nothing
    }
    
    // MARK: Mapping
    
    open func targetForData(_ data: SGRowData) -> AnyObject? {
        return (data.targetType == .Object) ? self.object : self
    }
    
    open func cellForControl(_ control: UIView) -> UITableViewCell? {
        return control.superview?.superview as? UITableViewCell
    }
    
    open func dataForControl(_ control: UIView) -> SGRowData? {
        
        if let cell = self.cellForControl(control) {
            return self.dataForCell(cell);
        }
        
        return nil
    }
    
    open func dataForCell(_ cell: UITableViewCell) -> SGRowData? {
    
        if let path = self.tableView.indexPath(for: cell) {
            return self.dataForIndexPath(path)
        }
    
        return nil
    }
    
    open func cellForData(_ data: SGRowData) -> UITableViewCell? {
        
        if let indexPath = self.indexPathForData(data) {
            return self.tableView.cellForRow(at: indexPath)
        }
        
        return nil
    }
    
    open func cellForModelPath(_ modelPath: String) -> UITableViewCell? {
        
        var s = 0
        var r = 0
        
        for section in self.tableData.sections {
            for data in section.rows {
                if modelPath == data.modelPath {
                    let indexPath = IndexPath(row: r, section: s)
                    return self.tableView.cellForRow(at: indexPath)
                }
                r += 1
            }
            r = 0
            s += 1
        }
        
        return nil
    }
    
    open func dataForIndexPath(_ indexPath: IndexPath) -> SGRowData? {
        
        let modelPath = self.dynamicIndexPath(for: indexPath)
        if modelPath.section < self.tableData.sections.count {
            let section = self.tableData.sections[modelPath.section]
            if modelPath.row < section.rows.count {
                return section.rows[modelPath.row]
            }
        }
        
        return nil
    }
    
    open func indexPathForData(_ dataToFind: SGRowData) -> IndexPath? {
        
        var s = 0
        var r = 0
        
        for section in self.tableData.sections {
            for data in section.rows {
                if data == dataToFind {
                    return IndexPath(row: r, section: s)
                }
                r += 1
            }
            r = 0
            s += 1
        }
        
        return nil
    }
    
    open func enabledStateForModelPath(_ modelPath: String?) -> Bool {
        return true
    }
    
    open func cellIdentifierForIndexPath(_ indexPath: IndexPath) -> String {
        
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
        
        return id
    }
    
    // MARK: Configuration
    
    open func configureCell(_ cell: UITableViewCell) {
        if let path = self.tableView.indexPath(for: cell) {
            self.configureCell(cell, atIndexPath: path)
        }
    }
    
    open func configureCellAtIndexPath(_ path: IndexPath) {
        if let cell = self.tableView.cellForRow(at: path as IndexPath) {
            self.configureCell(cell, atIndexPath: path)
        }
    }
    
    open func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        
        let data = self.dataForIndexPath(indexPath)!
        
        switch (cell.reuseIdentifier ?? "") {
            
        case BASIC_CELL_ID:
            
            var text = ""
            
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value: Any = target.value(forKeyPath: path) {
                        text = "\(value)"
                    }
                }
            }
            
            if text == "" {
                text = data.title
            }
            
            cell.textLabel?.text = text
            
            if data.segueName != nil {
                cell.accessoryType = .disclosureIndicator
            }
            else if data.checked == true {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
        
        case OTHER_CELL_ID:
            
            cell.textLabel?.text = data.title
            //cell.selectionStyle = .None
            
            if data.segueName != nil {
                cell.accessoryType = .disclosureIndicator
            }
            else if data.checked == true {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
            
        case PICKER_LABEL_CELL_ID:
        
            cell.textLabel?.text = data.title
            
            var text = "Untitled"
            
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let name = target.value(forKeyPath: path) as? String {
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
                    if let value = target.value(forKeyPath: path) as? NSDate {
                        date = value
                    }
                }
            }
        
            cell.detailTextLabel?.text = SGFormatter.dateStringFromDate(date as Date)
        
        case TIME_LABEL_CELL_ID:
            
            cell.textLabel?.text = data.title
            
            var length = 0.0
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value = target.value(forKeyPath: path) as? TimeInterval {
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
                    if let value: Any = target.value(forKeyPath: path) {
                        text = "\(value)"
                    }
                }
            }
            
            let textLabel = cell.viewWithTag(1) as? UILabel
            let detailTextLabel = cell.viewWithTag(2) as? UILabel
            
            textLabel?.text = data.title
            detailTextLabel?.text = text
            
            if data.segueName != nil {
                cell.accessoryType = .disclosureIndicator
            }
            else if data.checked == true {
                cell.accessoryType = .checkmark
            }
            else {
                cell.accessoryType = .none
            }
            
        case COLOR_CELL_ID:
            
            let colorView = cell.viewWithTag(2) as! SGColorView
            
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value = target.value(forKeyPath: path) as? UIColor {
                        colorView.color = value
                    }
                }
            }
            
            let label = cell.viewWithTag(1) as! UILabel
            label.text = data.title
            
            cell.accessoryType = .disclosureIndicator
        
        case TEXT_FIELD_CELL_ID:
            
            let label = cell.viewWithTag(1) as! UILabel
            label.text = data.title
            
            var text = "Untitled"
            
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value = target.value(forKeyPath: path) as? String {
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
                    if let value = target.value(forKeyPath: path) as? String {
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
                    if let value = target.value(forKeyPath: path) as? Bool {
                        on = value
                    }
                }
            }
            
            let toggle = cell.viewWithTag(2) as! UISwitch
            toggle.isOn = on
            
            toggle.addTarget(self, action: #selector(switchDidChange(_:)), for: .valueChanged)
            
        case SLIDER_CELL_ID:
            
            let label = cell.viewWithTag(1) as! UILabel
            label.text = data.title
            
            var number: Float = 0.0
            
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value = target.value(forKeyPath: path) as? Float {
                        number = value
                    }
                }
            }
            
            let slider = cell.viewWithTag(2) as! UISlider
            slider.minimumValue = Float(data.range.location)
            slider.maximumValue = Float(data.range.location + data.range.length)
            slider.value = number
            
            slider.addTarget(self, action: #selector(sliderDidChange(_:)), for: .valueChanged)
            
        case PICKER_CELL_ID:
            
            let picker = cell.viewWithTag(2) as! UIPickerView
            picker.delegate = self
            self.configurePickerView(picker, forModelPath: data.modelPath)
        
        case DATE_PICKER_CELL_ID:
            
            var date = NSDate()
            
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value = target.value(forKeyPath: path) as? NSDate {
                        date = value
                    }
                }
            }
            
            let picker = cell.viewWithTag(2) as! UIDatePicker
            picker.setDate(date as Date, animated: false)
            
            picker.addTarget(self, action: #selector(datePickerDidChange(_:)), for: .valueChanged)
            
        case TIME_PICKER_CELL_ID:
            
            var length = 0.0
            
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value = target.value(forKeyPath: path) as? TimeInterval {
                        length = value
                    }
                }
            }
            
            let picker = cell.viewWithTag(2) as! UIDatePicker
            picker.countDownDuration = length
            
            picker.addTarget(self, action: #selector(datePickerDidChange(_:)), for: .valueChanged)
            
        case SEGMENTED_CELL_ID:
            
            let control = cell.viewWithTag(2) as! UISegmentedControl
            
            var index = 0
            if let path = data.modelPath {
                if let target = self.targetForData(data) {
                    if let value = target.value(forKeyPath: path) as? Int {
                        index = Int(value)
                    }
                }
            }
 
            self.configureSegmentedControl(control, forModelPath: data.modelPath)
            control.selectedSegmentIndex = index
            control.addTarget(self, action: #selector(segmentedControlDidChange), for: .valueChanged)
            
        default:
            break
        }
        
        let enabled = self.enabledStateForModelPath(data.modelPath)
        self.enable(cell, enabled)
    }
    
    open func enable(_ cell: UITableViewCell, _ enabled: Bool) {
        cell.isUserInteractionEnabled = enabled
        cell.textLabel?.isEnabled = enabled
        cell.detailTextLabel?.isEnabled = enabled
    }
    
    open func refresh(section: Int) {
        for i in 0 ..< self.tableView.numberOfRows(inSection: section) {
            let path = IndexPath(row: i, section: 0)
            if let cell = self.tableView.cellForRow(at: path) {
                self.configureCell(cell)
            }
        }
    }
    
    // MARK: Hide/Show
    
    open func dynamicIndexPath(for indexPath: IndexPath) -> IndexPath {
        
        if let path = self.revealedCellIndexPath {
            if (path.section == indexPath.section && path.row <= indexPath.row) {
                return indexPath.previous()
            }
        }
        
        return indexPath
    }
    
    open func targetedCell() -> IndexPath? {
        if let path = self.revealedCellIndexPath {
            return path.previous()
        } else {
            return self.tableView.indexPathForSelectedRow
        }
    }
    
    open func hasRevealedCell() -> Bool {
        return self.revealedCellIndexPath != nil
    }
    
    open func canExpandCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) -> Bool {
        let hasRevealableCellBelow = (cell.reuseIdentifier == TIME_LABEL_CELL_ID) // CJC: revisit
        let canModify = true // CJC: revisit
        return hasRevealableCellBelow && canModify
    }
    
    open func hasRevealedCellFor(_ indexPath: IndexPath) -> Bool {
        
        if let thisCell = self.tableView.cellForRow(at: indexPath as IndexPath) {
            if let nextCell = self.tableView.cellForRow(at: indexPath.next() as IndexPath) {
                
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
    
    open func updateRevealedControl() {
        if let path = self.revealedCellIndexPath {
            if let cell = self.tableView.cellForRow(at: path as IndexPath) {
                self.configureCell(cell, atIndexPath: path)
            }
        }
    }
    
    open func toggleRevealedCellFor(_ indexPath: IndexPath) {
        
        self.tableView.beginUpdates()
        
        let indexPaths = [indexPath.next()]
        
        if self.hasRevealedCellFor(indexPath) {
            self.tableView.deleteRows(at: indexPaths as [IndexPath], with: .fade)
        } else {
            self.tableView.insertRows(at: indexPaths as [IndexPath], with: .fade)
        }
        
        self.tableView.endUpdates()
    }
    
    open func displayRevealedCellForRowAtIndexPath(_ indexPath: IndexPath) {
        
        self.tableView.beginUpdates()
        
        var before = false
        var sameCellClicked = false
        
        if let path = self.revealedCellIndexPath {
            before = path.row < indexPath.row
            sameCellClicked = (path.previous() == indexPath)
            self.tableView.deleteRows(at: [path as IndexPath], with: .fade)
            self.revealedCellIndexPath = nil
        }
        
        if !sameCellClicked {
            let path = (before) ? indexPath.previous() : indexPath
            self.toggleRevealedCellFor(path)
            self.revealedCellIndexPath = path.next()
        }
        
        self.tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        self.tableView.endUpdates()
        
        self.updateRevealedControl()
    }
}
