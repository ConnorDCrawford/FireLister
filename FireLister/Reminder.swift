//
//  Reminder.swift
//  FireLister
//
//  Created by Connor Crawford on 10/9/16.
//  Copyright © 2016 Connor Crawford. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Reminder: NSObject, FirebaseModel {
    
    enum Keys: String {
        case text = "text", alarmDate = "date", repeatFrequency = "freq", listID = "lid", isCompleted = "complete"
    }
    
    enum RepeatFrequency: Int {
        case never = 0, daily = 1, weekly = 2, biweekly = 3, monthly = 4, yearly = 5
    }
    
    static var typeRef = FIRDatabase.database().reference().child("reminders")
    var key: String
    var ref: FIRDatabaseReference
    var text: String!
    var alarmDate: Date?
    var repeatFrequency: RepeatFrequency
    var listID: String
    var isCompleted: Bool = false
    
    init(key: String, ref: FIRDatabaseReference, listID: String, text: String, alarmDate: Date?, repeatFrequency: RepeatFrequency, isCompleted: Bool) {
        self.key = key
        self.ref = ref
        self.listID = listID
        self.repeatFrequency = repeatFrequency
        super.init()
        self.text = text
        self.alarmDate = alarmDate
        self.isCompleted = isCompleted
    }
    
    /// Use this initializer only when creating a new record in the database
    convenience init(listID: String, text: String, alarmDate: Date?, repeatFrequency: RepeatFrequency) {
        let ref = Reminder.typeRef.child(listID).childByAutoId()
        let key = ref.key
        self.init(key: key, ref: ref, listID: listID, text: text, alarmDate: alarmDate, repeatFrequency: repeatFrequency, isCompleted: false)
    }
    
    required convenience init?(snapshot: FIRDataSnapshot) {
        // Check to make sure snapshot is valid
        guard let values = snapshot.value as? [String : Any],
            let listID = values[Keys.listID.rawValue] as? String,
            let text = values[Keys.text.rawValue] as? String,
            let isCompleted = values[Keys.isCompleted.rawValue] as? Bool else {
            // Does not contain necessary data, fail init
            return nil
        }
        
        // Init optional variables
        let alarmDate = (values[Keys.alarmDate.rawValue] as? String)?.toDate()
        let repeatFrequency = values[Keys.repeatFrequency.rawValue] as? Int
        
        self.init(key: snapshot.key, ref: snapshot.ref, listID: listID, text: text, alarmDate: alarmDate, repeatFrequency: RepeatFrequency(rawValue: repeatFrequency!)!, isCompleted: isCompleted)
    }
    
    func push(_ completionHandler: ((Error?)->Void)?) {
        
        var reminder: [String : Any] = [Keys.text.rawValue : text,
                                        Keys.repeatFrequency.rawValue : repeatFrequency.rawValue,
                                        Keys.listID.rawValue : listID,
                                        Keys.isCompleted.rawValue : isCompleted]
        
        if let alarmDate = alarmDate {
            reminder[Keys.alarmDate.rawValue] = alarmDate.datetimeToString()
        } else {
            ref.child(Keys.alarmDate.rawValue).removeValue()
        }
        
        // Push updates
        ref.updateChildValues(reminder) { (error, dbRef) in
            completionHandler?(error)
        }
    }
    
    func remove(_ completionHandler: ((Error?)->Void)?) {
        ref.removeValue { (error, _) in
            completionHandler?(error)
        }
    }
    
    var repeatFrequencyDescription: String {
        get {
            var text: String
            switch repeatFrequency {
            case .never: text = "Never"
            case .daily: text = "Every Day"
            case .weekly: text = "Every Week"
            case .biweekly: text = "Every 2 Weeks"
            case .monthly: text = "Every Month"
            case .yearly: text = "Every Year"
            }
            return text
        }
    }
    
}

extension String {
    
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.date(from: self)
    }
    
}

extension Date {
    
    func datetimeToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self)
    }
    
}
