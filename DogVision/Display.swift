//
//  Display.swift
//  Dog Vision
//
//  Created by Saju Pillai on 7/9/22.
//

import SwiftUI
import AVFoundation
import CoreGraphics
import VideoToolbox



class Screen: NSObject, ObservableObject {
    static let singleton = Screen()
    
    @Published var current_frame: CVPixelBuffer?
    
    let video_output_queue = DispatchQueue(
        label: "org.srp.umwelt.video_output_q",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem)
    
    private override init() {
        super.init()
        Camera.singleton.set(self, queue: video_output_queue)
    }
}

extension Screen: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
                     from connection: AVCaptureConnection) {
    if let buffer = sampleBuffer.imageBuffer {
      DispatchQueue.main.async {
        self.current_frame = buffer
      }
    }
  }
}


class Display: ObservableObject {
    @Published var current_frame: CGImage?
    @Published var err_str: String?
    var dog_vision = false
    
    private let camera = Camera.singleton;
    private let screen = Screen.singleton;
    
    private let context = CIContext()
    
    init() {
        /* listen for error messages dispatched from the Camera and display them */
        camera.$err_str
            .receive(on: RunLoop.main)
            .map { $0 }
            .assign(to: &$err_str)
        
        
        screen.$current_frame
            .receive(on: RunLoop.main)
            .compactMap { $0 }
            .compactMap { buffer in
                var cg_image: CGImage?

                
                VTCreateCGImageFromCVPixelBuffer(buffer, options: nil, imageOut: &cg_image)
                guard let image:CGImage = cg_image else {
                    return nil
                }
                
                if (self.dog_vision) {
                    var ci_image = CIImage(cgImage: image)
                    let colorPolynomialParams : [String : AnyObject]
                                = [kCIInputImageKey: ci_image,
                                   "inputRedCoefficients" : CIVector(x: 0.0, y: 0.0, z: 0.0, w: 0.0),
                                   "inputGreenCoefficients" : CIVector(x: 0.0, y: 1.0, z: 0.0, w: 0.0),
                                   "inputBlueCoefficients" : CIVector(x: 0.0, y: 1.0, z: 0.0, w: 0.0),
                                   "inputAlphaCoefficients" : CIVector(x: 0.0, y: 1.0, z: 0.0, w: 0.0)]

                    let colorPolynomial = CIFilter(name: "CIColorPolynomial", parameters: colorPolynomialParams);
                    ci_image = colorPolynomial?.outputImage ?? ci_image
                    return self.context.createCGImage(ci_image, from: ci_image.extent)
                } else {
                    return image
                }
                
            }
            .assign(to: &$current_frame)
    }
    
}

