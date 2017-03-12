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



class CameraViewController: UIViewController {
    
    //MARK: UI ELEMENTS
    /** */
    @IBOutlet weak var createdImageImageView: UIImageView!
    @IBOutlet weak var isFirstVisitUnderstandInfoButton: UIButton!
    @IBOutlet weak var isFirstVisitInfoLabel: UILabel!
    @IBOutlet weak var isFirstVisitBackgroundView: UIView!
    
    /** UI-Element where the preview of camera is */
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var authorizeUserButton: UIButton!
    @IBOutlet weak var takeImageButton: UIButton!
    @IBOutlet weak var dontTakeImageButton: UIButton!
    
    @IBOutlet weak var showCountOfAuthorizedImagesLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    //MARK: VARS
    //Microsoft Api
    let mpoFaceServiceClient = MPOFaceServiceClient(subscriptionKey: microsoftFaceDetectionApiKey)
    
    //authorized user
    var userWantToLoginFaceIds:[String] = []
    
    var isFirstVisitSoShowInformationView = true
    
    //camera
    let captureSession = AVCaptureSession()
    var captureDevice:AVCaptureDevice!
    var tookPhotoAutomatically = false
    var temporarySavedImage:UIImage?
    
    /**
     three states
     login = take image and login with that
     authorisation = fill array with images
     */
    var state = "login"
    
    /** needs toogles */
    var loginUser = false
    var authorizeUser = false
    
    
    
    
    //MARK: BUTTON ACTIONS
    @IBAction func isFirstVisitUnderstandInfoButtonAction(_ sender: Any) {
        isFirstVisitSoShowInformationView = false
        isFirstVisitUnderstandInfoButton.isHidden = true
        isFirstVisitInfoLabel.isHidden = true
        isFirstVisitBackgroundView.isHidden = true
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func takeImageButtonAction(_ sender: Any) {
        
        hideDecisionPanel()
        
        if let image = temporarySavedImage {
            authorizeImageOfUser(image: image)
        }
        
        EZLoadingActivity.show("Sichere Foto...📸", disableUI: true)
        
    }
    
    
    func hideDecisionPanel() {
        dontTakeImageButton.isHidden = true
        takeImageButton.isHidden = true
        createdImageImageView.isHidden = true
    }
    
    func showCountOfAuthorizedImages() {
        showCountOfAuthorizedImagesLabel.alpha = 1.0
        showCountOfAuthorizedImagesLabel.isHidden = false
        showCountOfAuthorizedImagesLabel.text = "\(authorizedImages.count)"
        
        
        UIView.animate(withDuration: 1.5, animations: {
            self.showCountOfAuthorizedImagesLabel.alpha = 0.0
        }, completion: { (finished) in
            self.showCountOfAuthorizedImagesLabel.isHidden = true
            self.showCountOfAuthorizedImagesLabel.alpha = 1.0
        })
    }
    
    @IBAction func dontTakeImageButtonAction(_ sender: Any) {
        hideFirstVisitInfoScreen()
    }
    
    @IBAction func authorizeUserButtonAction(_ sender: Any) {
        
        if authorizedFaceIds.count > 4 && state == "login" {
            loginUser = true
            EZLoadingActivity.show("Kontrolliere Gesicht...🕵️", disableUI: true)
        } else {
            authorizeUser = true
        }
    }
    
    func hideFirstVisitInfoScreen() {
        temporarySavedImage = nil
        createdImageImageView.isHidden = true
        dontTakeImageButton.isHidden = true
        takeImageButton.isHidden = true
    }
    
    func showFirstVisitInfoScreen() {
        if isFirstVisitSoShowInformationView {
            isFirstVisitUnderstandInfoButton.isHidden = false
            isFirstVisitInfoLabel.isHidden = false
            isFirstVisitBackgroundView.isHidden = false
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
            
            var responseMessage = ""
            if error != nil {
                
                responseMessage = "Ein unbekannter Fehler ist aufgetreten.🚀"
                if let error = error?.localizedDescription {
                    responseMessage = error
                }
                
                Tools.showMessage(text: responseMessage, parentViewController: self)
            } else {
                if detectFace == true {
                    self.checkUser()
                } else {
                    responseMessage = "Auf dem Foto wurde kein Gesicht erkannt.🙈"
                }
            }
            EZLoadingActivity.hide()
            if !detectFace {
                Tools.showMessage(text: responseMessage, parentViewController: self)
            }
        })
        
    }
    
