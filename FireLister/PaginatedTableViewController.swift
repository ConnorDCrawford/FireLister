//
//  PaginatedTableViewController.swift
//  FireLister
//
//  Created by Connor Crawford on 11/28/16.
//  Copyright © 2016 Connor Crawford. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PaginatedTableViewController: UITableViewController {

    var dataSource: PaginatedFirebaseTableViewDataSource<SnapshotModel>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let ref = FIRDatabase.database().reference().child("test")
        let query = ref.queryOrderedByKey()
        let a = PaginatedFirebaseArray<SnapshotModel>(query: query, sortOrderBlock: nil, filterBlock: nil, pageSize: 10, startValue: nil, endValue: nil)
        dataSource = PaginatedFirebaseTableViewDataSource<SnapshotModel>(array: a, reuseIdentifier: "cell", tableView: tableView)
        dataSource?.populateCell(with: { (cell, snap) in
            if let val = snap.value as? [String : Any] {
                let num = val["num"] as! Int
                cell.textLabel?.text = "\(num)"
            }
        })
        tableView.dataSource = dataSource
    }
    
}
