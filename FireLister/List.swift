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
//    var reminders: FirebaseArray<Reminder>?
    var uid: String
    var title: String

    init(key: String, ref: FIRDatabaseReference, uid: String, title: String) {
        self.uid = uid
        self.key = key
        self.ref = ref
        self.title = title
        super.init()
//        reminders = FirebaseArray<Reminder>(query: FIRDatabase.database().reference().queryEqual(toValue: uid, childKey: "uid"))
    }
    
    /// Use this initializer only when creating a new record in the database
    convenience init(uid: String, title: String) {
        let ref = FIRDatabase.database().reference().child("lists").childByAutoId()
        let key = ref.key
        self.init(key: key, ref: ref, uid: uid, title: title)
    }
    
    required convenience init?(snapshot: FIRDataSnapshot) {
        // Check to make sure snapshot is valid
        guard let values = snapshot.value as? [String : Any],
            let uid = values["uid"] as? String,
            let title = values["title"] as? String else {
                // Does not contain necessary data, fail init
                return nil
        }
        
        self.init(key: snapshot.key, ref: snapshot.ref, uid: uid, title: title)
    }
    
    func push(_ completionHandler: ((Error?) -> Void)?) {
        let list: [String : Any] = [
            "uid" : uid,
            "title" : title
        ]
        
        ref.updateChildValues(list) { (error, _) in
            completionHandler?(error)
        }
    }
}
