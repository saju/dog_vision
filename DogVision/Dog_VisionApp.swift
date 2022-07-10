//
//  Dog_VisionApp.swift
//  Dog Vision
//
//  Created by Saju Pillai on 7/9/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var feed = Display()
    
    var body: some View {
      ZStack {
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
