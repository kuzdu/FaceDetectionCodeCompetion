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
    }
    @IBAction func backButtonAction(_ sender: Any) {
    
        _ = self.navigationController?.popViewController(animated: true)
    
    }

    @IBAction func manageAuthorizedImagesButtonAction(_ sender: Any) {
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ImageManagementViewController") as? ImageManagementViewController {
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
   
}
