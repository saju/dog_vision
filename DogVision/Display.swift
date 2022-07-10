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

struct ErrorView: View {
  var err_str: String?

  var body: some View {
    VStack {
        Text(err_str ?? "")
        .bold()
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(8)
        .foregroundColor(.white)
        .background(Color.red.edgesIgnoringSafeArea(.top))
        .opacity(err_str == nil ? 0.0 : 1.0)
        .animation(.easeInOut, value: 0.25)

      Spacer()
    }
  }
}

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
    
    private let camera = Camera.singleton;
    private let screen = Screen.singleton;
    
    
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
                var cgimage: CGImage?

                
                VTCreateCGImageFromCVPixelBuffer(buffer, options: nil, imageOut: &cgimage)
                return cgimage;
            }
            .assign(to: &$current_frame)
    }
    
}

