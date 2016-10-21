//
//  List.swift
//  FireLister
//
//  Created by Connor Crawford on 10/13/16.
//  Copyright © 2016 Connor Crawford. All rights reserved.
//

import UIKit
import FirebaseDatabase

class List: NSObject, FirebaseModel {
    
    var key: String
    var ref: FIRDatabaseReference
    var uid: String
    var title: String {
        get {
            return key
        }
    }
    var color: UIColor

    init(key: String, ref: FIRDatabaseReference, uid: String, color: UIColor) {
        self.uid = uid
        self.key = key
        self.ref = ref
        self.color = color
        super.init()
    }
    
    /// Use this initializer only when creating a new record in the database
    convenience init(uid: String, title: String, color: UIColor) {
        let ref = FIRDatabase.database().reference().child("lists").child(title)
        let key = ref.key
        self.init(key: key, ref: ref, uid: uid, color: color)
    }
    
    required convenience init?(snapshot: FIRDataSnapshot) {
        // Check to make sure snapshot is valid
        guard let values = snapshot.value as? [String : Any],
            let uid = values["uid"] as? String,
            let red = values["red"] as? Float,
            let green = values["green"] as? Float,
            let blue  = values["blue"] as? Float
            else {
                // Does not contain necessary data, fail init
                return nil
        }
        
        let color = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
        self.init(key: snapshot.key, ref: snapshot.ref, uid: uid, color: color)
    }
    
    func push(_ completionHandler: ((Error?) -> Void)?) {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: nil)
        let list: [String : Any] = [
            "uid" : uid,
            "red" : red,
            "green" : green,
            "blue" : blue
        ]
        
        ref.updateChildValues(list) { (error, _) in
            completionHandler?(error)
        }
    }
    
    func remove(_ completionHandler: ((Error?)->Void)?) {
        
        // Delete all reminders associated with list
        let query = FIRDatabase.database().reference().child("reminders").queryOrdered(byChild: "lid").queryEqual(toValue: key)
        query.observe(.value) { (snapshot: FIRDataSnapshot) in
            for child in snapshot.children.allObjects {
                let childSnapshot = child as! FIRDataSnapshot
                childSnapshot.ref.removeValue()
            }
        }
        
        ref.removeValue { (error, _) in
            completionHandler?(error)
        }
    }
}
