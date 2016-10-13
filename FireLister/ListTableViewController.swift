//
//  ListTableViewController.swift
//  FireLister
//
//  Created by Connor Crawford on 10/8/16.
//  Copyright © 2016 Connor Crawford. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {

    var detailViewController: ReminderDetailTableViewController? = nil
    var remindersDataSource: FirebaseTableViewDataSource<Reminder>!
    fileprivate var newReminderText: String?
    fileprivate var newReminderTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // Set row height to automatic dimension
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        // Configure reminders FirebaseArray
        remindersDataSource = FirebaseTableViewDataSource(query: Reminder.typeRef, sortDescriptors: nil, predicate: nil, prototypeReuseIdentifier: "ReminderCell", tableView: tableView)
        remindersDataSource.populateCell { (cell, reminder) in
            let cell = cell as! ReminderTableViewCell
            cell.titleField.text = reminder.text
            
            var detailText = reminder.alarmDate?.datetimeToString()
            if reminder.repeatFrequency != .never {
                detailText = detailText! + (", " + reminder.repeatFrequencyDescription)
            }
            cell.dateLabel.text = detailText
        }
        
        // Get detail view controller
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? ReminderDetailTableViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
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
                let controller = (segue.destination as! UINavigationController).topViewController as! ReminderDetailTableViewController
                controller.reminder = reminder
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return remindersDataSource.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isLastCell = indexPath.row == remindersDataSource.count
        
        // Normal reminder cell, so use remindersDataSource
        if !isLastCell {
            return remindersDataSource.tableView(tableView, cellForRowAt: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddReminderCell", for: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Cannot edit last row
        return indexPath.row != remindersDataSource.count
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // TODO: Handle remove
            let reminder = remindersDataSource.object(at: indexPath)
            reminder?.remove(nil)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath.row != remindersDataSource.count {
            let reminder = remindersDataSource.object(at: indexPath)
            performSegue(withIdentifier: "showDetail", sender: reminder)
        }
    }

    func addReminder() {
        newReminderTextField?.resignFirstResponder()
        newReminderText = newReminderTextField?.text
        newReminderTextField?.text = nil
        
        if let text = newReminderText {
            let reminder = Reminder(text: text, alarmDate: nil, repeatFrequency: .never)
            reminder.push(nil)
        }
    }
    
    @IBAction func didPressAdd(_ sender: UIButton) {
        addReminder()
    }

}

extension ListTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.characters.count > 0 {
            if let reminderCell = textField.superview?.superview as? ReminderTableViewCell, let indexPath = tableView.indexPath(for: reminderCell) {
                let reminder = remindersDataSource.object(at: indexPath)
                reminder?.text = textField.text
                reminder?.push(nil)
                textField.resignFirstResponder()
            } else if textField.superview?.superview is AddReminderTableViewCell {
                addReminder()
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
