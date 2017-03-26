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
    
    /** MARK: UI ELEMENTS */
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
    
    //init microsoft api
    let mpoFaceServiceClient = MPOFaceServiceClient(subscriptionKey: microsoftFaceDetectionApiKey)
    
    //authorized user
    var userWantToLoginFaceIds:[String] = []
    
    //camera specific vars
    let captureSession = AVCaptureSession()
    var captureDevice:AVCaptureDevice!
    var tookPhotoAutomatically = false
    
    //save token image by user
    var temporarySavedImage:UIImage?
    
    var firstInfoScreenWasRead = false
    
    /** default state */
    var state = State.login
    
    /** needs toogles */
    var isLoggedIn = false
    var authorizeUser = false
    
    var uploadQueue:[UIImage] = []
    var failedUploadingImages:[String] = []
    
    
    //MARK: BUTTON ACTIONS
    @IBAction func isFirstVisitUnderstandInfoButtonAction(_ sender: Any) {
        hideFirstVisitInfoScreen()
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    /** remove value from upload queue */
    func removeValueFromUploaQueue(number: Int) {
        if uploadQueue.count > number {
            uploadQueue.remove(at: number)
        } else {
            if self.uploadQueue.count == 1 {
                EZLoadingActivity.hide()
            }
        }
    }
    
    /** generates error message for images that can't be uploaded */
    func createErrorMessage() -> String {
        var errorMessage = "Es wurden \(failedUploadingImages.count) abgelehnt. Aufgrung von:\n"
        
        for error in failedUploadingImages {
            errorMessage += "-\(error)\n"
        }
        
        return errorMessage
    }
    
    /** start upload - it's recursive */
    func upload(number: Int) {
        if number < uploadQueue.count {
            authorizeImageOfUser(image: uploadQueue[number]) { (successFullUpload) in
                if self.uploadQueue.count > 0 {
                    self.removeValueFromUploaQueue(number: number)
                    self.upload(number: number)
                    self.updateUI()
                }
            }
        } else {
            
            if self.failedUploadingImages.count == 0 {
                Tools.showMessage(text: savedImageMessage, parentViewController: self)
            } else {
                Tools.showMessage(text: self.createErrorMessage(), parentViewController: self)
                self.failedUploadingImages = []
            }
            
            uploadQueue = []
            EZLoadingActivity.hide()
        }
    }
    
    /** add image to uploadQueue */
    @IBAction func takeImageButtonAction(_ sender: Any) {
        if let image = temporarySavedImage {
    
            uploadQueue.append(image)
            
            if state == .login {
                showCountOfSavedImagesLocally()
                updateUI()
                
                let count = uploadQueue.count + authorizedImagesGlobalArray.count
                if count >= 5 {
                    if uploadQueue.count > 0 {
                        EZLoadingActivity.show(saveProcessMessage, disableUI: true)
                        upload(number: 0)
                    }
                }
            } else {
                if uploadQueue.count > 0 {
                    EZLoadingActivity.show(saveProcessMessage, disableUI: true)
                    upload(number: 0)
                }
            }
        }
        hideDecisionPanel()
    }
    
    /** dont take photo so let it die 🌚*/
    @IBAction func dontTakeImageButtonAction(_ sender: Any) {
        hideDecisionPanel()
    }
    
    /** login when enough images are in storage for authentification  */
    @IBAction func authorizeUserButtonAction(_ sender: Any) {
        if authorizedFaceIdsGlobalArray.count > 4 && state == State.login {
            isLoggedIn = true
            EZLoadingActivity.show(checkFaceMessage, disableUI: true)
        } else {
            authorizeUser = true
        }
    }
    
    /** init camera */
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        if let availableDevices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .front).devices {
            captureDevice = availableDevices.first
            beginSession()
        }
        
    }
    
    /** ios camera stuff */
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
    
    
    //MARK: MICROSOFT API FUNCTIONS
    /** if image of user is valid, start compareImageFromUserWithAuthorizedImages  */
    func checkValidationOfLoginImage(forImage: UIImage) {
        
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
                    self.compareImageFromUserWithAuthorizedImages()
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
    
    
    
    /** save valid image for image management and face id for later login  */
    func authorizeImageOfUser(image: UIImage, completion: @escaping (_ success:Bool) -> Void) {
        
        let imageToData = UIImageJPEGRepresentation(image,1)
        
        mpoFaceServiceClient?.detect(with: imageToData, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: nil, completionBlock: { (faces, error) in
            
            var detectFace = false
            var responseMessage = unknownError
            
            if let faces = faces {
                for face in faces {
                    
                    authorizedFaceIdsGlobalArray.append(face.faceId)
                    authorizedImagesGlobalArray.append(image)
                    Tools.saveFaceIdAndImage(image: image, faceId: face.faceId, keyImage: "\(authorizedImagesGlobalArray.count)_img", keyFaceId: "\(authorizedImagesGlobalArray.count)_faceId")
                    
                    detectFace = true
                }
            }
            
            if error != nil || !detectFace {
                if let error = error?.localizedDescription {
                    responseMessage = error
                } else {
                    responseMessage = noFaceDetectedError
                }
           
                self.failedUploadingImages.append(responseMessage)
            }
            
            completion(detectFace)
        })
    }
    
    
    /** hmmm compare image from user with authorized images 😇*/
    func compareImageFromUserWithAuthorizedImages() {
        
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
    /** hide take / don't take image */
    func hideDecisionPanel() {
        temporarySavedImage = nil
        dontTakeImageButton.isHidden = true
        takeImageButton.isHidden = true
        createdImageImageView.isHidden = true
    }
    
    /** show how many items are in upload queue */
    func showUploadQueueState() {
        showCountOfAuthorizedImagesLabel.alpha = 1.0
        showCountOfAuthorizedImagesLabel.isHidden = false
        
        showCountOfAuthorizedImagesLabel.text = "\(self.uploadQueue.count)"
       
        UIView.animate(withDuration: 0.5, animations: {
            self.showCountOfAuthorizedImagesLabel.alpha = 0.0
        }, completion: { (finished) in
            self.showCountOfAuthorizedImagesLabel.isHidden = true
            self.showCountOfAuthorizedImagesLabel.alpha = 1.0
        })
    }
    
    /** show how many items are in upload queue */
    func showCountOfSavedImagesLocally() {
        showCountOfAuthorizedImagesLabel.alpha = 1.0
        showCountOfAuthorizedImagesLabel.isHidden = false
        
        if state == .login {
            let count = uploadQueue.count + authorizedImagesGlobalArray.count
            showCountOfAuthorizedImagesLabel.text = "\(count)"
        } else {
            showCountOfAuthorizedImagesLabel.text = "\(uploadQueue.count)"
        }
        
        UIView.animate(withDuration: 0.5, animations: {
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
    
    /** reading camera output stream */
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
                checkValidationOfLoginImage(forImage: image)
            }
            
        }
    }
    
    /** get single image */
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
    
    /** has to be called after ending with camera */
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

