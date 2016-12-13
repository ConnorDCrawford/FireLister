//
//  ListsCollectionViewController.swift
//  FireLister
//
//  Created by Connor Crawford on 10/13/16.
//  Copyright © 2016 Connor Crawford. All rights reserved.
//

import UIKit
import FirebaseDatabase

private let reuseIdentifier = "ListCell"

class ListsCollectionViewController: UICollectionViewController {

    private var isPaginated = false
    
    private var dataSource: FirebaseCollectionViewDataSource<List>?
    var userID: String? {
        didSet {
            if let userID = userID {
                let query = FIRDatabase.database().reference().child("lists").queryOrdered(byChild: "uid").queryEqual(toValue: userID)
                dataSource = FirebaseCollectionViewDataSource(query: query, sortDescriptors: nil, filterBlock: nil, prototypeReuseIdentifier: reuseIdentifier, collectionView: collectionView)
                dataSource?.populateCell(with: { (cell, model) in
                    // Configure the cell
                    let list = model
                    if let cell = cell as? ListCollectionViewCell {
                        cell.titleLabel.text = list.title
                        cell.backgroundColor = list.color
                        cell.layer.masksToBounds = true
                        cell.layer.cornerRadius = 10
                    }
                })
                collectionView?.dataSource = dataSource
            }
        }
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let listVC = segue.destination.childViewControllers.first as? ListTableViewController
        listVC?.isPaginated = isPaginated
        if let indexPath = collectionView?.indexPathsForSelectedItems?.first {
            listVC?.list = dataSource?.object(at: indexPath)
        }
        
        listVC?.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        listVC?.navigationItem.leftItemsSupplementBackButton = true
    }

    @IBAction func didLongPressCell(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: self.collectionView)
        if let indexPath = collectionView?.indexPathForItem(at: point),
            let cell = collectionView?.cellForItem(at: indexPath),
            let list = dataSource?.object(at: indexPath) {
            
            let alert = UIAlertController(title: "Delete \(list.title)", message: "Are you sure you want to delete the list \"\(list.title)\"?", preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                // Do nothing
            }
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                list.remove(nil)
            }
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            
            if let presenter = alert.popoverPresentationController {
                presenter.sourceView = cell
                presenter.sourceRect = cell.bounds
            }
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func switchPaginated(_ sender: UIBarButtonItem) {
        isPaginated = !isPaginated
        sender.title = isPaginated ? "Switch to Unpaginated" : "Switch to Paginated"
    }
    
}


