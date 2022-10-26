//
//  BaseViewController.swift
//  PodcastsApp
//
//  Created by Bayu Yasaputro on 26/10/22.
//

import UIKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.sizeToFit()
        
    }
}
