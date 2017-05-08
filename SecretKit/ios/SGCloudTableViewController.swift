//
//  SGCloudTableViewController.swift
//  SecretKit
//
//  Created by Colin Caufield on 2016-02-15.
//  Copyright © 2016 Secret Geometry, Inc. All rights reserved.
//

import UIKit
import CloudKit

open class SGCloudTableViewController: SGAbstractTableViewController {
    
    // MARK: - Properties
    
    open var objects = [CKRecord]()
    open var selectedIndex: Int!
    
    // MARK: - Lifecycle
    
    open override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.fetchObjects()
    }
    
    // MARK: - Objects
    
    open override func createNewObject() -> AnyObject {
        // IMPLEMENT CREATE
        return NSObject()
    }
    
    open override func objectAt(_ indexPath: IndexPath) -> AnyObject {
        assert(indexPath.section == 0)
        return self.objects[indexPath.row]
    }
    
    open override func allObjects() -> [AnyObject] {
        return self.objects
    }
    
    open override func deleteObject(_ object: AnyObject, at indexPath: IndexPath) {
        
        let selectedID = (object as! CKRecord).recordID
        
        CloudData.shared.deleteRecord(selectedID) { () -> Void in
            
            self.objects.remove(at: indexPath.row)
            self.tableView.reloadData()
            self.updateBarButtonStates()
        }
        
        self.saveObjects()
    }
    
    open override func fetchObjects() {
        
        CloudData.shared.fetchAllRecords(self.typeName) { (newObjects) -> Void in
            
            self.objects += newObjects
            
            OperationQueue.main.addOperation({ () -> Void in
                self.tableView.reloadData()
                self.updateBarButtonStates()
            })
        }
    }
    
    open override func saveObjects() {
        // IMPLEMENT SAVE
    }
    
    // MARK: - Cells
    
    open override func configureCell(_ cell: UITableViewCell, withObject object: AnyObject) {
        
        let name = object.value(forKey: "name") as? String
        let address = object.value(forKey: "address") as? String
        
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = address
    }
    
    // MARK: - UITableViewController
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
