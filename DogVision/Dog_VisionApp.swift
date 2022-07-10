//
//  Dog_VisionApp.swift
//  Dog Vision
//
//  Created by Saju Pillai on 7/9/22.
//

import SwiftUI

struct FrameView: View {
  var image: CGImage?
  private let label = Text("Camera feed")
  
    var body: some View {
      if let image = image {
        GeometryReader { geometry in
          Image(image, scale: 1.0, orientation: .up, label: label)
            .resizable()
            .scaledToFill()
            .frame(
              width: geometry.size.width,
              height: geometry.size.height,
              alignment: .center)
            .clipped()
        }
      } else {
        Color.black
      }

    }
}

struct ContentView: View {
    @StateObject private var feed = Display()
    
    var body: some View {
      ZStack {
          FrameView(image: feed.current_frame)
          ErrorView(err_str: feed.err_str)
      }
    }
}

@main
struct Dog_VisionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
