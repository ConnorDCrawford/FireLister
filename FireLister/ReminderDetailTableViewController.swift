//
//  ReminderDetailTableViewController.swift
//  FireLister
//
//  Created by Connor Crawford on 10/10/16.
//  Copyright © 2016 Connor Crawford. All rights reserved.
//

import UIKit
import SwiftLCS

class ReminderDetailTableViewController: UITableViewController {

    private enum CellType: String {
        case title = "TitleCell"
        case triggerAlarm = "TriggerAlarmCell"
        case alarm = "AlarmCell"
        case datepicker = "DatePickerCell"
        case triggerRepeat = "TriggerRepeatCell"
    }
    
    private typealias Row = Int
    private typealias TableState = [[CellType]]
    
    private let emptyState: TableState = []
    
    private let defaultState: TableState = [
        [.title],
        [.triggerAlarm]
    ]
    
    private let alarmState: TableState = [
        [.title],
        [
            .triggerAlarm,
            .alarm,
            .triggerRepeat
        ]
    ]
    
    private let pickAlarmDateState: TableState = [
        [.title],
        [
            .triggerAlarm,
            .alarm,
            .datepicker,
            .triggerRepeat
        ]
    ]
    
    var reminder: Reminder? {
        didSet {
            if let alarmDate = reminder?.alarmDate {
                self.alarmDate = alarmDate
                transition(to: alarmState)
            } else {
                transition(to: defaultState)
            }
        }
    }
    private var currentState: TableState!
    private var titleTextField: UITextField?
    private var alarmDateLabel: UILabel?
    fileprivate var repeatFrequencyLabel: UILabel?
    private var alarmDate: Date? {
        didSet {
            if let alarmDate = alarmDate {
                reminder?.alarmDate = alarmDate
                reminder?.push(nil)
            }
        }
    }
    
    private func transition(to newState: TableState) {
        // Set current state to new state
        let currentState = self.currentState ?? emptyState
        self.currentState = newState
        
        // Iterate over each section in the new state
        var addedIndexPaths = [IndexPath]()
        var removedIndexPaths = [IndexPath]()
        for section in 0 ..< currentState.count {
            // Determine added and removed indices
            let difference = currentState[section].diff(newState[section])
            for index in difference.addedIndexes {
                addedIndexPaths.append(IndexPath(row: index, section: section))
            }
            for index in difference.removedIndexes {
                removedIndexPaths.append(IndexPath(row: index, section: section))
            }
        }
        
        // Determine added and removed sections
        var addedSections = IndexSet()
        var removedSections = IndexSet()
        for section in 0...abs(newState.count - currentState.count) {
            if newState.count > currentState.count {
                addedSections.insert(section)
            } else if newState.count < currentState.count {
                removedSections.insert(section)
            }
        }
        
        // Animate changes
        tableView.beginUpdates()
        tableView.insertRows(at: addedIndexPaths, with: .fade)
        tableView.deleteRows(at: removedIndexPaths, with: .fade)
        tableView.insertSections(addedSections, with: .fade)
        tableView.deleteSections(removedSections, with: .fade)
        tableView.endUpdates()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set height to automatic dimensions
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        // Create touch recognizer to dismiss keyboard
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReminderDetailTableViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return currentState.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentState[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = currentState[indexPath.section][indexPath.row]
        let reuseIdentifier = type.rawValue
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        // Configure the cell...
        
        if type == .title {
            let cell = cell as? TextFieldTableViewCell
            titleTextField = cell?.textField
            titleTextField?.text = reminder?.text
        }
        
        if type == .alarm {
            alarmDateLabel = cell.detailTextLabel
            if alarmDate == nil {
                alarmDate = Date()
            }
            alarmDateLabel?.text = alarmDate?.datetimeToString()
        }
        
        if type == .triggerAlarm {
            let cell = cell as? TriggerAlarmTableViewCell
            cell?.alarmSwitch.isOn = alarmDate != nil
        }

        if type == .triggerRepeat, let reminder = reminder {
            repeatFrequencyLabel = cell.detailTextLabel
            repeatFrequencyLabel?.text = reminder.repeatFrequencyDescription
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType = currentState[indexPath.section][indexPath.row]
        if cellType == .alarm {
            if indexPath.row + 2 == currentState[indexPath.section].count {
                // Not showing date picker, so display it
                transition(to: pickAlarmDateState)
            } else {
                // Showing date picker, so hide it
                transition(to: alarmState)
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    func dismissKeyboard() {
        titleTextField?.resignFirstResponder()
    }
    
    @IBAction func didToggleAlarmSwitch(_ sender: UISwitch) {
        if sender.isOn {
            transition(to: alarmState)
        } else {
            transition(to: defaultState)
        }
    }
    
    @IBAction func didChangeSelection(_ sender: UIDatePicker) {
        alarmDate = sender.date
        alarmDateLabel?.text = alarmDate?.datetimeToString()
    }
    
    @IBAction func titleFieldEditingDidEnd(_ sender: UITextField) {
        reminder?.text = sender.text
        reminder?.push(nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let controller = segue.destination as? RepeatTableViewController {
            controller.delegate = self
            controller.reminder = reminder
        }
    }

}

extension ReminderDetailTableViewController: SetRepeatDelegate {
    
    func didSetRepeatFrequency(to: Reminder.RepeatFrequency) {
        repeatFrequencyLabel?.text = reminder?.repeatFrequencyDescription
    }
    
}
