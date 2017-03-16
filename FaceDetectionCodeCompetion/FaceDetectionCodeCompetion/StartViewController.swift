//
//  Start2ViewController.swift
//  FaceDetectionCodeCompetion
//
//  Created by Michael Rothkegel on 07.03.17.
//  Copyright © 2017 Michael Rothkegel. All rights reserved.
//

import UIKit
import AVFoundation

class StartViewController: UIViewController {
    
    //MARK: UI
    @IBOutlet weak var getCameraPermissionButton: UIButton!
    
    
    //MARK: Button Actions
    @IBAction func getCameraPermissionButtonAction(_ sender: Any) {
        handleCameraPermission()
    }
    
    
    //MARK: VARS
    var messageThatAppJustWorkWithCameraPermissionAlreadyShow = false
    
    
    func handleCameraPermission() {
        Tools.userWasAskToGiveCameraPermission()
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  .authorized {
            goToCameraViewController()
        } else {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
                if granted == true {
                    self.goToCameraViewController()
                } else {
                    
                    if self.messageThatAppJustWorkWithCameraPermissionAlreadyShow {
                        Tools.openSettingsOfUsersIphoneToSetCameraPermisson()
                    } else {
                        
                        self.messageThatAppJustWorkWithCameraPermissionAlreadyShow = true
                        self.getCameraPermissionButton.setTitle("Zum Fotobereich", for: .normal)
                        
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: messageScreenViewControllerIdent) as? MessageScreenViewController {
                            vc.text = noCameraPermissionError
                            
                            DispatchQueue.main.async {
                                Tools.displayContentController(partentViewController: self, childViewController: vc)
                            }
                        }
                        
                    }
                    
                    
                    
                }
            })
        }
    }
    
    func goToCameraViewController() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: cameraViewControllerIdent) as? CameraViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func fillGlobalArraysWithSavedData() {
       
        let numberOfImages = UserDefaults.standard.integer(forKey: numberOfImagesKey)+1
        
        for i in 1..<numberOfImages {
            if let (image,faceId) = Tools.loadImageAndFaceId(keyImage: "\(i)_img", keyFaceId: "\(i)_faceId") {
                authorizedFaceIdsGlobalArray.append(faceId)
                authorizedImagesGlobalArray.append(image)
            }
        }
    }
    
}

extension StartViewController {
    
    
    override func viewDidLoad() {
        fillGlobalArraysWithSavedData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Tools.userGaveAlreadyCameraPermission() {
            handleCameraPermission()
        }
    }
}
