//
//  ViewController.swift
//  SmileSwift
//
//  Created by Ken Tominaga on 11/7/14.
//  Copyright (c) 2014 Ken Tominaga. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet private weak var outputTextView: UITextView!
    @IBOutlet private weak var sampleImageView: UIImageView!
    
    
    /** 画像取得用 */
   // var picker:UIImagePickerController?
    /** 画像認識 */
    var detector:CIDetector?
    
    //撮った写真の最初の状態を保持
    var originalImage: UIImage!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //detectFaces()
    }
    
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func detectFaces() {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) {
            
            // create CGImage from image on storyboard.
            guard let image = self.sampleImageView.image, cgImage = image.CGImage else {
                return
            }
            
            let ciImage = CIImage(CGImage: cgImage)
            
            // set CIDetectorTypeFace.
            let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
            
            // set options
            let options = [CIDetectorSmile : true, CIDetectorEyeBlink : true]
            
            // get features from image
            let features = detector.featuresInImage(ciImage, options: options)
            
            var resultString = "DETECTED FACES:\n\n"
            
            for feature in features as! [CIFaceFeature] {
                resultString.appendContentsOf("bounds: \(NSStringFromCGRect(feature.bounds))\n")
                resultString.appendContentsOf("hasSmile: \(feature.hasSmile ? "YES" : "NO")\n")
                resultString.appendContentsOf("faceAngle: \(feature.hasFaceAngle ? String(feature.faceAngle) : "NONE")\n")
                resultString.appendContentsOf("leftEyeClosed: \(feature.leftEyeClosed ? "YES" : "NO")\n")
                resultString.appendContentsOf("rightEyeClosed: \(feature.rightEyeClosed ? "YES" : "NO")\n")
                
                resultString.appendContentsOf("\n")
            }
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.outputTextView.text = "\(resultString)"
            }
        }
    }
    @IBAction func takePhoto() {
        
        //カメラが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
            //カメラを起動する
            let picker = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            
            //カメラを自由な形に開きたいとき（今回は正方形）
            picker.allowsEditing = true

            
            presentViewController(picker, animated: true, completion: nil)
            
        } else {
            
            //カメラが利用できない時はerrorがコンソールに表示される
            print("error")
        }
                //detectFaces()
    }

    @IBAction func  album() {
        //カメラロールが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            //カメラを自由な形に開きたいとき（今回は正方形）
            picker.allowsEditing = true
            
            self.outputTextView.text = ""
            
            //アプリ画面へ戻る
            self.presentViewController(picker, animated: true, completion: nil)
                   // detectFaces()
        }
        
        
    }
    //カメラを起動して撮影が終わったときに呼ばれるメソッド
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        sampleImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        //撮った写真を最初の画像として記憶しておく
        originalImage = sampleImageView.image
    
        self.outputTextView.text = ""
        dismissViewControllerAnimated(true, completion: nil) //アプリ画面へ　戻る
    }
}


