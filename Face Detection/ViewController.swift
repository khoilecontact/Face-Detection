//
//  ViewController.swift
//  Face Detection
//
//  Created by KhoiLe on 02/11/2021.
//

import UIKit
import Vision

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    var imageOrientation = CGImagePropertyOrientation(.up)
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let image = UIImage(named: "group") {
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            imageOrientation = CGImagePropertyOrientation(image.imageOrientation)
            
            guard let cgImage = image.cgImage else { return }
            
            setupVision(image: cgImage)
        }
    }
    
    /// Setup the vision to send request and handler it
    private func setupVision (image: CGImage) {
        let faceDetectionRequest = VNDetectFaceRectanglesRequest(completionHandler: self.faceDetectionHandler)
        
        let imageRequestHandler = VNImageRequestHandler(cgImage: image, orientation: imageOrientation, options: [:])
        
        do {
            try imageRequestHandler.perform([faceDetectionRequest])
        } catch let error as NSError {
            print("Error in sending Vision Request: \(error)")
            return
        }
    }
    
    /// A function of completionHandler of VNDetectFaceRectanglesRequest
    private func faceDetectionHandler(request: VNRequest?, error: Error?) {
        if let error = error as? NSError {
            print("Error in Face Detection Error \(error)")
            return
        }
        
        guard let image = imageView.image else { return }
        guard let cgImage = image.cgImage else { return }
        
        // Determine the scale
        let imageRect = self.determineScale(cgImage: cgImage, imageViewFrame: imageView.frame)
        
        self.imageView.layer.sublayers = nil
        
        if let results = request?.results as? [VNFaceObservation] {
            for observation in results {
                let faceRect = convertUnitToPoint(originalImageRect: imageRect, targetRect: observation.boundingBox)
                
                let emojiRect = CGRect(x: faceRect.origin.x,
                                       y: faceRect.origin.y - 5,
                                       width: faceRect.size.width + 10,
                                       height: faceRect.size.height + 10)
                
                let textLayer = CATextLayer()
                textLayer.string = "😎"
                textLayer.fontSize = faceRect.width
                textLayer.frame = emojiRect
                textLayer.contentsScale = UIScreen.main.scale
                
                self.imageView.layer.addSublayer(textLayer)
            }
        }
    }


}

