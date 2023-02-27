//
//  TabBarController.swift
//  Perfect Pitch
//
//  Created by Jia Rui Shan on 2023/2/26.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewControllers = [
            HomeNavigationController(rootViewController: NoteTestMenuViewController()),
            HomeNavigationController(rootViewController: ApproximationTestMenuViewController())
        ]
        
        viewControllers![0].tabBarItem = UITabBarItem(title: "Pitch Sensitivity Test", image: UIImage(systemName: "music.note.list"), tag: 1)
        viewControllers![1].tabBarItem = UITabBarItem(title: "Note Approximation Test", image: UIImage(systemName: "slider.horizontal.3"), tag: 2)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
