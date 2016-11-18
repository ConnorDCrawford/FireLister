//
//  PaginatedFirebaseTableViewDataSource.swift
//  FireLister
//
//  Created by Connor Crawford on 11/17/16.
//  Copyright © 2016 Connor Crawford. All rights reserved.
//

import UIKit

class PaginatedFirebaseTableViewDataSource<T : FirebaseModel>: FirebaseTableViewDataSource<T> {
    
    var paginatedArray: PaginatedFirebaseArray<T>
    override var array: FirebaseArray<T> {
        get {
            return paginatedArray
        } set {
            assert(array is PaginatedFirebaseArray)
            if let array = array as? PaginatedFirebaseArray {
                paginatedArray = array
            }
        }
    }
    
    init(array: PaginatedFirebaseArray<T>, reuseIdentifier: String, tableView: UITableView?) {
        self.paginatedArray = array
        super.init(array: array, reuseIdentifier: reuseIdentifier, tableView: tableView)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Check if the object is the last element of the last page
        if let object = object(at: indexPath) {
            if object == paginatedArray.lastLoadedObject {
                paginatedArray.loadNextPage()
            }
        }
        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }

}
