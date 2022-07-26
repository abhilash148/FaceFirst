//
//  FaceView.swift
//  FaceFirst
//
//  Created by Sai Abhilash Gudavalli on 27/07/22.
//

import Foundation
import UIKit
import Vision

struct Laser {
  var origin: CGPoint
  var focus: CGPoint
}

class FaceView: UIView {
  var leftEye: [CGPoint] = []
  var rightEye: [CGPoint] = []
  var leftEyebrow: [CGPoint] = []
  var rightEyebrow: [CGPoint] = []
  var nose: [CGPoint] = []
  var outerLips: [CGPoint] = []
  var innerLips: [CGPoint] = []
  var faceContour: [CGPoint] = []

  var boundingBox = CGRect.zero
  
  func clear() {
    leftEye = []
    rightEye = []
    leftEyebrow = []
    rightEyebrow = []
    nose = []
    outerLips = []
    innerLips = []
    faceContour = []
    
    boundingBox = .zero
    
    DispatchQueue.main.async {
      self.setNeedsDisplay()
    }
  }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
          return
        }
        context.saveGState()
        defer {
          context.restoreGState()
        }
        context.addRect(boundingBox)
        UIColor.red.setStroke()
        context.strokePath()
    }
}

class LaserView: UIView {
  private var lasers: [Laser] = []
  
  func add(laser: Laser) {
    lasers.append(laser)
  }
  
  func clear() {
    lasers.removeAll()
    DispatchQueue.main.async {
      self.setNeedsDisplay()
    }
  }
}
