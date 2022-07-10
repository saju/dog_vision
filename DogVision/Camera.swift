//
//  Camera.swift
//  Dog Vision
//
//  Created by Saju Pillai on 7/9/22.
//

import AVFoundation

class Camera: ObservableObject {
    @Published var err_str: String?
    private let av_session = DispatchQueue(label: "org.srp.umwelt")
    static let singleton = Camera()
    private var online: Bool
    
    private func test_and_ask_permissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            online = true
            break
        case .notDetermined:
            av_session.suspend()
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                if (!authorized) {
                    self.online = false
                }
                self.online = true
                self.av_session.resume()
                }
        default:
            online = false
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
    }
}
