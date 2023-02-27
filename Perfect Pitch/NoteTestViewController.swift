//
//  TestViewController.swift
//  Perfect Pitch
//
//  Created by Jia Rui Shan on 2023/2/16.
//

import UIKit
import AVFoundation

class NoteTestViewController: UIViewController {
    
    enum TestState { case ready, chooseAnswer, shouldProceed, shouldEndTest, finished }
    
    var centerContainer: UIView!
    var centerTitle: UILabel!
    var centerSubtitle: UILabel!
    var continueButton: UIButton!
    
    var progressContainer: UIView!
    var progressText: UILabel!
    var progressBar: Bar!
    
    var testViewContainer: UIView!
    var questionTitle: UILabel!
    var buttonGridContainer: UIView!
    var buttonA: UIButton!
    var buttonB: UIButton!
    var buttonC: UIButton!
    var buttonD: UIButton!
    var lastTriggeredTime = Date()
    
    var currentState = TestState.ready
    // Which question the user is on
    var currentQuestion = 0 {
        didSet {
            progressText.text = "\(currentQuestion) / \(totalQuestions) (\(numberOfCorrectAnswers) Correct)"
            if self.currentState == .chooseAnswer {
                progressBar.percentage = CGFloat(currentQuestion - 1) / CGFloat(totalQuestions)
            } else {
                progressBar.percentage = CGFloat(currentQuestion) / CGFloat(totalQuestions)
            }
        }
    }
    var currentKey: Int!
    var currentOffsets: [Double]!
    var currentAnswerIndex: Int?
    var totalQuestions = 15
    var numberOfCorrectAnswers = 0 {
        didSet {
            progressText.text = "\(currentQuestion) / \(totalQuestions) (\(numberOfCorrectAnswers) Correct)"
        }
    }
    
