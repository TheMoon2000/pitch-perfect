//
//  ApproximationTestViewController.swift
//  Perfect Pitch
//
//  Created by Jia Rui Shan on 2023/2/26.
//

import UIKit
import AVFoundation

class ApproximationTestViewController: UIViewController {
    
    enum TestState { case ready, adjustAnswer, shouldProceed, shouldEndTest, finished }
    
    var pitchDifference = 0.5
    var currentState: TestState = .ready
    var totalQuestions = 15
    var currentQuestion = 0 {
        didSet {
            progressText.text = "\(currentQuestion) / \(totalQuestions) (\(numberOfCorrectAnswers) Correct)"
            if self.currentState == .adjustAnswer {
                progressBar.percentage = CGFloat(currentQuestion - 1) / CGFloat(totalQuestions)
            } else {
                progressBar.percentage = CGFloat(currentQuestion) / CGFloat(totalQuestions)
            }
        }
    }
    var numberOfCorrectAnswers = 0 {
        didSet {
            progressText.text = "\(currentQuestion) / \(totalQuestions) (\(numberOfCorrectAnswers) Correct)"
        }
    }
    
    var centerContainer: UIView!
    var centerTitle: UILabel!
    var centerSubtitle: UILabel!
    var continueButton: UIButton!
    
    var progressContainer: UIView!
    var progressText: UILabel!
    var progressBar: Bar!
    
    var testViewContainer: UIView!
    var questionTitle: UILabel!
    var pitchSlider: PitchSlider!
    
    let engine = AVAudioEngine()
    let audioPlayer = AVAudioPlayerNode()
    let pitchControl = AVAudioUnitTimePitch()
    var currentKey: Int!
    
