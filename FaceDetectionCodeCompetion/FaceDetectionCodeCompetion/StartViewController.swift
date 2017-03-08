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
    
    @IBOutlet weak var getCameraPermissionButton: UIButton!
    @IBAction func getCameraPermissionButtonAction(_ sender: Any) {
        askForCameraPermission()
    }
    
    var messageAlreadyShow = false
    
    func userDecidedToGiveCameraPermission() {
        UserDefaults.standard.set(true, forKey: "gaveCameraPermission")
    }
    
    func getUserDecidedToGiveCameraPermissionAlready() -> Bool {
        return UserDefaults.standard.bool(forKey: "gaveCameraPermission")
    }
    
    func askForCameraPermission() {
        userDecidedToGiveCameraPermission()
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  .authorized {
            goToCameraViewController()
        } else {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
                if granted == true {
                    self.goToCameraViewController()
                } else {
                    
                    if self.messageAlreadyShow {
                        
                        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                print("Settings opened: \(success)") // Prints true
                            })
                        }
                    } else {
                        
                        
                        self.messageAlreadyShow = true
                        self.getCameraPermissionButton.setTitle("Zum Fotobereich", for: .normal)
                        
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MessageScreenViewController") as? MessageScreenViewController {
                            vc.text = "Aktiviere die Kamera. Sonst war es das schon.😞"
                            
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
        if let vc = storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

extension StartViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        if getUserDecidedToGiveCameraPermissionAlready() {
            askForCameraPermission()
        }
    }
}
