//
//  ImageAndTwoButtonsTableViewCell.swift
//  FaceDetectionCodeCompetion
//
//  Created by Michael Rothkegel on 12.03.17.
//  Copyright © 2017 Michael Rothkegel. All rights reserved.
//

import Foundation
import UIKit


class ImageAndTwoButtonsTableViewCell : UITableViewCell {
    
    
    var deleteCallBack: (() -> Void)?
    
    @IBOutlet weak var faceImageView: UIImageView!
    
    @IBAction func showImageInBigButtonAction(_ sender: Any) {
    
    
    }
    
    
    @IBAction func deleteImageButtonAction(_ sender: Any) {
        deleteCallBack?()
    }
    
    
    override func awakeFromNib() {
        
        
        //make image clickable two
    }
    
    
}
