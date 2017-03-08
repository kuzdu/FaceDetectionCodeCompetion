//
//  ViewController.swift
//  FaceDetectionCodeCompetion
//
//  Created by Michael Rothkegel on 06.03.17.
//  Copyright © 2017 Michael Rothkegel. All rights reserved.
//

import UIKit
import ProjectOxfordFace
import AVFoundation
import EZLoadingActivity


let microsoftFaceDetectionApiKey = "7a3bad27eb4d41849eb86bb8cf310c86"

class CameraViewController: UIViewController {
    
    
    //MARK: VARS
    //Microsoft Api
    let mpoFaceServiceClient = MPOFaceServiceClient(subscriptionKey: microsoftFaceDetectionApiKey)
    
    //authorized user
    var userWantToLoginFaceIds:[String] = []
    
    //faces of peope
    var authorizedFaceIds: [String] = []
    
    //camera
    let captureSession = AVCaptureSession()
    var captureDevice:AVCaptureDevice!
    var tookPhotoAutomatically = false
    
    var loginUser = false
    var authorizeUser = false
    
    var imageForImageView:UIImage?
    var savedImage:UIImage?
    
    @IBOutlet weak var createdImageImageView: UIImageView!
    
    //UI-Element where the preview of camera is
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var authorizeUserButton: UIButton!
    
    @IBOutlet weak var takeImageButton: UIButton!
    @IBAction func takeImageButtonAction(_ sender: Any) {
        
        dontTakeImageButton.isHidden = true
        takeImageButton.isHidden = true
        createdImageImageView.isHidden = true
        
        EZLoadingActivity.show("Sichere Foto...📸", disableUI: true)
        if let savedImage = savedImage {
            authorizeImageOfUser(image: savedImage)
        }
    }
    
