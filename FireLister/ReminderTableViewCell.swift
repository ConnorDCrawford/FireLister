//
//  ReminderTableViewCell.swift
//  FireLister
//
//  Created by Connor Crawford on 10/9/16.
//  Copyright © 2016 Connor Crawford. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {

    var reminder: Reminder?
    @IBOutlet weak var completedButton: UIButton!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBAction func didPressCompletedButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        reminder?.isCompleted = sender.isSelected
        reminder?.push({ (error) in
            if let error = error {
                // Unsuccessful, return to prior state
                NSLog(error.localizedDescription)
                sender.isSelected = !sender.isSelected
            }
        })
    }
}
