//
//  Tools.swift
//  FaceDetectionCodeCompetion
//
//  Created by Michael Rothkegel on 08.03.17.
//  Copyright © 2017 Michael Rothkegel. All rights reserved.
//

import Foundation
import UIKit

class Tools {
    
    static func displayContentController(partentViewController:UIViewController, childViewController: UIViewController) {
        partentViewController.addChildViewController(childViewController)
        partentViewController.view.addSubview(childViewController.view)
        childViewController.didMove(toParentViewController: partentViewController)
    }
    
    static func hideContentController(childViewController: UIViewController) {
        childViewController.willMove(toParentViewController: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParentViewController()
    }
    
}