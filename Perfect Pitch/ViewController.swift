//
//  ViewController.swift
//  Perfect Pitch
//
//  Created by Jia Rui Shan on 2023/2/13.
//

import UIKit

class ViewController: UIViewController {
    
    weak var titleLabel: UILabel!
    weak var slider: UISlider!
    weak var sliderValue: UILabel!
    weak var buttonStack: UIStackView!
    weak var resetButton: UIButton!
    
    var answerIndex: Int? = 0
    
    var noteFrequencies: [Float] = [0, 0, 0, 0]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        titleLabel = {
            let label = UILabel()
            label.font = .systemFont(ofSize: 22, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
            label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            
            return label
        }()
        
        buttonStack = {
            let sv = UIStackView()
            sv.axis = .vertical
            sv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(sv)
            
            sv.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            sv.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
            sv.widthAnchor.constraint(greaterThanOrEqualToConstant: 200).isActive = true
            return sv
        }()
        
        slider = {
            let s = UISlider()
            s.isContinuous = true
            s.minimumValue = 0.001
            s.maximumValue = 0.06
            s.value = 0.01
            s.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(s)
            
            s.widthAnchor.constraint(equalTo: buttonStack.widthAnchor).isActive = true
            s.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            s.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -15).isActive = true
            s.addTarget(self, action: #selector(sliderUpdated), for: .valueChanged)
            
            return s
        }()
        
        sliderValue = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            label.centerYAnchor.constraint(equalTo: slider.centerYAnchor).isActive = true
            label.leftAnchor.constraint(equalTo: slider.rightAnchor, constant: 10).isActive = true
            
            return label
        }()
        
        for i in 0..<4 {
            let button = UIButton()
            button.setTitle(["A", "B", "C", "D"][i], for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
            button.layer.borderColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1).cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 25
            button.translatesAutoresizingMaskIntoConstraints = false
            
            button.widthAnchor.constraint(equalToConstant: 220).isActive = true
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
            let longTap = UILongPressGestureRecognizer(target: self, action: #selector(buttonDoublePressed(_:)))
            longTap.name = "\(i)"
            longTap.minimumPressDuration = 1
            button.addGestureRecognizer(longTap)
            
            buttonStack.addArrangedSubview(button)
        }
        
        resetButton = {
            let button = UIButton(type: .system)
            button.setTitle("Reset", for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
            
            button.addTarget(self, action: #selector(assign), for: .touchUpInside)
            
            return button
        }()
        
        sliderUpdated()
        assign()
    }
    
    @objc func assign() {
        let randomInterval = Float(Int.random(in: 1...48))
        let randomNote = pow(2, randomInterval/12) * 110
        let offsets: [Float] = (0..<4).map { i in
            return 1.0 - Float(3-i) * slider.value
        }
        let randomOffset = offsets.randomElement()!
        noteFrequencies = (0..<4).map { i in
            return randomNote * (Float(randomOffset) + 0.005 * Float(i))
        }
        titleLabel.text = "Target Note: A2 + \(Int(randomInterval))"
        
        answerIndex = 3 - offsets.firstIndex(of: randomOffset)!
    }
    
    @objc func sliderUpdated() {
        sliderValue.text = String(round(slider.value * 10000) / 10000)
    }
    
    @objc func buttonPressed(_ sender: UIButton) {
        let index = ["A", "B", "C", "D"].firstIndex(of: sender.title(for: .normal)!)!
        playPureTone(frequencyInHz: noteFrequencies[index], amplitude: 1, durationInMillis: 400, completion: {})
    }

    @objc func buttonDoublePressed(_ gesture: UILongPressGestureRecognizer) {
        guard answerIndex != nil else { return }
        let index = Int(gesture.name!)
        
        let alert = UIAlertController()
        if index == answerIndex {
            alert.title = "Correct"
        } else{
            alert.title = "Incorrect"
        }
        alert.addAction(.init(title: "Dismiss", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
}

