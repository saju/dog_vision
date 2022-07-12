//
//  Dog_VisionApp.swift
//  Dog Vision
//
//  Created by Saju Pillai on 7/9/22.
//

import SwiftUI

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

struct ToggleButton: View {
  @Binding var selected: Bool

  var label: String

  var body: some View {
    Button(action: {
      selected.toggle()
    }, label: {
      Text(label)
    })
    .padding(.vertical, 10)
    .padding(.horizontal)
    .foregroundColor(selected ? .white : .black)
    .background(selected ? Color.blue : .white)
    .animation(.easeInOut, value: 0.25)
    .cornerRadius(10)
  }
}

struct ControlView: View {
  @Binding var dog_vision: Bool

  var body: some View {
    VStack {
      Spacer()

      HStack(spacing: 12) {
        ToggleButton(selected: $dog_vision, label: "Dog")
      }
    }
  }
}

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
          ControlView(dog_vision: $feed.dog_vision)
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
