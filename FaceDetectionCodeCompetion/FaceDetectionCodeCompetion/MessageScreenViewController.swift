//
//  ErrorScreenViewController.swift
//  FaceDetectionCodeCompetion
//
//  Created by Michael Rothkegel on 08.03.17.
//  Copyright © 2017 Michael Rothkegel. All rights reserved.
//

import UIKit

class MessageScreenViewController: UIViewController {
    
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var text = ""
    var backgroundColor = UIColor.white
    var textColor = UIColor.black
    
    func closeViewAfterSeconds() {
        
        let when = DispatchTime.now() + 2.5 // change 2 to desired number of seconds
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
}

extension MessageScreenViewController {
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        messageLabel.text = text
        messageLabel.textColor = textColor
        messageView.backgroundColor = backgroundColor
        
        
        self.closeViewAfterSeconds()
        
    }
    
}
