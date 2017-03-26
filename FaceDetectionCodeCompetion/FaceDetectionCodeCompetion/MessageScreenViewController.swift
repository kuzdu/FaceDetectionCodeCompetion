//
//  ErrorScreenViewController.swift
//  FaceDetectionCodeCompetion
//
//  Created by Michael Rothkegel on 08.03.17.
//  Copyright © 2017 Michael Rothkegel. All rights reserved.
//

import UIKit

class MessageScreenViewController: UIViewController {
    
    
    /** MARK: UI ELEMENTS */
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    var text = ""
    
    //default colors
    var backgroundColor = UIColor.white
    var textColor = UIColor.black
    
    /** animation to hide message screen */
    func closeViewAfterSeconds() {
        let when = DispatchTime.now() + 1.5
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            
            UIView.animate(withDuration: 0.5, animations: {
                self.topConstraint.constant = -154
                self.view.layoutIfNeeded()
            }, completion: { (finished) in
                Tools.hideContentController(childViewController: self)
            })
        }
        
        
    }
    
    func setTextAndColors() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        messageLabel.text = text
        messageLabel.textColor = textColor
        messageView.backgroundColor = backgroundColor
    }
}

extension MessageScreenViewController {
  
    
    override func viewWillAppear(_ animated: Bool) {
        setTextAndColors()
        closeViewAfterSeconds()
    }
    
}
