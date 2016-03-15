//
//  SGCoreDataTableViewController.swift
//  Skiptracer
//
//  Created by Colin Caufield on 4/1/15.
//  Copyright (c) 2015 Secret Geometry, Inc. All rights reserved.
//

import UIKit
import CoreData

public class SGCoreDataTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    public override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let editButton = self.editButtonItem()
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "add:")
        
        let navItem = self.navigationItem
        
        if (self.needsBackButton) {
            navItem.rightBarButtonItems = [addButton, editButton]
        } else {
            navItem.leftBarButtonItem = editButton
            navItem.rightBarButtonItem = addButton
        }
        
        self.tableView.alwaysBounceVertical = false
    }
    
    // MARK: - Methods to override.
    
    public var needsBackButton: Bool { return false }
    
    public var fetchPredicate: NSPredicate? { return nil }
    
    public var fetchBatchSize: Int { return 20 }
    
    public var sortDescriptors: [NSSortDescriptor] { return [] }
    
    public var sectionKey: String? { return nil }
    
    public var headerHeight: CGFloat { return 0.0 }
    
    public var centerHeaderText: Bool { return false }
    
    public var cacheName: String? { return nil }
    
    public var entityName: String {
        assertionFailure("entityName must be overridden in SGCoreDataTableViewController subclasses.")
        return ""
    }
    
    public func cellIdentifierForObject(object: AnyObject) -> String {
        assertionFailure("cellIdentifierForObject must be overridden in SGCoreDataTableViewController subclasses.")
        return ""
    }
    
    public func createNewObject() -> NSManagedObject {
        return NSEntityDescription.insertNewObjectForEntityForName(self.entityName, inManagedObjectContext: self.context!) as NSManagedObject
    }
    
    public func deleteObject(object: NSManagedObject) {
        self.context!.deleteObject(object)
        SGData.shared.save()
    }
    
    public func prepareNewObject(object: AnyObject) {
        // nothing
    }
    
    public func configureCell(cell: UITableViewCell, withObject object: AnyObject) {
        // nothing
    }
    
    public func didSelectObject(object: AnyObject, new: Bool = false) {
        // nothing
    }
    
    public func canEditObject(object: AnyObject) -> Bool {
        return true
    }
    
    // MARK: - UITableViewController
    
    @IBAction public func add(sender: AnyObject?) {
        
        let object = self.createNewObject()
        self.prepareNewObject(object)
        
        if self.autoSelectAddedObjects {
            self.didSelectObject(object, new: true)
        }
        
        SGData.shared.save()
    }
    
    @IBAction public func edit(sender: AnyObject?) {
        self.tableView.setEditing(!self.tableView.editing, animated: true)
    }
    
    public override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchController.sections?.count ?? 0
    }
    
    public override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.headerHeight
    }
    
    public override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = self.fetchController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.name
    }
    
    public override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    public override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let object: AnyObject = self.fetchController.objectAtIndexPath(indexPath)
        let identifier = self.cellIdentifierForObject(object)
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as UITableViewCell
        self.configureCell(cell, withObject: object)
        return cell
    }
    
    public override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let object: AnyObject = self.fetchController.objectAtIndexPath(indexPath)
        self.didSelectObject(object)
    }
    
    public override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let object: AnyObject = self.fetchController.objectAtIndexPath(indexPath)
        return self.canEditObject(object)
    }
    
    public override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let object = self.fetchController.objectAtIndexPath(indexPath) as! NSManagedObject
            self.deleteObject(object)
        }
    }
    
    // MARK: - NSFetchedResultsController
    
    public var fetchController: NSFetchedResultsController {
        
        if self.fetchedResultsController != nil {
            return self.fetchedResultsController!
        }
        
        let request = NSFetchRequest(entityName: self.entityName)
        self.configureRequest(request)
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                           managedObjectContext: self.context!,
                                                             sectionNameKeyPath: self.sectionKey,
                                                                      cacheName: self.cacheName)
        self.fetchedResultsController?.delegate = self
        
        self.refreshData()
        
        return self.fetchedResultsController!
    }
    
    public func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    public func controller(controller: NSFetchedResultsController,
                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                    atIndex sectionIndex: Int,
                    forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
            
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            
            default:
                return
        }
    }
    
    public func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                    atIndexPath indexPath: NSIndexPath?,
                    forChangeType type: NSFetchedResultsChangeType,
                    newIndexPath: NSIndexPath?) {
        
        switch type {
            
            case .Insert:
                self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                self.pathToScrollTo = newIndexPath!
            
            case .Delete:
                self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            
            case .Update:
                if let cell = tableView.cellForRowAtIndexPath(indexPath!) {
                    self.configureCell(cell, withObject: anObject)
                }
            
            case .Move:
                self.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                self.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        self.tableView.endUpdates()
        
        if let path = self.pathToScrollTo {
            self.tableView.scrollToRowAtIndexPath(path, atScrollPosition: .Bottom, animated: true)
        }
        
        self.pathToScrollTo = nil
    }
    
    public var context: NSManagedObjectContext? {
        return SGData.shared.context
    }
    
    public func updateRequest() {
        NSFetchedResultsController.deleteCacheWithName(self.cacheName)
        self.configureRequest(self.fetchController.fetchRequest)
        self.refreshData()
    }
    
    public func configureRequest(request: NSFetchRequest) {
        request.predicate = self.fetchPredicate
        request.fetchBatchSize = self.fetchBatchSize
        request.sortDescriptors = self.sortDescriptors
    }
    
    public func refreshData() {
        do {
            try self.fetchController.performFetch()
        }
        catch let error as NSError {
            assert(false)
            print(error) // CJC: handle error better
        }
        self.tableView.reloadData()
    }
    
    public var fetchedResultsController: NSFetchedResultsController?
    public var pathToScrollTo: NSIndexPath?
    public var autoSelectAddedObjects = true
}
