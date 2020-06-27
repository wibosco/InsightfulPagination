//
//  PageViewController.swift
//  Example
//
//  Created by William Boles on 27/06/2020.
//  Copyright © 2020 William Boles. All rights reserved.
//

import UIKit

class PageViewController: UIViewController {
    
    @IBOutlet weak var labelPage: UILabel!
    @IBOutlet weak var labelInformational: UILabel!
    
    // MARK: ViewLifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.randomPastelColor
    }
}
