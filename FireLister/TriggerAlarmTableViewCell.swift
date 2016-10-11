//
//  TriggerAlarmTableViewCell.swift
//  FireLister
//
//  Created by Connor Crawford on 10/10/16.
//  Copyright © 2016 Connor Crawford. All rights reserved.
//

import UIKit

class TriggerAlarmTableViewCell: UITableViewCell {

    override var textLabel: UILabel? {
        get {
            return label
        }
    }
    @IBOutlet weak private var label: UILabel!
    @IBOutlet weak var alarmSwitch: UISwitch!

}
