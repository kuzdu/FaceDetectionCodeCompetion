//
//  ImageManagementViewController.swift
//  FaceDetectionCodeCompetion
//
//  Created by Michael Rothkegel on 12.03.17.
//  Copyright © 2017 Michael Rothkegel. All rights reserved.
//

import UIKit

class ImageManagementViewController: UIViewController {
    
    //MARK: UI
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: BUTTON ACTIONS
    @IBAction func backButtonAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addNewImageButtonAction(_ sender: Any) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: cameraViewControllerIdent) as? CameraViewController {
            vc.state = .authorisation
            navigationController?.pushViewController(vc, animated: true)
        }
    }
  
    //MARK: INNER LOGIC
    func dismissImage(tapGestureRecognizer: UITapGestureRecognizer) {
        if let tappedImage = tapGestureRecognizer.view as? UIImageView {
            tappedImage.removeFromSuperview()
        }
    }
    
    /** show image to full size by tap */
    func showImageByTap(_ image: UIImage, view: UIView) {
        let newImageView = UIImageView(frame:CGRect(x: 0,y: 0, width: view.frame.width, height: view.frame.height))
        newImageView.autoresizingMask = [.flexibleBottomMargin,.flexibleHeight,.flexibleRightMargin,.flexibleLeftMargin,.flexibleTopMargin,.flexibleWidth]
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        newImageView.backgroundColor = UIColor(red: 0, green: 0.0, blue: 0.0, alpha: 0.5)
        newImageView.image = image
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissImage(tapGestureRecognizer:)))
        newImageView.addGestureRecognizer(tap)
        view.addSubview(newImageView)
    }
    
    
    /** configuration of table view */
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 99.0
        tableView.reloadData()
        tableView.tableFooterView = UIView()
    }
    
}
extension ImageManagementViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return authorizedImagesGlobalArray.count
    }
    
    
    /** show all uploaded images */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: imageManagementCellIdent) as? ImageAndTwoButtonsTableViewCell {
            
            //show images
            if authorizedImagesGlobalArray.count > indexPath.row {
                cell.imageView?.image = authorizedImagesGlobalArray[indexPath.row]
            }
            
            //show image in a big size
            cell.tapImageCallBack = {
                if authorizedImagesGlobalArray.count > indexPath.row {
                    self.showImageByTap(authorizedImagesGlobalArray[indexPath.row], view: self.view)
                }
            }
            
            //show delete images
            cell.deleteCallBack = {
                if authorizedImagesGlobalArray.count > indexPath.row && authorizedImagesGlobalArray.count != 1 {
                   
                    authorizedImagesGlobalArray.remove(at: indexPath.row)
                    authorizedFaceIdsGlobalArray.remove(at: indexPath.row)
                  
                    //need plus 1: when the keys will be save the counter starts with 1, row counter begin with 0
                    Tools.removeImageAndFaceId(keyImage: "\(indexPath.row+1)_img", keyFaceId: "\(indexPath.row+1)_faceId")
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        self.tableView.beginUpdates()
                        self.tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .automatic)
                        self.tableView.endUpdates()
                    }, completion: { (finished) in
                   
                        let oldDatasFace = authorizedFaceIdsGlobalArray
                        authorizedFaceIdsGlobalArray = []
                        let oldDataImage = authorizedImagesGlobalArray
                        authorizedImagesGlobalArray = []
                        
                        for i in 0..<oldDatasFace.count {
                            
                            authorizedFaceIdsGlobalArray.append(oldDatasFace[i])
                            authorizedImagesGlobalArray.append(oldDataImage[i])
                            Tools.saveFaceIdAndImage(image: oldDataImage[i], faceId: oldDatasFace[i], keyImage: "\(i)_img", keyFaceId: "\(i)_faceId")
                        }
                        
                        self.tableView.reloadData()
                    })
                    
                } else {
                    Tools.showMessage(text: minimumOneImageError, parentViewController: self)
                }
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
}


extension ImageManagementViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        configureTableView()
    }
    
}
