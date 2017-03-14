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
    
    
    static func showMessage(text: String, parentViewController: UIViewController) {
        if let vc = parentViewController.storyboard?.instantiateViewController(withIdentifier: "MessageScreenViewController") as? MessageScreenViewController {
            vc.text = text
            Tools.displayContentController(partentViewController: parentViewController, childViewController: vc)
        }
    }
    
    
    static func saveFaceIdAndImage(image: UIImage, faceId: String, keyImage:String, keyFaceId:String) {
        if let imageData = UIImageJPEGRepresentation(image, 1) {
            UserDefaults.standard.set(imageData, forKey: keyImage)
        }
        
        UserDefaults.standard.set(faceId, forKey: keyFaceId)
    }
    
    static func removeImageAndFaceId(keyImage:String, keyFaceId: String) {
        UserDefaults.standard.removeObject(forKey: keyImage)
        UserDefaults.standard.removeObject(forKey: keyFaceId)
    }
    
    static  func loadImageAndFaceId(keyImage:String, keyFaceId: String) -> (UIImage,String)? {
        
        var image:UIImage?
        var faceId:String?
        
        if let imageAsData:Data = UserDefaults.standard.object(forKey: keyImage) as? Data {
            image = UIImage(data: imageAsData)
        }
        
        if let getFaceId = UserDefaults.standard.string(forKey: keyFaceId) {
            faceId = getFaceId
        }
        
        if image != nil && faceId != nil {
            return (image!,faceId!)
        }
        
        return nil
    }
    
}
