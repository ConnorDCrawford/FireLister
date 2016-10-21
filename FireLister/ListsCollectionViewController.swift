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

    private var lists: FirebaseArray<List>?
    var userID: String? {
        didSet {
            if let userID = userID {
                let query = FIRDatabase.database().reference().child("lists").queryOrdered(byChild: "uid").queryEqual(toValue: userID) //queryEqual(toValue: userID, childKey: "uid")
                lists = FirebaseArray<List>(query: query)
                lists?.delegate = self
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return lists == nil ? 0 : 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return lists?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
        if let cell = cell as? ListCollectionViewCell, let list = lists?[indexPath.row] {
            cell.titleLabel.text = list.title
            cell.backgroundColor = list.color
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 10
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let listVC = segue.destination.childViewControllers.first as? ListTableViewController
        let index = collectionView?.indexPathsForSelectedItems?.first?.row
        listVC?.list = lists?[index!]
        
        listVC?.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        listVC?.navigationItem.leftItemsSupplementBackButton = true
    }

    @IBAction func didLongPressCell(_ sender: UILongPressGestureRecognizer) {
        let point = sender.location(in: self.collectionView)
        if let indexPath = collectionView?.indexPathForItem(at: point),
            let cell = collectionView?.cellForItem(at: indexPath),
            let list = lists?[indexPath.row] {
            
            let alert = UIAlertController(title: "Delete \(list.key)", message: "Are you sure you want to delete the list \"\(list.key)\"?", preferredStyle: .actionSheet)
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
}

extension ListsCollectionViewController: FirebaseArrayDelegate {
    
    func initialized(objects: [FirebaseModel]) {
        collectionView?.reloadData()
    }
    
    func childAdded(object: FirebaseModel, at index: Int) {
        collectionView?.insertItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func childRemoved(object: FirebaseModel, at index: Int) {
        collectionView?.deleteItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func childChanged(object: FirebaseModel, at index: Int) {
        collectionView?.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func childMoved(object: FirebaseModel, from oldIndex: Int, to newIndex: Int) {
        collectionView?.moveItem(at: IndexPath(item: oldIndex, section: 0), to: IndexPath(item: newIndex, section: 0))
    }
    
}
