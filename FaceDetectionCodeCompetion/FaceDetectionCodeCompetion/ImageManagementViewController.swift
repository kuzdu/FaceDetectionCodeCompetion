//
//  ImageManagementViewController.swift
//  FaceDetectionCodeCompetion
//
//  Created by Michael Rothkegel on 12.03.17.
//  Copyright © 2017 Michael Rothkegel. All rights reserved.
//

import UIKit

class ImageManagementViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backButtonAction(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func addNewImageButtonAction(_ sender: Any) {
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as? CameraViewController {
            vc.state = "authorisation"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
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
        return authorizedImages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ImageManagementIdent") as? ImageAndTwoButtonsTableViewCell {
            
            if authorizedImages.count > indexPath.row {
                cell.imageView?.image = authorizedImages[indexPath.row]
            }
            
            let debug = authorizedImages.count
            print("Debug \(debug)")
            let debug2 = indexPath.row
            print("Debug 2 \(debug2)")
            
            cell.deleteCallBack = {
                if authorizedImages.count > indexPath.row {
                    authorizedImages.remove(at: indexPath.row)
                    
                    let debug3 = indexPath.row
                    print("Debug 3 \(debug3)")
                    
                    Tools.removeImageAndFaceId(keyImage: "\(indexPath.row+1)_img", keyFaceId: "\(indexPath.row+1)_faceId")
                    self.tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .automatic)
                } else {
                
                    Tools.showMessage(text: "Es muss mindestens ein Foto hinterlegt sein.", parentViewController: self)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
