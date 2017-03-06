//
//  ViewController.swift
//  FaceDetectionCodeCompetion
//
//  Created by Michael Rothkegel on 06.03.17.
//  Copyright © 2017 Michael Rothkegel. All rights reserved.
//

import UIKit
import ProjectOxfordFace


let faceDetectionApiKey = "7a3bad27eb4d41849eb86bb8cf310c86"

class ViewController: UIViewController {
    
    
    let test = MPOFaceServiceClient(subscriptionKey: faceDetectionApiKey)
    
    var myFaceIds:[String] = []
    //  test2.faceId
    var otherFaceIds: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let data = UIImageJPEGRepresentation(UIImage(named:"billgates1")!,1)
        
        test?.detect(with: data, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: nil, completionBlock: { (faces, error) in
            
            
            for face in faces! {
                self.myFaceIds.append(face.faceId)
                print("known: \(face.faceId)")
            }
        
            
            let data2 = UIImageJPEGRepresentation(UIImage(named:"billgates2")!, 1)
            
            self.test?.detect(with: data2, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: nil, completionBlock: { (faces, error) in
                
                
                for face in faces! {
                    self.otherFaceIds.append(face.faceId)
                    print("unknownFace: \(face.faceId)")
                }
                
                self.tester()
                
            })
            
            
        })
        
        
      
        
        
        
        
        
        
        
    
    }
    
    func tester() {
        
        let debug1 = myFaceIds
        let debug2 = otherFaceIds
        
      
        
        
        test?.findSimilar(withFaceId: myFaceIds[0], faceIds: otherFaceIds, completionBlock: { (similarFaces, error) in
            
            print("the cound \(similarFaces?.count)")
            
            for similarFace in similarFaces! {
                let personface = MPOPersonFace().faceId = similarFace.faceId
                
                
                print("the confidence \(similarFace.confidence)")
                
            }
            //
            //            MPOSimilarFace * result = collection[i];
            //            UIImageView * imageView = [[UIImageView alloc] initWithImage:((PersonFace*)[self faceForId:result.faceId]).image];
            //
            
            
            //            let image = UIImage(Person)
            
            print("error \(error)")
        })
        
        
//        test?.findSimilar(withFaceId: myFaceIds[0], faceListId: otherFaceIds[0], maxNumOfCandidatesReturned: 1, mode: MPOSimilarFaceSearchingMode.init(1), completionBlock: { (mpoSimilarFace, error) in
//            
//            
//            let debug = mpoSimilarFace
//        
//            print("the error \(error)")
//            
//            
//        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

