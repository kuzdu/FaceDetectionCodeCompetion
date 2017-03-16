//
//  SecretAreaViewController.swift
//  FaceDetectionCodeCompetion
//
//  Created by Michael Rothkegel on 08.03.17.
//  Copyright © 2017 Michael Rothkegel. All rights reserved.
//

import UIKit

class SecretAreaViewController: UIViewController {

    @IBOutlet weak var placeForYourSpiritTextView: UITextView!
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @IBAction func manageAuthorizedImagesButtonAction(_ sender: Any) {
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: imageManagementViewControllerIdent) as? ImageManagementViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func setContentFromLastSessionToTextView() {
        
    }
   
}

extension SecretAreaViewController : UITextViewDelegate {
    
    
    override func didChange(_ changeKind: NSKeyValueChange, valuesAt indexes: IndexSet, forKey key: String) {
   //SAVE HERE
    }
}


extension SecretAreaViewController {
    override func viewDidLoad() {
     
        placeForYourSpiritTextView.delegate = self
        
        setContentFromLastSessionToTextView()
    }
}
