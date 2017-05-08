//
//  SGAbstractTableViewController.swift
//  SecretKit
//
//  Created by Colin Caufield on 4/1/15.
//  Copyright (c) 2015 Secret Geometry, Inc. All rights reserved.
//

import UIKit

open class SGAbstractTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    open var titleString: String { return "Untitled" }
    open var needsBackButton: Bool { return false }
    open var autoSelectAddedObjects: Bool { return true }
    open var headerHeight: CGFloat { return 0.0 }
    open var centerHeaderText: Bool { return false }
    open var allowReordering: Bool { return false }
    open var allowInsertion: Bool { return true }
    open var allowEditing: Bool { return true }
    open var orderingKey: String { return "ordering" }
    
    open var addButton: UIBarButtonItem!
    open var editButton: UIBarButtonItem!
    
    open var ignoreModelChanges = false
    open var pathToScrollTo: IndexPath?
    open weak var recentlySelectedObject: AnyObject?
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = self.titleString
        
        self.editButton = self.editButtonItem
        self.addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add(sender:)))
        
        let navItem = self.navigationItem
        
        if (self.needsBackButton) {
            navItem.rightBarButtonItems = [self.addButton, self.editButton]
        } else {
            navItem.leftBarButtonItem = self.editButton
            navItem.rightBarButtonItem = self.addButton
        }
        
        self.tableView.alwaysBounceVertical = false
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateBarButtonStates()
    }
    
    open func updateBarButtonStates() {
        self.addButton.isEnabled = self.allowInsertion
        self.editButton.isEnabled = self.allowEditing
    }
    
    // MARK: - Data methods to override
    
    open var typeName: String {
        preconditionFailure() // subclasses must implement
    }
    
    open func fetchObjects() {
        // nothing
    }
    
    open func createNewObject() -> AnyObject {
        preconditionFailure() // subclasses must implement
    }
    
    open func prepareNewObject(_ object: AnyObject) {
        // nothing
    }
    
    open func objectAt(_ indexPath: IndexPath) -> AnyObject {
        preconditionFailure() // subclasses must implement
    }
    
    open func allObjects() -> [AnyObject] {
        preconditionFailure() // subclasses must implement
    }
    
    open func deleteObject(_ object: AnyObject, at indexPath: IndexPath) {
        // nothing
    }
    
    open func didSelectObject(_ object: AnyObject, new: Bool = false) {
        // nothing
    }
    
    open func canEditObject(_ object: AnyObject) -> Bool {
        return true
    }
    
    open func saveObjects() {
        // nothing
    }
    
    // MARK: - Cell methods to override
    
    open func cellIdentifierForObject(_ object: AnyObject) -> String {
        preconditionFailure() // subclasses must implement
    }
    
    open func configureCell(_ cell: UITableViewCell, withObject object: AnyObject) {
        // nothing
    }
    
    // MARK: - Editing
    
    @IBAction open func add(sender: AnyObject?) {
        
        let object = self.createNewObject()
        self.prepareNewObject(object)
        
        if self.autoSelectAddedObjects {
            self.recentlySelectedObject = object
            self.didSelectObject(object, new: true)
        }
        
        self.saveObjects()
    }
    
    @IBAction open func edit(sender: AnyObject?) {
        if self.allowEditing {
            self.tableView.setEditing(!self.tableView.isEditing, animated: true)
        }
    }
    
    // MARK: - Ordering
    
    open func resetOrdering() {
        
        var index = 0
        for object in self.allObjects() {
            object.setValue(NSInteger(index), forKey: self.orderingKey)
            index += 1
        }
        
        checkOrdering()
    }
    
    open func checkOrdering() {
        
        var index = 0
        for object in self.allObjects() {
            let ordering = object.value(forKey: self.orderingKey) as! NSInteger
            assert(ordering == NSInteger(index))
            index += 1
        }
    }
    
    // MARK: - Internal table view methods
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allObjects().count
    }
    
    open override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.headerHeight
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = self.objectAt(indexPath)
        let identifier = self.cellIdentifierForObject(object)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as UITableViewCell
        self.configureCell(cell, withObject: object)
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let object = self.objectAt(indexPath)
        self.recentlySelectedObject = object
        self.didSelectObject(object)
    }
    
    open override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let object = self.objectAt(indexPath)
        return self.canEditObject(object)
    }
    
    open override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if self.allowReordering {
            self.checkOrdering()
        }
    
        if editingStyle == .delete {
            
            if self.allowReordering {
                let count = tableView.numberOfRows(inSection: indexPath.section)
                for _ in indexPath.row + 1 ..< count {
                    let object = self.objectAt(indexPath) as! NSObject
                    let oldOrdering = object.value(forKeyPath: self.orderingKey) as! NSInteger
                    object.setValue(oldOrdering - 1, forKey: self.orderingKey)
                }
            }
            
            let object = self.objectAt(indexPath)
            self.deleteObject(object, at: indexPath)
        }
    }
    
    open override func tableView(_ tableView: UITableView, moveRowAt sourcePath: IndexPath, to targetPath: IndexPath) {
        
        if !self.allowReordering {
            return
        }
        
        if sourcePath == targetPath {
            return
        }
        
        self.checkOrdering()
        
        self.ignoreModelChanges = true
        
        let objectToMove = self.objectAt(sourcePath)
        
        let sameSection = (sourcePath.section == targetPath.section)
        
        if sameSection {
            
            if sourcePath.row < targetPath.row {
                
                for row in sourcePath.row + 1 ... targetPath.row {
                    
                    let path = IndexPath(row: row, section: sourcePath.section)
                    let object = self.objectAt(path) as! NSObject
                    
                    let oldOrdering = object.value(forKey: self.orderingKey) as! NSInteger
                    object.setValue(oldOrdering - 1, forKey: self.orderingKey)
                }
            }
            else {
                
                for row in targetPath.row ... sourcePath.row - 1  {
                    
                    let path = IndexPath(row: row, section: sourcePath.section)
                    let object = self.objectAt(path) as! NSObject
                    
                    let oldOrdering = object.value(forKey: self.orderingKey) as! NSInteger
                    object.setValue(oldOrdering + 1, forKey: self.orderingKey)
                }
            }
            
            objectToMove.setValue(NSInteger(targetPath.row), forKey: self.orderingKey)
            
        }
        else {
            
            let sourceCount = tableView.numberOfRows(inSection: sourcePath.section)
            for row in sourcePath.row + 1 ..< sourceCount {
                
                let path = IndexPath(row: row, section: sourcePath.section)
                let object = self.objectAt(path)
                
                let oldOrdering = object.value(forKey: self.orderingKey) as! NSInteger
                object.setValue(oldOrdering - 1, forKey: self.orderingKey)
            }
            
            let targetCount = tableView.numberOfRows(inSection: targetPath.section)
            for row in targetPath.row ..< targetCount {
                
                let path = IndexPath(row: row, section: targetPath.section)
                let object = self.objectAt(path)
                
                let oldOrdering = object.value(forKey: self.orderingKey) as! NSInteger
                object.setValue(oldOrdering + 1, forKey: self.orderingKey)
            }
            
            objectToMove.setValue(NSInteger(targetPath.row), forKey: self.orderingKey)
        }
        
        self.saveObjects()
        
        self.ignoreModelChanges = false
    }
}
