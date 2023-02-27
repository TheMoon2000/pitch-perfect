//
//  Global Constants.swift
//  Perfect Pitch
//
//  Created by Jia Rui Shan on 2023/2/16.
//

import UIKit

enum Colors {
    static let background = UIColor(named: "Background")!
    static let theme = UIColor(named: "Theme")!
    static let themeLight = UIColor(named: "Theme light")!
    static let themeDisabled = UIColor(named: "Theme disabled")!
    static let correct = UIColor(named: "Correct")!
    static let incorrect = UIColor(named: "Incorrect")!
    static let trackColor = UIColor(named: "Track color")!
    static let pitchRange = UIColor(named: "Pitch range")!
    static let tableBG = UIColor(named: "Table bg")!
    static let cellBG = UIColor(named: "Cell bg")!
    static let cellPressed = UIColor(named: "Cell pressed")!
}

let LEVELS = [1.0, 0.75, 0.5, 0.3333, 0.25, 0.2, 0.15, 0.1, 0.05, 0.02, 0.01]

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
