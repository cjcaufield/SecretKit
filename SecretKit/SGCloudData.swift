//
//  SGCloudData.swift
//  SecretKit
//
//  Created by Colin Caufield on 2016-02-15.
//  Copyright © 2016 Secret Geometry, Inc. All rights reserved.
//

import CloudKit

open class CloudData: NSObject {

    // MARK: - Properties
    
    open static var singleton: CloudData?
    
    open static var shared: CloudData {
        
        if singleton == nil {
            singleton = CloudData()
        }
        
        return singleton!
    }
    
    open var shouldLog = true

    open var container: CKContainer {
        return CKContainer.default()
    }
    
    open var db: CKDatabase {
        return self.container.publicCloudDatabase
    }
    
    // MARK: - Lifecycle
    
    public override init() {
        super.init()
        self.checkDB()
    }
    
    // MARK: - Queries
    
    open func checkDB() {
        
        self.container.accountStatus( completionHandler: { status, error in
            
            if let description = error?.localizedDescription {
                print("Error = \(description)")
                return
            }
            
            print("Account status: ", terminator: "")
            
            switch status.hashValue {
            case 0:
                print("CouldNotDetermine")
            case 1:
                print("Available")
            case 2:
                print("Restricted")
            case 3:
                print("NoAccount")
            default:
                print("Unknown")
            }
        })
    }
    
    open func addRecord(_ recordType: String, name: String) {
        
        let recordID = CKRecordID(recordName: name)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        self.db.save(record, completionHandler: { savedRecord, error in
            
            if let nserror = (error as NSError?) {
                
                print("Failed to save record: \(name).")
                print("ERROR: \(nserror.localizedDescription)")

                if let delay = nserror.userInfo[CKErrorRetryAfterKey] as? TimeInterval {
                    
                    //let date = NSDate(timeIntervalSinceNow: delay)
                    print("Should try again in \(delay) seconds.")
                }
            }
        })
    }
    
    open func fetchRecord(_ name: String) {
        
        let recordID = CKRecordID(recordName: name)
        
        self.db.fetch(withRecordID: recordID) { fetchedRecord, error in
            
            if fetchedRecord == nil {
                
                print("Failed to fetch record: \(name).")
                
                if let error = error {
                    print("ERROR: \(error.localizedDescription)")
                }
            }
        }
    }
    
    open func fetchAllRecords(_ recordType: String, block: @escaping ([CKRecord]) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        self.db.perform(query, inZoneWith: nil) { (results, error) -> Void in
            
            if let error = error {
                print("Failed to fetch records.")
                print("ERROR: \(error.localizedDescription)")
                return
            }
            
            guard let newObjects = results , newObjects.count > 0 else {
                return
            }
            
            block(newObjects)
        }
    }
    
    open func deleteRecord(_ recordID: CKRecordID, block: @escaping () -> Void) {
        
        self.db.delete(withRecordID: recordID, completionHandler: { (recordID, error) -> Void in
            
            if let nserror = (error as NSError?) {
                print("Failed to delete record with id " + String(describing: recordID) + ".")
                print("ERROR: \(nserror.localizedDescription)")
                return
            }
            
            block()
        })
    }
    
    open func searchRecords(_ recordType: String, searchString: String) {
        
        let predicate = NSPredicate(format: "name CONTAINS '\(searchString)'")
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        self.db.perform(query, inZoneWith: nil) { results, error in
            
            // Do stuff.
        }
    }
    
    open func watchRecords(_ searchString: String) {
        
        let predicate = NSPredicate(format: "description CONTAINS '\(searchString)'")
        
        let subscription = CKQuerySubscription(recordType: "Checkin", predicate: predicate, options: .firesOnRecordCreation)
        
        let info = CKNotificationInfo()
        info.alertLocalizationKey = "NEW_PLACE_ALERT_KEY"
        info.soundName = "NewAlert.aiff"
        info.shouldBadge = true
        
        subscription.notificationInfo = info
        
        self.db.save(subscription, completionHandler: { subscription, error in
            
            // Do stuff.
        }) 
    }
    
    open func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        
        let note = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
        
        if note.notificationType == .query, let queryNote = note as? CKQueryNotification {
        
            let _ = queryNote.recordID
            
            // Do stuff.
        }
    }
}