    let engine = AVAudioEngine()
    let audioPlayer = AVAudioPlayerNode()
    let pitchControl = AVAudioUnitTimePitch()
    var pitchDifference = 0.5

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(self.exitTest))

        view.backgroundColor = Colors.background
        setupUI()
        
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
            label.text = "Pitch Sensitivity Test"
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
            label.text = "Frequency Difference: \(round(pitchDifference * 10000) / 100)%"
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
            
            bar.topAnchor.constraint(equalTo: progressText.bottomAnchor,constant: 3).isActive = true
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
            
            let helperView = UIView()
            helperView.translatesAutoresizingMaskIntoConstraints = false
            testViewContainer.addSubview(helperView)
            helperView.bottomAnchor.constraint(equalTo: testViewContainer.safeAreaLayoutGuide.centerYAnchor).isActive = true
            helperView.topAnchor.constraint(equalTo: testViewContainer.safeAreaLayoutGuide.topAnchor).isActive = true
            
            label.centerYAnchor.constraint(equalTo: helperView.centerYAnchor).isActive = true
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            
            return label
        }()
        
        buttonGridContainer = {
            let v = UIView()
            v.translatesAutoresizingMaskIntoConstraints = false
            testViewContainer.addSubview(v)
            
            v.widthAnchor.constraint(equalTo: v.heightAnchor).isActive = true
            v.centerXAnchor.constraint(equalTo: testViewContainer.safeAreaLayoutGuide.centerXAnchor).isActive = true
            v.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 45).withPriority(.defaultHigh).isActive = true
            v.bottomAnchor.constraint(equalTo: testViewContainer.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
            v.topAnchor.constraint(greaterThanOrEqualTo: questionTitle.bottomAnchor, constant: 5).isActive = true
            
            return v
        }()
        
        buttonA = {
            let button = UIButton(type: .system)
            button.setTitle("A", for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            testViewContainer.addSubview(button)
            
            button.leftAnchor.constraint(equalTo: buttonGridContainer.leftAnchor).isActive = true
            button.topAnchor.constraint(equalTo: buttonGridContainer.topAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: buttonGridContainer.centerXAnchor, constant: -10).isActive = true
            
            return button
        }()
        
        buttonB = {
            let button = UIButton(type: .system)
            button.setTitle("B", for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            testViewContainer.addSubview(button)
            
            button.topAnchor.constraint(equalTo: buttonGridContainer.topAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: buttonGridContainer.rightAnchor).isActive = true
            button.leftAnchor.constraint(equalTo: buttonGridContainer.centerXAnchor, constant: 10).isActive = true
            
            return button
        }()
        
        buttonC = {
            let button = UIButton(type: .system)
            button.setTitle("C", for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            testViewContainer.addSubview(button)
            
            button.leftAnchor.constraint(equalTo: buttonGridContainer.leftAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: buttonGridContainer.bottomAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: buttonGridContainer.centerXAnchor, constant: -10).isActive = true
            
            return button
        }()
        
        buttonD = {
            let button = UIButton(type: .system)
            button.setTitle("D", for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            testViewContainer.addSubview(button)
            
            button.rightAnchor.constraint(equalTo: buttonGridContainer.rightAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: buttonGridContainer.bottomAnchor).isActive = true
            button.leftAnchor.constraint(equalTo: buttonGridContainer.centerXAnchor, constant: 10).isActive = true
            
            return button
        }()
        
        for button in [buttonA, buttonB, buttonC, buttonD] {
            let button = button!
            button.layer.borderWidth = 1
            button.layer.borderColor = Colors.themeLight.cgColor
            button.layer.cornerRadius = 8
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            button.tintColor = Colors.theme
            button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
            
            button.addTarget(self, action: #selector(makeSelection(_:)), for: .touchUpInside)
        }
        
    }
    
    @objc private func exitTest() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func nextQuestion() {
        self.audioPlayer.stop()
        currentKey = Int.random(in: 12...76)
        currentQuestion += 1
        questionTitle.text = "Find the Note: \(Piano.getKeyName(self.currentKey!))"
        
        let correctIndex = Int.random(in: 0..<4)
        currentOffsets = (0..<4).map { Double($0 - correctIndex) * pitchDifference }
        
        UIView.transition(with: view, duration: 0.2, options: .curveEaseOut) {
            for button in [self.buttonA, self.buttonB, self.buttonC, self.buttonD] {
                button?.backgroundColor = nil
                button?.setTitleColor(Colors.theme, for: .normal)
            }
            self.continueButton.isEnabled = false
            self.continueButton.backgroundColor = Colors.themeDisabled
        }
    }
    
    @objc private func continueButtonPressed() {
        switch currentState {
        case .ready:
            currentState = .chooseAnswer
            continueButton.setTitle("Confirm Selection", for: .normal)
            nextQuestion()
            
            UIView.transition(with: view, duration: 0.25, options: .curveEaseOut, animations: {
                self.centerContainer.alpha = 0
                self.progressContainer.alpha = 1
                self.testViewContainer.alpha = 1
                self.continueButton.isEnabled = false
            })
            
        case .chooseAnswer:
            currentState = currentQuestion < totalQuestions ? .shouldProceed : .shouldEndTest
            continueButton.setTitle("Next Question", for: .normal)
            
            if let i = currentAnswerIndex {
                if currentOffsets[i] == 0 {
                    UIView.animate(withDuration: 0.25) {
                        [self.buttonA, self.buttonB, self.buttonC, self.buttonD][i]?.backgroundColor = Colors.correct
                    }
                    numberOfCorrectAnswers += 1
                } else {
                    [self.buttonA, self.buttonB, self.buttonC, self.buttonD][i]?.backgroundColor = Colors.incorrect
                    if let correctIndex = currentOffsets.firstIndex(of: 0.0) {
                        let correctButton = [self.buttonA, self.buttonB, self.buttonC, self.buttonD][correctIndex]
                        correctButton?.backgroundColor = Colors.correct
                        correctButton?.setTitleColor(.white, for: .normal)
                    }
                }
            }
        case .shouldProceed:
            nextQuestion()
            currentState = .chooseAnswer
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
        default:
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func makeSelection(_ sender: UIButton) {
        let answerIndex = ["A", "B", "C", "D"].firstIndex(of: sender.title(for: .normal))!
        
        guard let notePath = Bundle.main.url(forResource: "\(currentKey!)", withExtension: "mp3", subdirectory: "Notes") else {
            print(currentKey, "not found!")
            return
        }
        
        if currentState == .chooseAnswer {
            currentAnswerIndex = answerIndex
            UIView.animate(withDuration: 0.2) {
                self.continueButton.isEnabled = true
                self.continueButton.backgroundColor = Colors.theme
            }
            
            for button in [buttonA, buttonB, buttonC, buttonD] {
                if button == sender {
                    UIView.transition(with: button!, duration: 0.2, options: .curveEaseOut) {
                        button?.backgroundColor = Colors.theme
                        button?.setTitleColor(.white, for: .normal)
                    }
                } else {
                    UIView.transition(with: button!, duration: 0.2, options: .curveEaseOut) {
                        button?.backgroundColor = nil
                        button?.setTitleColor(Colors.theme, for: .normal)
                    }
                }
            }
        }
        
        let triggerTime = Date()
        lastTriggeredTime = triggerTime
        pitchControl.pitch = Float(currentOffsets[answerIndex] * 100)
        let file = try! AVAudioFile(forReading: notePath)
        
        audioPlayer.stop()
        audioPlayer.scheduleFile(file, at: nil)
        audioPlayer.play()
        
        Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { _ in
            if self.lastTriggeredTime == triggerTime {
                self.audioPlayer.stop()
            }
        }
    }
}
