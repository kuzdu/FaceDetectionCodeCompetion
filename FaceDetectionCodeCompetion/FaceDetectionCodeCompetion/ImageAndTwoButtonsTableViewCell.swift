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
    var tapImageCallBack: (() -> Void)?
    
    @IBOutlet weak var faceImageView: UIImageView!
    
    @IBAction func showImageInBigButtonAction(_ sender: Any) {
        showImageInBig()
    }
    
    @IBAction func deleteImageButtonAction(_ sender: Any) {
        deleteCallBack?()
    }
    
    func showImageInBig() {
        tapImageCallBack?()
    }
    
    override func awakeFromNib() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showImageInBig))
        faceImageView.isUserInteractionEnabled = true
        faceImageView.addGestureRecognizer(tap)
    }
    
}
