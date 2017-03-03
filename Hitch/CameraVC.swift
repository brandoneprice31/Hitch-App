//
//  CameraVC.swift
//  Hitch
//
//  Created by Brandon Price on 1/28/17.
//  Copyright © 2017 BEPco. All rights reserved.
//

import UIKit
import AVFoundation

class CameraVC: UIViewController {
    
    // Camera Properties.
    var session: AVCaptureSession?
    var input: AVCaptureDeviceInput?
    var output: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var tempImage = UIImage()
    
    // IBOutlets.
    @IBOutlet var triggerButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var retryButton: UIButton!
    @IBOutlet var hiddenView: UIView!
    
    // View did load.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initialize session an output variables this is necessary
        session = AVCaptureSession()
        output = AVCaptureStillImageOutput()
        let camera = getDevice(position: .front)
        do {
            input = try AVCaptureDeviceInput(device: camera)
        } catch let error as NSError {
            print(error)
            input = nil
        }
        
        // If we can add an input.
        if(session?.canAddInput(input) == true){
            session?.addInput(input)
            output?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            if(session?.canAddOutput(output) == true){
                session?.addOutput(output)
                previewLayer = AVCaptureVideoPreviewLayer(session: session)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                previewLayer?.frame = view.bounds
                view.layer.addSublayer(previewLayer!)
                session?.startRunning()
            }
        }
        
        // Do any additional setup after loading the view.
        saveButton.layer.cornerRadius = 5.0
        retryButton.layer.cornerRadius = 5.0
        self.view.bringSubview(toFront: triggerButton)
        hiddenView.alpha = 0.0
        self.view.bringSubview(toFront: hiddenView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Get the device (Front or Back)
    func getDevice(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devices() as NSArray
        for de in devices {
            let deviceConverted = de as! AVCaptureDevice
            if(deviceConverted.position == position){
                return deviceConverted
            }
        }
        return nil
    }
    
    // Trigger button clicked.
    @IBAction func triggerClicked(_ sender: Any) {
        
        // Change color of trigger button and bring up back button.
        UIView.animate(withDuration: 0.1, animations: {
            
            self.triggerButton.alpha = 0.0
            self.hiddenView.alpha = 1.0
        })
        
        // Capture the image.
        if let videoConnection : AVCaptureConnection = output?.connection(withMediaType: AVMediaTypeVideo) {
                
            if videoConnection.isVideoOrientationSupported{
                videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            }
                
            // Capture it.
            output?.captureStillImageAsynchronously(from: videoConnection) { (imageDataSampleBuffer, error) -> Void in
                    
                // Get the image data.
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                    
                // Stop session.
                self.session?.stopRunning()
                    
                // Save image to temp.
                let image = (UIImage(data: imageData!))!
                self.tempImage = image
            }
        }
    }
    
    @IBAction func retryButtonClicked(_ sender: Any) {
        
        // Retry taking a picture.
        UIView.animate(withDuration: 0.1, animations: {
            self.triggerButton.alpha = 1.0
            self.hiddenView.alpha = 0.0
        })
        
        // Restart session.
        session?.startRunning()
    }

    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        // Send image to previous view controller.
        let personInfoVC : PersonalInfoSignUpVC = self.navigationController?.viewControllers[(self.navigationController?.viewControllers.index(of: self))! - 1] as! PersonalInfoSignUpVC
        
        personInfoVC.profileImage = tempImage
        
        // Present previous view controller.
        let _ = self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
