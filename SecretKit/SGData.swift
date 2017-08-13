//
//  Data.swift
//  SecretKit
//
//  Created by Colin Caufield on 4/1/15.
//  Copyright (c) 2015 Secret Geometry, Inc. All rights reserved.
//

import Foundation
import CoreData

#if os(iOS)
    import UIKit
#endif

private var _shared: SGData? = nil

public let CloudDataDidChangeNotification  = "CloudDataDidChangeNotification"

open class SGData: NSObject {
    
    open var name = "Data"
    open var useCloud = false
    
    open class var shared: SGData {
        if (_shared == nil) {
            _shared = SGData(name: "Data")
        }
        return _shared!
    }
    
    public init(name: String, useCloud: Bool = false) {
        super.init()
        assert(_shared == nil)
        _shared = self
        self.name = name
        self.useCloud = useCloud
        self.registerCloudStoreObserver(self)
        self.refreshProperties()
    }
    
    deinit {
        self.unregisterCloudStoreObserver(self)
    }
    
    open var center: NotificationCenter {
        return NotificationCenter.default
    }
    
    open func registerCloudStoreObserver(_ observer: AnyObject) {
        
        if !self.useCloud { return }
        
        self.center.addObserver(
            observer,
            selector: #selector(cloudStoreWillChange(_:)),
            name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange,
            object: self.persistentStoreCoordinator)
        
        self.center.addObserver(
            observer,
            selector: #selector(cloudStoreDidChange(_:)),
            name: NSNotification.Name.NSPersistentStoreCoordinatorStoresDidChange,
            object: self.persistentStoreCoordinator)
        
        self.center.addObserver(
            observer,
            selector: #selector(cloudStoreDidImport(_:)),
            name: NSNotification.Name.NSPersistentStoreDidImportUbiquitousContentChanges,
            object: self.persistentStoreCoordinator)
    }
    
    open func unregisterCloudStoreObserver(_ observer: AnyObject) {
        
        if !self.useCloud { return }
        
        self.center.removeObserver(
            observer,
            name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange,
            object: self.persistentStoreCoordinator)
        
        self.center.removeObserver(
            observer,
            name: NSNotification.Name.NSPersistentStoreCoordinatorStoresDidChange,
            object: self.persistentStoreCoordinator)
        
        self.center.removeObserver(
            observer,
            name: NSNotification.Name.NSPersistentStoreDidImportUbiquitousContentChanges,
            object: self.persistentStoreCoordinator)
    }
    
    open func registerCloudDataObserver(_ observer: AnyObject) {
        self.center.addObserver(
            observer,
            selector: #selector(cloudDataDidChange(_:)),
            name: NSNotification.Name(rawValue: CloudDataDidChangeNotification),
            object: nil)
    }
    
    open func unregisterCloudDataObserver(_ observer: AnyObject) {
        self.center.removeObserver(
            observer,
            name: NSNotification.Name(rawValue: CloudDataDidChangeNotification),
            object: nil)
    }
    
