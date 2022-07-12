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

class DogFilter: CIFilter {
  private let kernel: CIColorKernel
  
  var inputImage: CIImage?
  
  override init() {
    let url = Bundle.main.url(forResource: "default", withExtension: "metallib")!
    let data = try! Data(contentsOf: url)
    kernel = try! CIColorKernel(functionName: "dog_eyes", fromMetalLibraryData: data)
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
  }
  
  func outputImage() -> CIImage? {
    guard let inputImage = inputImage else {return nil}
    return kernel.apply(extent: inputImage.extent, arguments: [inputImage])
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
                    let filter = DogFilter()
                    filter.inputImage = ci_image
                    ci_image = filter.outputImage() ?? ci_image
                    return self.context.createCGImage(ci_image, from: ci_image.extent)
                } else {
                    return image
                }
                
            }
            .assign(to: &$current_frame)
    }
    
}

