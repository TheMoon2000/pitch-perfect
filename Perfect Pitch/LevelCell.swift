//
//  LevelCell.swift
//  Perfect Pitch
//
//  Created by Jia Rui Shan on 2023/2/17.
//

import UIKit

class LevelCell: UITableViewCell {

    private(set) var level: Int = 0
    private(set) var prefix: String!
    private var bgView: UIView!
    private var titleLabel: UILabel!
    private var diffBackground: UIView!
    private var diffLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    required init(level: Int, prefix: String = "") {
        super.init(style: .default, reuseIdentifier: nil)
        self.level = level
        self.prefix = prefix
        selectionStyle = .none
        backgroundColor = .clear
        
        bgView = {
            let v = UIView()
            v.backgroundColor = Colors.cellBG
            v.layer.cornerRadius = 5
            v.translatesAutoresizingMaskIntoConstraints = false
            addSubview(v)
            
            v.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
            v.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
            v.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
            v.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
            v.heightAnchor.constraint(equalToConstant: 75).isActive = true
            
            return v
        }()
        
        titleLabel = {
            let label = UILabel()
            label.text = "Level \(level)"
            label.font = .systemFont(ofSize: 19, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 15).isActive = true
            label.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
            
            return label
        }()
        
//        diffBackground = {
//            let v = UIView()
//            v.backgroundColor = Colors.trackColor
//            v.layer.cornerRadius = 8
//            v.translatesAutoresizingMaskIntoConstraints = false
//            bgView.addSubview(v)
//
//            v.widthAnchor.constraint(equalTo: v.heightAnchor).isActive = true
//            v.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
//            v.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -15).isActive = true
//            v.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 10).isActive = true
//
//            return v
//        }()
        
        diffLabel = {
            let label = UILabel()
            label.text = "\(prefix)\(round(LEVELS[level - 1] * 10000) / 100)%"
            label.font = .systemFont(ofSize: 17, weight: .bold)
            label.textColor = Colors.theme
            label.translatesAutoresizingMaskIntoConstraints = false
            bgView.addSubview(label)
            
            label.centerYAnchor.constraint(equalTo: bgView.centerYAnchor).isActive = true
            label.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -30).isActive = true
            
            return label
        }()
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if !highlighted {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                self.bgView.backgroundColor = Colors.cellBG
            })
        } else {
            self.bgView.backgroundColor = Colors.cellPressed
        }
    }

}
