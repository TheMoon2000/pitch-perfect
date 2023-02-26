//
//  Bar.swift
//  Animations
//
//  Created by Jia Rui Shan on 2023/1/14.
//

import UIKit

class Bar: UIView {
    
    var percentage: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    let height: CGFloat = 10


        
    override func draw(_ rect: CGRect) {
        // Track
        let track = UIBezierPath(rect: bounds)
        Colors.trackColor.setFill()
        track.fill()
        
        // Progress
        let progress = UIBezierPath(rect: CGRect(x: .zero, y: .zero, width: percentage * bounds.width, height: height))
        Colors.theme.setFill()
        progress.fill()
        
//        let line = UIBezierPath()
//        line.move(to: CGPoint(x: 12, y: 12))
//        line.addLine(to: CGPoint(x: max(0, (bounds.width - 12) * percentage), y: 12))
//        line.lineWidth = 24
//        line.lineCapStyle = .round
//        UIColor.orange.setStroke()
//        line.stroke()
    }

}
