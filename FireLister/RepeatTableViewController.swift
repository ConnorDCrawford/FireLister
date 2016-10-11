//
//  RepeatTableViewController.swift
//  FireLister
//
//  Created by Connor Crawford on 10/10/16.
//  Copyright © 2016 Connor Crawford. All rights reserved.
//

import UIKit

class RepeatTableViewController: UITableViewController {

    var reminder: Reminder? {
        didSet {
            if let reminder = reminder {
                selectedRow = reminder.repeatFrequency.rawValue
            }
        }
    }
    
    private var selectedRow: Int!
    var delegate: SetRepeatDelegate?
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if indexPath.row == selectedRow {
            cell.accessoryType = .checkmark
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            reminder?.repeatFrequency = .never
        case 1:
            reminder?.repeatFrequency = .daily
        case 2:
            reminder?.repeatFrequency = .weekly
        case 3:
            reminder?.repeatFrequency = .biweekly
        case 4:
            reminder?.repeatFrequency = .monthly
        case 5:
            reminder?.repeatFrequency = .yearly
        default:
            break
        }
        
        // Set a checkmark next to selection
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Tell delegate of change
        if let reminder = reminder {
            delegate?.didSetRepeatFrequency(to: reminder.repeatFrequency)
        }
        
        // Push changes to DB
        reminder?.push(nil)
        
        // Return to previous VC
        _ = navigationController?.popViewController(animated: true)
    }

}
