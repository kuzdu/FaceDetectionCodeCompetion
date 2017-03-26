//
//  GlobalVars.swift
//  FaceDetectionCodeCompetion
//
//  Created by Michael Rothkegel on 12.03.17.
//  Copyright © 2017 Michael Rothkegel. All rights reserved.
//

import UIKit

//save face ids and images of user
var authorizedFaceIdsGlobalArray: [String] = []
var authorizedImagesGlobalArray: [UIImage] = []

//API KEY for microsoft API
let microsoftFaceDetectionApiKey = "7a3bad27eb4d41849eb86bb8cf310c86"



//normal messages
let saveProcessMessage = "Uploading...📸"
let savedImageMessage = "Das Bild wurde gepspeichert und die ID erfolgreich hinterlegt. 🍯"
let checkFaceMessage = "Kontrolliere Gesicht...🕵️"


//error messages
let noFaceDetectedError = "Auf dem Foto wurde kein Gesicht erkannt.🙈"
let noCameraPermissionError = "Aktiviere die Kamera. Sonst bietet diese App keinerlei mehrwert.😞"
let noConfidenceError = "Die Übereinstimmung reichte nicht, versuch es nochmal.😎 ... \nEin Passwort zuschicken geht nämlich nicht. 🙈"
let unknownError = "Ein unbekannter Fehler ist aufgetreten. 🚀"
let minimumOneImageError = "Es muss mindestens ein Foto hinterlegt sein.🦆"



//save storage keys
let userGaveAlreadyCameraPermissionKey = "userGaveAlreadyCameraPermission"
let numberOfImagesKey = "numberOfImages"
let firstInfoScreenWasReadKey = "firstInfoScreenWasRead"
let inputInTextViewInSecretAreaTextKey = "inputInTextViewInSecretAreaText"

//identifier to jump between viewControllers programmatically
let messageScreenViewControllerIdent = "MessageScreenViewController"
let cameraViewControllerIdent = "CameraViewController"
let secretAreaViewControllerIdent = "SecretAreaViewController"
let imageManagementViewControllerIdent = "ImageManagementViewController"
let imageManagementCellIdent = "ImageManagementIdent"
