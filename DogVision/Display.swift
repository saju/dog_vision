//
//  Display.swift
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

class Display: ObservableObject {
    @Published var frame: CGImage?
    @Published var err_str: String?
    
    private let camera = Camera.singleton;

    
    init() {
        /* listen for error messages dispatched from the Camera and display them */
        camera.$err_str
            .receive(on: RunLoop.main)
            .map { $0 }
            .assign(to: &$err_str)
    }
}

