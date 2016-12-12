//
//  ListTableViewController.swift
//  FireLister
//
//  Created by Connor Crawford on 10/8/16.
//  Copyright © 2016 Connor Crawford. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ListTableViewController: UITableViewController {

    private let predicate = NSPredicate(format: "completed == FALSE")
    var isPaginated = false
    
    var list: List? {
        didSet {
            guard let list = list else { return }
            
            // Configure reminders FirebaseArray
            let ref = FIRDatabase.database().reference().child("reminders").child(list.key)
            let query = ref.queryOrderedByKey()
            
            if isPaginated {
                remindersDataSource = PaginatedFirebaseTableViewDataSource(query: query,
                                                                           sortKey: nil,
                                                                           pageSize: 10,
                                                                           startValue: nil,
                                                                           sortDescriptors: nil,
                                                                           predicate: predicate, prototypeReuseIdentifier: "ReminderCell",
                                                                           tableView: tableView)
                
            } else {
                remindersDataSource = FirebaseTableViewDataSource(query: query,
                                                                  sortDescriptors: nil,
                                                                  predicate: predicate, prototypeReuseIdentifier: "ReminderCell",
                                                                  tableView: tableView)
            }
            
            remindersDataSource?.populateCell { (cell, reminder) in
                let cell = cell as! ReminderTableViewCell
                cell.reminder = reminder
                cell.titleField.text = reminder.text
                
                var detailText = reminder.alarmDate?.datetimeToString()
                if reminder.repeatFrequency != .never {
                    detailText = detailText! + (", " + reminder.repeatFrequencyDescription)
                }
                cell.dateLabel.text = detailText
                
                let frame = CGRect(x: 0, y: 0, width: 22, height: 22)
                let emptyImage = ColorCircleView.image(in: frame, state: .empty, color: self.list!.color)
                let selectedImage = ColorCircleView.image(in: frame, state: .selected, color: self.list!.color)
                cell.completedButton.setImage(emptyImage, for: .normal)
                cell.completedButton.setImage(selectedImage, for: .selected)
                cell.completedButton.setImage(selectedImage, for: .highlighted)
                cell.completedButton.isSelected = reminder.isCompleted
            }
            
            // Set view controller's title
            navigationItem.title = list.title
        }
    }
    var detailViewController: ReminderDetailTableViewController? = nil
    var remindersDataSource: FirebaseTableViewDataSource<Reminder>?
    fileprivate var newReminderText: String?
    fileprivate var newReminderTextField: UITextField?
    private var isShowingCompleted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.list != nil {
            navigationItem.rightBarButtonItem = self.editButtonItem
            navigationController?.isToolbarHidden = false
        }
        
        // Set row height to automatic dimension
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController?.isCollapsed ?? true
        super.viewWillAppear(animated)
    }
    
    func insertNewObject(_ sender: Any) {
        // TODO: Get reminder data from textfield
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let reminder = sender as? Reminder {
                let controller = segue.destination as! ReminderDetailTableViewController
                controller.reminder = reminder
            }
        }
    }

    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return remindersDataSource?.numberOfSections(in: tableView) ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return remindersDataSource?.tableView(tableView, numberOfRowsInSection: section) ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return remindersDataSource?.tableView(tableView, cellForRowAt: indexPath) ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // TODO: Handle remove
            let reminder = remindersDataSource?.object(at: indexPath)
            reminder?.remove(nil)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath.row != remindersDataSource?.count {
            let reminder = remindersDataSource?.object(at: indexPath)
            performSegue(withIdentifier: "showDetail", sender: reminder)
        }
    }
    
    func addReminder(title: String) {
        if let listID = list?.key {
            let reminder = Reminder(listID: listID, text: title, alarmDate: nil, repeatFrequency: .never)
            reminder.push(nil)
        }
    }
    
    @IBAction func didPressAdd(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Add Reminder", message: nil, preferredStyle: .alert)
        let titleAction = UIAlertAction(title: "Add", style: .default, handler: { _ in
            let titleTextField = alertController.textFields![0] as UITextField
            if let text = titleTextField.text {
                self.addReminder(title: text)
            }}
        )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Reminder title"
        }
        
        alertController.addAction(titleAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    @IBAction func didPressShowCompleted(_ sender: UIBarButtonItem) {
        isShowingCompleted = !isShowingCompleted
        if isShowingCompleted {
            remindersDataSource?.array.setFilter(with: nil)
            sender.title = "Hide Completed"
        } else {
            remindersDataSource?.array.setFilter(with: predicate)
            sender.title = "Show Completed"
        }
    }
    
}

extension ListTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.characters.count > 0 {
            if let reminderCell = textField.superview?.superview as? ReminderTableViewCell, let indexPath = tableView.indexPath(for: reminderCell) {
                let reminder = remindersDataSource?.object(at: indexPath)
                reminder?.text = textField.text
                reminder?.push(nil)
                textField.resignFirstResponder()
            }
            return true
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        newReminderTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        newReminderText = textField.text
    }
    
}
