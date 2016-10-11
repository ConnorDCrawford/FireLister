//
//  SetRepeatDelegate.swift
//  FireLister
//
//  Created by Connor Crawford on 10/11/16.
//  Copyright © 2016 Connor Crawford. All rights reserved.
//

import Foundation

protocol SetRepeatDelegate {
    func didSetRepeatFrequency(to: Reminder.RepeatFrequency)
}
