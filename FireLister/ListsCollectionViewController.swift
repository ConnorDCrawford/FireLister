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

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let listVC = segue.destination.childViewControllers.first as? ListTableViewController
        let index = collectionView?.indexPathsForSelectedItems?.first?.row
        listVC?.list = lists?[index!]
        
        listVC?.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        listVC?.navigationItem.leftItemsSupplementBackButton = true
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
