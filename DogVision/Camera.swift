//
//  Camera.swift
//  Dog Vision
//
//  Created by Saju Pillai on 7/9/22.
//

import AVFoundation

class Camera: ObservableObject {
    @Published var err_str: String?
    
    private var online: Bool
    private var av_configured = false
    
    private let pvt_queue = DispatchQueue(label: "org.srp.umwelt")
    let av_session = AVCaptureSession()
    private let video_output = AVCaptureVideoDataOutput()
    
    static let singleton = Camera()
    
    private func test_and_ask_permissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            online = true
            break
        case .notDetermined:
            /* request for camera perms */
            pvt_queue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if (!authorized) {
                    self.online = false
                }
                self.online = true
                self.pvt_queue.resume()
                }
            break
        default:
            online = false
        }
    }
    
    private func configure_capture_session () {
        if (self.av_configured) {
            return
        }
            
        av_session.beginConfiguration()
        defer {
            av_session.commitConfiguration()
        }
        
        /* grab the fancy triple camera */
        let device = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back)
        guard let cam = device else {
            DispatchQueue.main.async {
                self.err_str = "Triple Camera is not available"
            }
            return
        }

        /* now build the "camera feed" pipeline - input from camera, output to phone screen */
        do {
            let input = try AVCaptureDeviceInput(device: cam)
            if (av_session.canAddInput(input)) {
                av_session.addInput(input)
            } else {
                DispatchQueue.main.async {
                    self.err_str = "Unable to add Camera Input"
                }
                return
            }
        } catch {
            DispatchQueue.main.async {
              self.err_str = "Failed to set camera capture"
            }
                return
        }
            
        if (av_session.canAddOutput(video_output)) {
            av_session.addOutput(video_output)
            video_output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            
            let video_conn = video_output.connection(with: .video)
            video_conn?.videoOrientation = .landscapeRight
        } else {
            DispatchQueue.main.async {
                self.err_str = "Unable to add Video Output device to session"
            }
            return
        }
        self.av_configured = true
    }
    
    func set(_ delegate: AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue) {
        pvt_queue.async {
            self.video_output.setSampleBufferDelegate(delegate, queue: queue)
        }
    }
    
    private init () {
        online = false
        test_and_ask_permissions()
        
        if (!online) {
            DispatchQueue.main.async {
                self.err_str = "could not initialize camera. check perms"
            }
        }
        
        pvt_queue.async {
            self.configure_capture_session()
            self.av_session.startRunning()
        }
    }
}
