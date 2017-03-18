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
    
    
    //camera
    let captureSession = AVCaptureSession()
    var captureDevice:AVCaptureDevice!
    var tookPhotoAutomatically = false
    var temporarySavedImage:UIImage?
    
    
    var firstInfoScreenWasRead = false
    
    
    var state = State.login
    
    /** needs toogles */
    var isLoggedIn = false
    var authorizeUser = false
    
    //MARK: BUTTON ACTIONS
    @IBAction func isFirstVisitUnderstandInfoButtonAction(_ sender: Any) {
        hideFirstVisitInfoScreen()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func takeImageButtonAction(_ sender: Any) {
        if let image = temporarySavedImage {
            authorizeImageOfUser(image: image)
        }
        hideDecisionPanel()
        EZLoadingActivity.show(saveProcessMessage, disableUI: true)
    }
    
    @IBAction func dontTakeImageButtonAction(_ sender: Any) {
        hideDecisionPanel()
    }
    
    @IBAction func authorizeUserButtonAction(_ sender: Any) {
        
        if authorizedFaceIdsGlobalArray.count > 4 && state == State.login {
            isLoggedIn = true
            EZLoadingActivity.show(checkFaceMessage, disableUI: true)
        } else {
            authorizeUser = true
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
            
            var responseMessage = unknownError
            if error != nil {
                if let error = error?.localizedDescription {
                    responseMessage = error
                }
                
                Tools.showMessage(text: responseMessage, parentViewController: self)
            } else {
                if detectFace == true {
                    self.checkUser()
                } else {
                    responseMessage = noFaceDetectedError
                }
            }
            EZLoadingActivity.hide()
            if !detectFace {
                Tools.showMessage(text: responseMessage, parentViewController: self)
            }
        })
        
    }
    
    
    
  
    
    
    
    
    func authorizeImageOfUser(image: UIImage) {
        
        let imageToData = UIImageJPEGRepresentation(image,1)
        
        mpoFaceServiceClient?.detect(with: imageToData, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: nil, completionBlock: { (faces, error) in
            
            var detectFace = false

            if let faces = faces {
                for face in faces {
                  
                    authorizedFaceIdsGlobalArray.append(face.faceId)
                    authorizedImagesGlobalArray.append(image)
                    
                    Tools.saveFaceIdAndImage(image: image, faceId: face.faceId, keyImage: "\(authorizedImagesGlobalArray.count)_img", keyFaceId: "\(authorizedImagesGlobalArray.count)_faceId")
                    
                    detectFace = true
                }
            }
            
            
            var responseMessage = unknownError
            if error != nil {
                
                if let error = error?.localizedDescription {
                    responseMessage = error
                }
                
                Tools.showMessage(text: responseMessage, parentViewController: self)
            } else {
                
                
                if detectFace == true {
                    responseMessage = savedImageMessage
                    
                    self.showYesOrNoIfUserWantTakeOrDontTakeHisImage()
                    self.updateUI()
                } else {
                    responseMessage = noFaceDetectedError
                }
            }
            EZLoadingActivity.hide()
            Tools.showMessage(text: responseMessage, parentViewController: self)
        })
    }
    
    
    func checkUser() {
        
        mpoFaceServiceClient?.findSimilar(withFaceId: userWantToLoginFaceIds[userWantToLoginFaceIds.count-1], faceIds: authorizedFaceIdsGlobalArray, completionBlock: { (similarFaces, error) in
            
            EZLoadingActivity.hide()
            var findSimilarFace = false
            var responseMessage = unknownError
            
            if error != nil {
                if let error = error {
                    responseMessage = error.localizedDescription
                }
            } else {
                
                if let similarFaces = similarFaces {
                    for similarFace in similarFaces {
                        if Double(similarFace.confidence) > 0.8 {
                            findSimilarFace = true
                        } else {
                            responseMessage = noConfidenceError
                        }
                    }
                }
            }
            
            if findSimilarFace {
                if let vc = self.storyboard?.instantiateViewController(withIdentifier: secretAreaViewControllerIdent) as? SecretAreaViewController {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                Tools.showMessage(text: responseMessage, parentViewController: self)
            }
        })
    }
    
    
    
    //MARK: UI specific functions
    func needToShowInfoScreen() {
        firstInfoScreenWasRead = UserDefaults.standard.bool(forKey: firstInfoScreenWasReadKey)
        
        if !firstInfoScreenWasRead {
            showFirstVisitInfoScreen()
        } else {
            hideFirstVisitInfoScreen()
        }
    }
    
    func hasBackButton() {
        if state == .login {
            backButton.isHidden = true
        }
    }
    
    func updateUI() {
        if state == .login {
            
            temporarySavedImage = nil
            createdImageImageView.isHidden = true
            dontTakeImageButton.isHidden = true
            takeImageButton.isHidden = true
            
            if authorizedFaceIdsGlobalArray.count > 4 {
                self.authorizeUserButton.setTitle("Einloggen per Foto", for: .normal)
                self.authorizeUserButton.setTitleColor(UIColor.white, for: .normal)
                self.authorizeUserButton.backgroundColor = UIColor(red: CGFloat(99.0/255.0), green: CGFloat(130.0/255.0), blue: CGFloat(255.0/255.0), alpha: CGFloat(1))
            } else {
                self.authorizeUserButton.setTitle("Foto hinterlegen", for: .normal)
                self.authorizeUserButton.setTitleColor(UIColor.white, for: .normal)
                self.authorizeUserButton.backgroundColor = UIColor(red: CGFloat(170.0/255.0), green: CGFloat(170.0/255.0), blue: CGFloat(170.0/255.0), alpha: CGFloat(1))
            }
        }
    }
    
    func hideDecisionPanel() {
        temporarySavedImage = nil
        dontTakeImageButton.isHidden = true
        takeImageButton.isHidden = true
        createdImageImageView.isHidden = true
    }
    
    func showYesOrNoIfUserWantTakeOrDontTakeHisImage() {
        showCountOfAuthorizedImagesLabel.alpha = 1.0
        showCountOfAuthorizedImagesLabel.isHidden = false
        showCountOfAuthorizedImagesLabel.text = "\(authorizedImagesGlobalArray.count)"
        
        
        UIView.animate(withDuration: 1.5, animations: {
            self.showCountOfAuthorizedImagesLabel.alpha = 0.0
        }, completion: { (finished) in
            self.showCountOfAuthorizedImagesLabel.isHidden = true
            self.showCountOfAuthorizedImagesLabel.alpha = 1.0
        })
    }
    
    
    /** hide info screen that user needs five images to login */
    func hideFirstVisitInfoScreen() {
        isFirstVisitUnderstandInfoButton.isHidden = true
        isFirstVisitInfoLabel.isHidden = true
        isFirstVisitBackgroundView.isHidden = true
        
        firstInfoScreenWasRead = true
        UserDefaults.standard.set(firstInfoScreenWasRead, forKey: firstInfoScreenWasReadKey)
    }
    
    /** show info screen that user needs five images to login */
    func showFirstVisitInfoScreen() {
        isFirstVisitUnderstandInfoButton.isHidden = false
        isFirstVisitInfoLabel.isHidden = false
        isFirstVisitBackgroundView.isHidden = false
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
        
        if isLoggedIn {
            isLoggedIn = false
            
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
        updateUI()
        hasBackButton()
        needToShowInfoScreen()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopCaptureSession()
    }
    
    
}

