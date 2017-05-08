//
//  SGFormatter.swift
//  SecretKit
//
//  Created by Colin Caufield on 4/21/15.
//  Copyright (c) 2015 Secret Geometry, Inc. All rights reserved.
//

import Foundation

private var lengthFormatter: DateComponentsFormatter? = nil
private var dateFormatter: DateFormatter? = nil
private var longDateFormatter: DateFormatter? = nil
private var dayFormatter: DateFormatter? = nil
private var monthFormatter: DateFormatter? = nil

open class SGFormatter: NSObject {
   
    open class func stringFromLength(_ length: Double) -> String {
        
        if lengthFormatter == nil {
            lengthFormatter = DateComponentsFormatter()
            lengthFormatter?.allowedUnits = ([.day, .hour, .minute, .second])
            lengthFormatter?.maximumUnitCount = 2
            lengthFormatter?.unitsStyle = .abbreviated
            lengthFormatter?.zeroFormattingBehavior = .dropAll
        }
        
        return lengthFormatter!.string(from: length) ?? ""
    }
    
    open class func clockStringFromDate(_ date: Date) -> String {
        
        if dateFormatter == nil {
            dateFormatter = DateFormatter()
            dateFormatter?.dateFormat = "hh:mm"
        }
        
        return dateFormatter!.string(from: date)
    }
    
    open class func dateStringFromDate(_ date: Date) -> String {
        
        if longDateFormatter == nil {
            longDateFormatter = DateFormatter()
            longDateFormatter?.dateStyle = .medium
            longDateFormatter?.timeStyle = .medium
        }
        
        return longDateFormatter!.string(from: date)
    }
    
    open class func dayStringFromDate(_ date: Date) -> String {
        
        if dayFormatter == nil {
            dayFormatter = DateFormatter()
            dayFormatter?.dateStyle = .long
            dayFormatter?.timeStyle = .none
            dayFormatter?.doesRelativeDateFormatting = true
        }
        
        return dayFormatter!.string(from: date)
    }
    
    open class func monthStringFromDate(_ date: Date) -> String {
        
        if monthFormatter == nil {
            monthFormatter = DateFormatter()
            monthFormatter?.dateFormat = "EEEE"
        }
        
        return monthFormatter!.string(from: date)
    }
}
