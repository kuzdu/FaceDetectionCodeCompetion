//
//  SecretAreaViewController.swift
//  FaceDetectionCodeCompetion
//
//  Created by Michael Rothkegel on 08.03.17.
//  Copyright © 2017 Michael Rothkegel. All rights reserved.
//

import UIKit

class SecretAreaViewController: UIViewController {
    
    //MARK: UI
    @IBOutlet weak var placeForYourSpiritTextView: UITextView!
    
    @IBOutlet weak var hideKeyboardButton: UIButton!
    
    //MARK: BUTTON ACTIONS
    @IBAction func backButtonAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func manageAuthorizedImagesButtonAction(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: imageManagementViewControllerIdent) as? ImageManagementViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func hideKeyboardButtonAction(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    func loadContentFromLastSessionAndSetToTextView() {
        if let text = UserDefaults.standard.string(forKey: inputInTextViewInSecretAreaTextKey) {
            if text.characters.count > 0 {
                placeForYourSpiritTextView.text = text
            }
        }
    }
    
    func initTextView() {
        placeForYourSpiritTextView.delegate = self
        placeForYourSpiritTextView.layer.cornerRadius = 4
    }
    
}

extension SecretAreaViewController : UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        hideKeyboardButton.isHidden = false
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text {
            UserDefaults.standard.set(text, forKey: inputInTextViewInSecretAreaTextKey)
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        hideKeyboardButton.isHidden = true
        return true
    }
}


extension SecretAreaViewController {
    override func viewDidLoad() {
        initTextView()
        loadContentFromLastSessionAndSetToTextView()
    }
}