    open func cloudStoreWillChange(_ note: Notification) {
        
        print("Data.cloudStoreWillChange \(note)")
        //UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        if let context = self.context {
            context.performAndWait({
                if context.hasChanges {
                    self.save()
                } else {
                    context.reset()
                }
            })
        }
    }
    
    open func cloudStoreDidChange(_ note: Notification) {
        
        print("Data.cloudStoreDidChange \(note)")
        
        if let context = self.context {
            context.performAndWait({
                self.deduplicate()
                self.refreshProperties()
                self.center.post(name: Notification.Name(rawValue: CloudDataDidChangeNotification), object: nil)
            })
        }
        
        // CJC revisit: make other VC refreshes happen before reenabling interaction.
        //UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    open func cloudStoreDidImport(_ note: Notification) {
        
        print("Data.cloudStoreDidImport \(note)")
        
        if let context = self.context {
            context.performAndWait({
                context.mergeChanges(fromContextDidSave: note)
                self.deduplicate()
                self.refreshProperties()
                self.center.post(name: Notification.Name(rawValue: CloudDataDidChangeNotification), object: nil)
            })
        }
    }
    
    open func cloudDataDidChange(_ note: Notification) {
        // is this method needed?
    }

    open func insertNewObject(_ entityName: String) -> AnyObject {
        return NSEntityDescription.insertNewObject(forEntityName: entityName, into: self.context!)
    }
    
    open func uniqueDeviceString() -> String {
        
        #if os(iOS)
            let isPhone = (UIDevice.current.userInterfaceIdiom == .phone)
            let idiomName = isPhone ? "iPhone" : "iPad"
            let deviceID = UIDevice.current.identifierForVendor?.uuidString
            assert(deviceID != nil)
            return "\(idiomName) - \(String(describing: deviceID))"
        #else
            return "Unknown" // TODO: implement
        #endif
    }
    
    open func refreshProperties() {
        // empty
    }
    
    open func deduplicate() {
        // empty
    }
    
    open func save() {
        
        print("*** SAVING")
        
        if let context = self.context {
            if context.hasChanges {
                context.performAndWait({
                    do {
                        try context.save()
                    }
                    catch let error as NSError {
                        // CJC: Replace this with something shipable.
                        NSLog("Unresolved error \(error), \(error.userInfo)")
                        //abort()
                    }
                    catch {
                        // CJC: Replace this with something shipable.
                        NSLog("Unknown")
                        //abort()
                    }
                })
            }
        }
            
        print("*** SAVED")
    }
    
    open func fetchRequest(_ entityName: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = []) -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return request
    }
    
    open func fetchObject(_ request: NSFetchRequest<NSFetchRequestResult>) -> AnyObject? {
        return self.fetchObjects(request).first
    }
    
    open func fetchObject(_ entityName: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = []) -> AnyObject? {
        let request = self.fetchRequest(entityName, predicate: predicate, sortDescriptors: sortDescriptors)
        return self.fetchObject(request)
    }
    
    open func fetchObject(_ entityName: String, name: String, predicate: NSPredicate? = nil) -> AnyObject? {
        let namePredicate = NSPredicate(format: "(name = %@)", name)
        let predicate = self.andPredicates([namePredicate, predicate])
        let request = self.fetchRequest(entityName, predicate: predicate)
        return self.fetchObject(request)
    }
    
    open func fetchObjects(_ request: NSFetchRequest<NSFetchRequestResult>) -> [AnyObject] {
        let objects: [AnyObject]?
        do {
            objects = try self.context!.fetch(request)
        }
        catch let error as NSError {
            objects = nil
            assert(false)
            print(error) // CJC: handle error better
        }
        return objects ?? []
    }
    
    open func fetchObjects(_ entityName: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = []) -> [AnyObject] {
        let request = self.fetchRequest(entityName, predicate: predicate, sortDescriptors: sortDescriptors)
        return self.fetchObjects(request)
    }
    
    open func nextAvailableName(_ desiredName: String, entityName: String, predicate: NSPredicate? = nil) -> String {
        
        var name = ""
        var index = 1
        var existingObject: AnyObject? = nil
        
        repeat {
            let suffix = (index == 1) ? "" : " " + String(index)
            name = desiredName + suffix
            existingObject = self.fetchObject(entityName, name: name, predicate: predicate) as AnyObject?
            index += 1
        }
        while existingObject != nil
        
        return name
    }
    
    open func nullablePredicate(_ name: String, object: AnyObject?) -> NSPredicate {
        if object != nil {
            let format = "\(name) = %@"
            return NSPredicate(format: format, argumentArray: [object!])
        } else {
            let format = "\(name) = nil"
            return NSPredicate(format: format)
        }
    }
    
    open func booleanPredicate(_ name: String, value: Bool) -> NSPredicate {
        if value {
            let format = "\(name) = true"
            return NSPredicate(format: format)
        } else {
            let format = "\(name) = false"
            return NSPredicate(format: format)
        }
    }
    
    open func andPredicates(_ predicates: [NSPredicate?]) -> NSPredicate {
        
        var finalPredicate: NSPredicate?
        for possiblePredicate in predicates {
            if let predicate = possiblePredicate {
                if finalPredicate == nil {
                    finalPredicate = predicate
                } else {
                    finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [finalPredicate!, predicate])
                }
            }
        }
        
        assert(finalPredicate != nil)
        return finalPredicate!
    }
    
    open lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1] as URL
    }()
    
    open lazy var cloudDirectory: URL? = {
        return FileManager.default.url(forUbiquityContainerIdentifier: nil)
    }()
    
    open lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: self.name, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)
    }()
    
    open lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let filename = self.name + ".sqlite"
        let url = self.applicationDocumentsDirectory.appendingPathComponent(filename)
        
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        var options = [AnyHashable: Any]()
        
        options = [
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        
        if self.useCloud {
            if let cloudDir = self.cloudDirectory {
                options[NSPersistentStoreUbiquitousContentNameKey] = self.name
            }
        }
        
        let store: NSPersistentStore?
        do {
            store = try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch {
            fatalError() // CJC: handle error better
        }
        
        if store == nil {
            
            coordinator = nil
            
            // Report any error.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            
            // CJC: Replace this with something shipable.
            NSLog("Unresolved error \(String(describing: error)), \(error!.userInfo)")
            abort()
        }
        
        print("Persistent store url is \(String(describing: store!.url))")
        
        return coordinator
    }()
    
    open lazy var context: NSManagedObjectContext? = {
        
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        
        var context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        return context
    }()
}
