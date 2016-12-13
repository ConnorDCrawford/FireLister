//
//  CreateListTableViewController.swift
//  FireLister
//
//  Created by Connor Crawford on 10/13/16.
//  Copyright © 2016 Connor Crawford. All rights reserved.
//

import UIKit

class CreateListTableViewController: UITableViewController {

    @IBOutlet weak var colorsCollectionView: UICollectionView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    private var titleText: String?
    fileprivate var color: ColorCircleView.Color?
    var selectedColorIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        doneButton.isEnabled = false
        color = ColorCircleView.Color.color(at: selectedColorIndex)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
    }

    @IBAction func editingDidChange(_ sender: UITextField) {
        doneButton.isEnabled = sender.text!.characters.count > 0
        titleText = sender.text
    }
    
    @IBAction func didPressCancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func didPressDone(_ sender: AnyObject) {
        if let userID = userID, let titleText = titleText, let color = color {
            let list = List(uid: userID, title: titleText, color: color.value)
            list.push(nil)
            dismiss(animated: true, completion: nil)
        }
    }

}

extension CreateListTableViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ColorCircleView.Color.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath)
        
        if let cell = cell as? ColorCircleCollectionViewCell {
            cell.colorCircleView.color = ColorCircleView.Color.color(at: indexPath.row)
            cell.colorCircleView.state = (indexPath.row == selectedColorIndex ? .selected : .filled)
            cell.colorCircleView.setNeedsDisplay()
        }
        
        return cell
    }
    
}

extension CreateListTableViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let oldSelection = selectedColorIndex
        let newSelection = indexPath.row
        
        if oldSelection == newSelection {
            return
        }
        
        selectedColorIndex = newSelection
        color = ColorCircleView.Color.color(at: indexPath.row)
        
        collectionView.reloadItems(at: [indexPath, IndexPath(item: oldSelection, section: 0)])
    }
    
}
