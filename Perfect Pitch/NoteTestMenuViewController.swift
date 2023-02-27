//
//  HomeViewController.swift
//  Perfect Pitch
//
//  Created by Jia Rui Shan on 2023/2/16.
//

import UIKit

class NoteTestMenuViewController: UIViewController {
    
    weak var menuTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        title = "Pitch Sensitivity Test"
        view.tintColor = Colors.theme
        
        setupUI()
    }

    private func setupUI() {
        menuTable = {
            let tv = UITableView()
            tv.backgroundColor = Colors.tableBG
            tv.delegate = self
            tv.dataSource = self
            tv.contentInset.top = 5
            tv.contentInset.bottom = 5
            tv.tableFooterView = UIView()
            tv.separatorStyle = .none
            tv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tv)
            
            tv.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
            tv.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            tv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            return tv
        }()
    }
}

extension NoteTestMenuViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LEVELS.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = LevelCell(level: indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = NoteTestViewController()
        vc.pitchDifference = LEVELS[indexPath.row]
        vc.title = "Pitch Sensitivity Level \(indexPath.row + 1) - \(round(vc.pitchDifference * 10000) / 100)%"
        let nvc = UINavigationController(rootViewController: vc)
        nvc.navigationBar.tintColor = Colors.theme
        nvc.modalPresentationStyle = .overFullScreen
        present(nvc, animated: true, completion: nil)
    }
}
