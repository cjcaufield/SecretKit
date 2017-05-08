//
//  SGCoreDataTableViewController.swift
//  SecretKit
//
//  Created by Colin Caufield on 4/1/15.
//  Copyright (c) 2015 Secret Geometry, Inc. All rights reserved.
//

import UIKit
import CoreData

open class SGCoreDataTableViewController: SGAbstractTableViewController, NSFetchedResultsControllerDelegate {

    // MARK: - Properties
    
    open var context: NSManagedObjectContext { return SGData.shared.context! }
    
    open var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    open var fetchPredicate: NSPredicate? { return nil }
    
    open var fetchBatchSize: Int { return 20 }
    
    open var sortDescriptors: [NSSortDescriptor] { return [] }
    
    open var sectionKey: String? { return nil }
    
    open var cacheName: String? { return nil }
    
    // MARK: - Core Data methods to override.
    
    open override func createNewObject() -> AnyObject {
        return NSEntityDescription.insertNewObject(forEntityName: self.typeName, into: self.context) as NSManagedObject
    }
    
    open override func objectAt(_ indexPath: IndexPath) -> AnyObject {
        return self.fetchController.object(at: indexPath)
    }
    
    open override func allObjects() -> [AnyObject] {
        return self.fetchController.fetchedObjects ?? []
    }
    
    open override func fetchObjects() {
        self.refreshData()
    }
    
    open override func deleteObject(_ object: AnyObject, at indexPath: IndexPath) {
        self.context.delete(object as! NSManagedObject)
        self.saveObjects()
    }
    
    open override func saveObjects() {
        SGData.shared.save()
    }
    
    // MARK: - Cell methods to override.
    
    open override func configureCell(_ cell: UITableViewCell, withObject object: AnyObject) {
        let name = object.value(forKey: "name") as? String
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = ""
    }
    
    // MARK: - UITableViewController
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return self.fetchController.sections?.count ?? 0
    }
    
    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = self.fetchController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.name
    }
    
    // MARK: - NSFetchedResultsController
    
    open var fetchController: NSFetchedResultsController<NSFetchRequestResult> {
        
        if let it = self.fetchedResultsController {
            return it
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: self.typeName)
        self.configureRequest(request)
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                           managedObjectContext: self.context,
                                                             sectionNameKeyPath: self.sectionKey,
                                                                      cacheName: self.cacheName)
        self.fetchedResultsController?.delegate = self
        
        self.refreshData()
        
        return self.fetchedResultsController!
    }
    
    open func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        if (self.ignoreModelChanges) {
            return
        }
        
        self.tableView.beginUpdates()
    }
    
    open func controller(controller: NSFetchedResultsController<NSFetchRequestResult>,
                         didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                         atIndex sectionIndex: Int,
                         forChangeType type: NSFetchedResultsChangeType) {
        
        if (self.ignoreModelChanges) {
            return
        }
        
        switch type {
            
            case .insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
            
            case .delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .fade)
            
            default:
                return
        }
    }
    
    open func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                           didChange anObject: Any,
                           at indexPath: IndexPath?,
                           for type: NSFetchedResultsChangeType,
                           newIndexPath: IndexPath?) {
        
        if (self.ignoreModelChanges) {
            return
        }
        
        switch type {
            
            case .insert:
                self.tableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
                self.pathToScrollTo = newIndexPath!
                self.updateBarButtonStates()
            
            case .delete:
                self.tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
                self.updateBarButtonStates()
            
            case .update:
                if let cell = tableView.cellForRow(at: indexPath! as IndexPath) {
                    self.configureCell(cell, withObject: anObject as AnyObject)
                }
            
            case .move:
                self.tableView.deleteRows(at: [indexPath! as IndexPath], with: .fade)
                self.tableView.insertRows(at: [newIndexPath! as IndexPath], with: .fade)
        }
    }
    
    open func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        if (self.ignoreModelChanges) {
            return
        }
        
        self.tableView.endUpdates()
        
        if let path = self.pathToScrollTo {
            self.tableView.scrollToRow(at: path as IndexPath, at: .bottom, animated: true)
        }
        
        self.pathToScrollTo = nil
    }
    
    open func updateRequest() {
        NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: self.cacheName)
        self.configureRequest(self.fetchController.fetchRequest)
        self.refreshData()
    }
    
    open func configureRequest(_ request: NSFetchRequest<NSFetchRequestResult>) {
        request.predicate = self.fetchPredicate
        request.fetchBatchSize = self.fetchBatchSize
        request.sortDescriptors = self.sortDescriptors
    }
    
    open func refreshData() {
        
        do {
            try self.fetchController.performFetch()
        }
        catch {
            print(error) // CJC: handle error better
            assert(false)
        }
        
        self.tableView.reloadData()
        self.updateBarButtonStates()
    }
}
