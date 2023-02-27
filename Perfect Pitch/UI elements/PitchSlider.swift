//
//  PitchSlider.swift
//  Perfect Pitch
//
//  Created by Jia Rui Shan on 2023/2/26.
//

import UIKit

class PitchSlider: UIView {
    
    /// Called when the user made an adjustment to the pitch.
    var onValueChanged: ((CGFloat) -> Void)?

    /// Minimum pitch.
    var minimumValue: CGFloat = 430 { didSet { setNeedsDisplay() } }
    
    /// Maximum pitch.
    var maximumValue: CGFloat = 450 { didSet { setNeedsDisplay() } }
    
    /// Current value.
    var value: CGFloat = 440 {
        didSet { setNeedsDisplay() }
    }
    
    var sensitivity: CGFloat = 1.0
    
    var trueValue: CGFloat = 440 { didSet { setNeedsDisplay() } }
    
    /// The error range, expressed as a percentage.
    var errorRange: CGFloat = 0.01 { didSet { setNeedsDisplay() } }
    var showSolution = false { didSet { setNeedsDisplay() } }
    
    /// The value at which the user began to slide the slider.
    private var pressValue: CGFloat?
    
    private var touchLocation: CGPoint?
    private var triggerTimer: Timer?
    private let trackWidth: CGFloat = 14
    private let knobSize = CGSize(width: 100, height: 50)
    
    var isValueCorrect: Bool {
        return value >= trueValue * (1 - errorRange) && value <= trueValue * (1 + errorRange)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    required init() {
        super.init(frame: .zero)
        
        isOpaque = false
    }
    
    func freqToProportion(_ freq: CGFloat) -> CGFloat {
        return log(freq / minimumValue) / log(maximumValue / minimumValue)
    }
    
    private func valueToY(_ value: CGFloat) -> CGFloat {
        return freqToProportion(value) * (bounds.height - knobSize.height)
    }
    
    // Given a slider position between 0-1, find the corresponding frequency such that `freqToProportion` returns `proportion`.
    func proportionToFreq(_ proportion: CGFloat) -> CGFloat {
        return pow(maximumValue / minimumValue, proportion) * minimumValue
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        
        // Track
        let track = UIBezierPath(roundedRect: CGRect(x: bounds.midX - trackWidth / 2, y: knobSize.height / 2 - trackWidth / 2, width: trackWidth, height: bounds.height - knobSize.height + trackWidth), cornerRadius: trackWidth / 2)
        Colors.trackColor.setFill()
        track.fill()
        
        // Knob
        let knob = UIBezierPath(roundedRect: CGRect(x: bounds.midX - knobSize.width / 2, y: (bounds.height - knobSize.height) - valueToY(value), width: knobSize.width, height: knobSize.height), cornerRadius: 8)
        
        if showSolution {
            Colors.theme.withAlphaComponent(0.3).setFill()
        } else {
            Colors.theme.setFill()
        }
        knob.fill()
        
        // Show solution range
        if showSolution {
            let solutionMin = max(minimumValue, (1 - errorRange) * trueValue)
            let solutionMax = min(maximumValue, (1 + errorRange) * trueValue)
            let solutionRange = UIBezierPath()
            solutionRange.move(to: CGPoint(x: bounds.midX, y: knobSize.height / 2 + bounds.height - knobSize.height - valueToY(solutionMax)))
            solutionRange.addLine(to: CGPoint(x: bounds.midX, y: knobSize.height / 2 + bounds.height - knobSize.height - valueToY(solutionMin)))
            solutionRange.lineWidth = trackWidth
            solutionRange.lineCapStyle = .round
            Colors.pitchRange.setStroke()
            solutionRange.stroke()
            
            // User answer position
            let userAnswer = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: knobSize.height / 2 + bounds.height - knobSize.height - valueToY(value)), radius: trackWidth / 2, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            if isValueCorrect {
                Colors.theme.withAlphaComponent(0.9).setFill()
            } else {
                Colors.incorrect.withAlphaComponent(0.9).setFill()
            }
            userAnswer.fill()
            
            // True value position
            let truePosition = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: knobSize.height / 2 + bounds.height - knobSize.height - valueToY(trueValue)), radius: trackWidth / 2, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
            Colors.correct.withAlphaComponent(0.9).setFill()
            truePosition.fill()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard touches.count == 1 else {
            return
        }
        
        pressValue = value
        touchLocation = touches.first!.location(in: self)
        
        triggerTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            self.onValueChanged?(self.value)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        let df = proportionToFreq((touches.first!.location(in: self).y - touchLocation!.y) * sensitivity / (bounds.height - knobSize.height)) - minimumValue
        value = max(minimumValue, min(maximumValue, pressValue! - df))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchLocation = nil
        triggerTimer?.invalidate()
        triggerTimer = nil
        
        if showSolution {
            value = pressValue!
        }
    }

}
