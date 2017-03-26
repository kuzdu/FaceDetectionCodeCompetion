//
//  Enums.swift
//  FaceDetectionCodeCompetion
//
//  Created by Michael Rothkegel on 16.03.17.
//  Copyright © 2017 Michael Rothkegel. All rights reserved.
//

import Foundation



/**
 two states for CameraViewController

 login: has some other UI interactions and images are saving in a queue for upload
 authorisation: one image = one upload
 */

enum State : String {
    case login = "State"
    case authorisation = "Authorisation"
}