    @IBOutlet weak var dontTakeImageButton: UIButton!
    @IBAction func dontTakeImageButtonAction(_ sender: Any) {
        savedImage = nil
        
        
        createdImageImageView.isHidden = true
        dontTakeImageButton.isHidden = true
        takeImageButton.isHidden = true
    }
    
    
    @IBAction func authorizeUserButtonAction(_ sender: Any) {
        
        
        if authorizedFaceIds.count > 0 {
            loginUser = true
            EZLoadingActivity.show("Kontrolliere Gesicht...🕵️", disableUI: true)
        } else {
            authorizeUser = true
        }
        
    }
    
    
    func showMessage(text: String) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "MessageScreenViewController") as? MessageScreenViewController {
            
            vc.text = text
            Tools.displayContentController(partentViewController: self, childViewController: vc)
            
        }
    }
    
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        if let availableDevices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .front).devices {
            captureDevice = availableDevices.first
            beginSession()
        }
        
    }
    
    func beginSession () {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        
        if let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) {
            
            previewLayer.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: cameraView.frame.height)
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            cameraView.layer.addSublayer(previewLayer)
            
            captureSession.startRunning()
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)]
            
            dataOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(dataOutput) {
                captureSession.addOutput(dataOutput)
            }
            
            captureSession.commitConfiguration()
            
            
            let queue = DispatchQueue(label: "com.rothkegel.kuzdu.FaceDetectionCodeCompetion")
            dataOutput.setSampleBufferDelegate(self, queue: queue)
        }
    }
    
    
    func checkLogin(forImage: UIImage) {
        
        let dataOfUserWhoWantsLogin = UIImageJPEGRepresentation(forImage, 1)
        
        self.mpoFaceServiceClient?.detect(with: dataOfUserWhoWantsLogin, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: nil, completionBlock: { (faces, error) in
            
            
            var detectFace = false
            if let faces = faces {
                for face in faces {
                    detectFace = true
                    self.userWantToLoginFaceIds.append(face.faceId)
                }
            }
            
            var text = ""
            if error != nil {
                
                text = "Ein unbekannter Fehler ist aufgetreten.🚀"
                if let error = error?.localizedDescription {
                    text = error
                }
                
                self.showMessage(text: text)
            } else {
                if detectFace == true {
                    self.checkUser()
                } else {
                    text = "Auf dem Foto wurde kein Gesicht erkannt.🙈"
                }
            }
            EZLoadingActivity.hide()
            if !detectFace {
                self.showMessage(text: text)
            }
        })
        
    }
    
    func authorizeImageOfUser(image: UIImage) {
        
        let dataOfAuthorizedUser = UIImageJPEGRepresentation(image,1)
        
        mpoFaceServiceClient?.detect(with: dataOfAuthorizedUser, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: nil, completionBlock: { (faces, error) in
            
            var detectFace = false
            //should always be just one
            if let faces = faces {
                for face in faces {
                    self.authorizedFaceIds.append(face.faceId)
                    detectFace = true
                }
            }
            
            
            var text = ""
            if error != nil {
                
                text = "Ein unbekannter Fehler ist aufgetreten.🚀"
                if let error = error?.localizedDescription {
                    text = error
                }
                
                self.showMessage(text: text)
            } else {
                
                
                if detectFace == true {
                    text = "Das Bild wurde gepspeichert und die ID erfolgreich hinterlegt. 🍯"
                    self.authorizeUserButton.setTitle("Einloggen per Foto", for: .normal)
                    self.authorizeUserButton.setTitleColor(UIColor.white, for: .normal)
                   
                    self.authorizeUserButton.backgroundColor = UIColor(red: CGFloat(99.0/255.0), green: CGFloat(130.0/255.0), blue: CGFloat(255.0/255.0), alpha: CGFloat(1))
                } else {
                    text = "Auf dem Foto wurde kein Gesicht erkannt.🙈"
                }
            }
            EZLoadingActivity.hide()
            self.showMessage(text: text)
        })
    }
    
    func checkUser() {
        
        mpoFaceServiceClient?.findSimilar(withFaceId: userWantToLoginFaceIds[userWantToLoginFaceIds.count-1], faceIds: authorizedFaceIds, completionBlock: { (similarFaces, error) in
            
            EZLoadingActivity.hide()
            var needToShowMessage = true
            var messageText = "Ein unbekannter Fehler ist aufgetreten. 🚀"
            
            if error != nil {
                if let error = error {
                    messageText = error.localizedDescription
                }
            } else {
                for similarFace in similarFaces! {
                    
                    print("the confidence \(similarFace.confidence)")
                    
                    if Double(similarFace.confidence) > 0.8 {
                        needToShowMessage = false
                        
                        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "SecretAreaViewController") as? SecretAreaViewController {
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    } else {
                        messageText = "Die Übereinstimmung reichte nicht, versuch es nochmal.😎 ... \nEin Passwort zuschicken geht nämlich auch nicht. 🙈"
                    }
                }
            }
            
            if needToShowMessage {
                self.showMessage(text: messageText)
            }
            
        })
    }
    
    
}


extension CameraViewController : AVCaptureVideoDataOutputSampleBufferDelegate{
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        if authorizeUser {
            authorizeUser = false
            
            if let image = getImageFromSampleBuffer(buffer: sampleBuffer) {
                
                savedImage = image
                DispatchQueue.main.async {
                    self.dontTakeImageButton.isHidden = false
                    self.createdImageImageView.isHidden = false
                    self.takeImageButton.isHidden = false
                }
                
                
            }
        }
        
        if loginUser {
            loginUser = false
            
            if let image = getImageFromSampleBuffer(buffer: sampleBuffer) {
                checkLogin(forImage: image)
            }
            
        }
    }
    
    
    
    func getImageFromSampleBuffer(buffer:CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                //hier faceDetection
                
                
                DispatchQueue.main.async {
                    self.createdImageImageView.image = UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .leftMirrored)
                }
                
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
            
        }
        
        return nil
    }
    
    func stopCaptureSession () {
        self.captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
    }
}


extension CameraViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        prepareCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopCaptureSession()
    }
    
    
}