    func updateUI() {
        if state == "login" {
            showCountOfAuthorizedImages()
            
            if authorizedFaceIds.count > 4 {
                
                
                self.authorizeUserButton.setTitle("Einloggen per Foto", for: .normal)
                self.authorizeUserButton.setTitleColor(UIColor.white, for: .normal)
                self.authorizeUserButton.backgroundColor = UIColor(red: CGFloat(99.0/255.0), green: CGFloat(130.0/255.0), blue: CGFloat(255.0/255.0), alpha: CGFloat(1))
            }
        }
        
    }
    
    func authorizeImageOfUser(image: UIImage) {
        
        let imageToData = UIImageJPEGRepresentation(image,1)
        
        mpoFaceServiceClient?.detect(with: imageToData, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: nil, completionBlock: { (faces, error) in
            
            var detectFace = false
            //should always be just one
            if let faces = faces {
                for face in faces {
                    authorizedFaceIds.append(face.faceId)
                    authorizedImages.append(image)
                    detectFace = true
                }
            }
            
            
            var responseMessage = ""
            if error != nil {
                
                responseMessage = "Ein unbekannter Fehler ist aufgetreten.🚀"
                if let error = error?.localizedDescription {
                    responseMessage = error
                }
                
                Tools.showMessage(text: responseMessage, parentViewController: self)
            } else {
                
                
                if detectFace == true {
                    responseMessage = "Das Bild wurde gepspeichert und die ID erfolgreich hinterlegt. 🍯"
                    
                    self.updateUI()
                    
                } else {
                    responseMessage = "Auf dem Foto wurde kein Gesicht erkannt.🙈"
                }
            }
            EZLoadingActivity.hide()
            Tools.showMessage(text: responseMessage, parentViewController: self)
        })
    }
    
    func checkUser() {
        
        mpoFaceServiceClient?.findSimilar(withFaceId: userWantToLoginFaceIds[userWantToLoginFaceIds.count-1], faceIds: authorizedFaceIds, completionBlock: { (similarFaces, error) in
            
            EZLoadingActivity.hide()
            var findSimilarFace = false
            var responseMessage = "Ein unbekannter Fehler ist aufgetreten. 🚀"
            
            if error != nil {
                if let error = error {
                    responseMessage = error.localizedDescription
                }
            } else {
                for similarFace in similarFaces! {
                    print("the confidence \(similarFace.confidence)")
                    
                    if Double(similarFace.confidence) > 0.8 {
                        findSimilarFace = true
                    } else {
                        responseMessage = "Die Übereinstimmung reichte nicht, versuch es nochmal.😎 ... \nEin Passwort zuschicken geht nämlich nicht. 🙈"
                    }
                }
            }
            
            if findSimilarFace {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: "SecretAreaViewController") as? SecretAreaViewController {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                Tools.showMessage(text: responseMessage, parentViewController: self)
            }
        })
    }
    
    
}


extension CameraViewController : AVCaptureVideoDataOutputSampleBufferDelegate{
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        
        
        if authorizeUser {
            authorizeUser = false
            
            if let image = getImageFromSampleBuffer(buffer: sampleBuffer) {
                
                temporarySavedImage = image
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
        print("state \(state)")
        if state == "login" {
            showFirstVisitInfoScreen()
        } else {
            hideFirstVisitInfoScreen()
        }
        
        
        prepareCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopCaptureSession()
    }
    
    
}

