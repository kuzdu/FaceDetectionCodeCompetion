//
//  SecretAreaViewController.swift
//  FaceDetectionCodeCompetion
//
//  Created by Michael Rothkegel on 08.03.17.
//  Copyright © 2017 Michael Rothkegel. All rights reserved.
//

import UIKit

class SecretAreaViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "🎸Deine Area🤘"
        
    }

    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
