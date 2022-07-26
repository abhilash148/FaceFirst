//
//  ViewController.swift
//  FaceFirst
//
//  Created by Sai Abhilash Gudavalli on 27/07/22.
//

import UIKit
import AVFoundation
import Vision
import Foundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet var faceView: FaceView!
    @IBOutlet var laserView: LaserView!
    @IBOutlet var faceLaserLabel: UILabel!
    
    let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    let dataOutputQueue = DispatchQueue(
        label: "video data queue",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)
    
    var faceViewHidden = false
    var sequenceHandler = VNSequenceRequestHandler()
    
    var maxX: CGFloat = 0.0
    var midY: CGFloat = 0.0
    var maxY: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCaptureSession()
        laserView.isHidden = true
        maxX = view.bounds.maxX
        midY = view.bounds.midY
        maxY = view.bounds.maxY
        
        session.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
          return
        }
        let detectFaceRequest = VNDetectFaceRectanglesRequest(completionHandler: detectedFace)
        do {
          try sequenceHandler.perform(
            [detectFaceRequest],
            on: imageBuffer,
            orientation: .leftMirrored)
        } catch {
          print(error.localizedDescription)
        }
    }
    
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        faceView.isHidden.toggle()
        laserView.isHidden.toggle()
        faceViewHidden = faceView.isHidden
        
        if faceViewHidden {
            faceLaserLabel.text = "Lasers"
        } else {
            faceLaserLabel.text = "Face"
        }
    }
    
    func configureCaptureSession() {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .front) else {
            return
        }
        
        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            session.addInput(cameraInput)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        
        session.addOutput(videoOutput)
        self.setVideoConnection(videoOutput)
    }
    
    func setVideoConnection(_ output: AVCaptureVideoDataOutput) {
        let videoConnection = output.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    func convert(rect: CGRect) -> CGRect {
      let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
        let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
      return CGRect(origin: origin, size: CGSize())
    }
    
    func detectedFace(request: VNRequest, error: Error?) {
      guard
        let results = request.results as? [VNFaceObservation],
        let result = results.first
        else {
          faceView.clear()
          return
      }
      let box = result.boundingBox
      faceView.boundingBox = convert(rect: box)
      DispatchQueue.main.async {
        self.faceView.setNeedsDisplay()
      }
    }
}