    var lastNotePlayedTime: Date?
    var lastTriggeredTime = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.background
        setupUI()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(self.exitTest))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "cursorarrow.motionlines"), style: .plain, target: self, action: #selector(changeSensitivity))
        
        engine.attach(audioPlayer)
        engine.attach(pitchControl)
        engine.connect(audioPlayer, to: pitchControl, format: nil)
        engine.connect(pitchControl, to: engine.mainMixerNode, format: nil)
        try! engine.start()
    }
    
    private func setupUI() {
        centerContainer = {
            let v = UIView()
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
            
            v.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 30).isActive = true
            v.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -30).isActive = true
            v.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -5).isActive = true
            
            return v
        }()
        
        centerTitle = {
            let label = UILabel()
            label.text = "Note Approximation Test"
            label.numberOfLines = 2
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 28, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            centerContainer.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: centerContainer.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: centerContainer.topAnchor).isActive = true
            
            return label
        }()
        
        centerSubtitle = {
            let label = UILabel()
            label.text = "Error Tolerance: ±\(round(pitchDifference * 10000) / 100)%"
            label.translatesAutoresizingMaskIntoConstraints = false
            centerContainer.addSubview(label)
            
            label.topAnchor.constraint(equalTo: centerTitle.bottomAnchor, constant: 10).isActive = true
            label.centerXAnchor.constraint(equalTo: centerContainer.centerXAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: centerContainer.bottomAnchor).isActive = true
            
            return label
        }()
        
        continueButton = {
            let button = UIButton(type: .system)
            button.setTitle("Begin Test", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = Colors.theme
            button.layer.cornerRadius = 24
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -70).isActive = true
            button.heightAnchor.constraint(equalToConstant: 48).isActive = true
            button.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 40).isActive = true
            button.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40).isActive = true
            
            button.addTarget(self, action: #selector(continueButtonPressed), for: .touchUpInside)
            
            return button
        }()
        
        progressContainer = {
            let v = UIView()
            v.alpha = 0
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
            
            v.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
            v.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 40).isActive = true
            v.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -40).isActive = true
            
            return v
        }()
        
        progressText = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 15)
            label.text = "\(currentQuestion) / \(totalQuestions)"
            label.translatesAutoresizingMaskIntoConstraints = false
            progressContainer.addSubview(label)
            
            label.centerXAnchor.constraint(equalTo: progressContainer.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: progressContainer.topAnchor).isActive = true
            
            return label
        }()
        
        progressBar = {
            let bar = Bar()
            bar.clipsToBounds = true
            bar.layer.cornerRadius = bar.height / 2
            bar.translatesAutoresizingMaskIntoConstraints = false
            progressContainer.addSubview(bar)
            
            bar.topAnchor.constraint(equalTo: progressText.bottomAnchor, constant: 3).isActive = true
            bar.leftAnchor.constraint(equalTo: progressContainer.leftAnchor).isActive = true
            bar.rightAnchor.constraint(equalTo: progressContainer.rightAnchor).isActive = true
            bar.bottomAnchor.constraint(equalTo: progressContainer.bottomAnchor).isActive = true
            bar.heightAnchor.constraint(equalToConstant: bar.height).isActive = true
            
            return bar
        }()
        
        testViewContainer = {
            let v = UIView()
            v.alpha = 0
            v.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(v)
            
            v.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
            v.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
            v.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            v.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -15).isActive = true
            
            return v
        }()
        
        questionTitle = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 25, weight: .medium)
            label.translatesAutoresizingMaskIntoConstraints = false
            testViewContainer.addSubview(label)
                        
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
            
            return label
        }()
        
        pitchSlider = {
            let v = PitchSlider()
            v.onValueChanged = { newValue in
                if !self.continueButton.isEnabled {
                    UIView.transition(with: self.view, duration: 0.2, options: .curveEaseOut) {
                        self.continueButton.isEnabled = true
                        self.continueButton.backgroundColor = Colors.theme
                    }
                }
                self.playCurrentNote()
            }
            v.translatesAutoresizingMaskIntoConstraints = false
            testViewContainer.addSubview(v)
            
            v.widthAnchor.constraint(equalToConstant: 100).isActive = true
            v.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            v.topAnchor.constraint(equalTo: questionTitle.bottomAnchor, constant: 20).isActive = true
            v.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -20).isActive = true
            
            return v
        }()
    }
    
    @objc private func exitTest() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func playCurrentNote() {
        if lastNotePlayedTime == nil || lastNotePlayedTime!.timeIntervalSinceNow < -1.5 {
            guard let notePath = Bundle.main.url(forResource: "\(currentKey!)", withExtension: "mp3", subdirectory: "Notes") else {
                print(currentKey!, "not found!")
                return
            }
            
            pitchControl.pitch = Float(pitchSlider.freqToProportion(pitchSlider.value) - pitchSlider.freqToProportion(pitchSlider.trueValue)) * Float(pitchDifference) * 200
            let file = try! AVAudioFile(forReading: notePath)
            
            let triggerTime = Date()
            lastTriggeredTime = triggerTime
            
            audioPlayer.stop()
            audioPlayer.scheduleFile(file, at: nil)
            audioPlayer.play()
            
            Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { _ in
                if self.lastTriggeredTime == triggerTime {
                    self.audioPlayer.stop()
                }
            }
            
            lastNotePlayedTime = Date()
        }
    }
    
    func nextQuestion() {
        self.audioPlayer.stop()
        currentKey = Int.random(in: 12...76)
        currentQuestion += 1
        questionTitle.text = "Find the Note: \(Piano.getKeyName(self.currentKey!))"
        
        pitchSlider.trueValue = 27.5 * pow(2, CGFloat(currentKey) / 12)
        let randomInitialLocation = CGFloat.random(in: 0...2)
        pitchSlider.minimumValue = pitchSlider.trueValue / pow(2, randomInitialLocation / 12)
        pitchSlider.maximumValue = pitchSlider.trueValue * pow(2, (2 - randomInitialLocation) / 12)
        pitchSlider.errorRange = pow(2, CGFloat(pitchDifference / 2) / 12) - 1
        pitchSlider.value = pitchSlider.proportionToFreq(0.5)
        pitchSlider.showSolution = false
                
        UIView.transition(with: view, duration: 0.2, options: .curveEaseOut) {
            self.continueButton.isEnabled = false
            self.continueButton.backgroundColor = Colors.themeDisabled
        }
        
    }
    
    @objc private func continueButtonPressed() {
        switch currentState {
        case .ready:
            nextQuestion()
            currentState = .adjustAnswer
            continueButton.setTitle("Confirm Note", for: .normal)
            
            UIView.transition(with: view, duration: 0.25, options: .curveEaseOut, animations: {
                self.centerContainer.alpha = 0
                self.progressContainer.alpha = 1
                self.testViewContainer.alpha = 1
                self.continueButton.isEnabled = false
            })
        case .adjustAnswer:
            pitchSlider.showSolution = true
            currentState = currentQuestion < totalQuestions ? .shouldProceed : .shouldEndTest
            continueButton.setTitle("Next Question", for: .normal)
            
            if pitchSlider.isValueCorrect {
                numberOfCorrectAnswers += 1
            }
        case .shouldProceed:
            nextQuestion()
            currentState = .adjustAnswer
            continueButton.setTitle("Confirm Selection", for: .normal)
        case .shouldEndTest:
            currentState = .finished
            self.centerTitle.text = "Score: \(self.numberOfCorrectAnswers) / \(self.totalQuestions)"
            self.centerSubtitle.text = ""
            UIView.transition(with: view, duration: 0.25, options: .curveEaseOut, animations: {
                self.centerContainer.alpha = 1
                self.testViewContainer.alpha = 0
                self.progressContainer.alpha = 0
            })
            continueButton.setTitle("Exit Test", for: .normal)
        case .finished:
            dismiss(animated: true)
        default:
            break
        }
    }
    
    @objc private func changeSensitivity() {
        let alert = UIAlertController(title: "Change Sensitivity", message: nil, preferredStyle: .actionSheet)
        for level in [15, 25, 50, 75, 100] {
            let sensitivity = CGFloat(level) / 100
            alert.addAction(UIAlertAction(title: "\(level)%" + (sensitivity == pitchSlider.sensitivity ? " (current)" : ""), style: .default, handler: { _ in
                self.pitchSlider.sensitivity = sensitivity
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
