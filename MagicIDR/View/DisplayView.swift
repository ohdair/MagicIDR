//
//  DisplayView.swift
//  MagicIDR
//
//  Created by 박재우 on 2/27/24.
//

import SwiftUI

struct DisplayView: View {
    @State var isOnCaptureSound = false
    @State var isOnAutoCapture = true

    var body: some View {
        HStack {
            Spacer()

            if isOnCaptureSound {
                CaptureSoundDisplayView()
            }

            if isOnAutoCapture {
                AutoCaptureDisplayView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .isMuted)) {
            if let userInfo = $0.userInfo,
               let isMuted = userInfo[NotificationKey.isMuted] as? Bool {
                withAnimation {
                    isOnCaptureSound = !isMuted
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .isAutoCapture)) {
            if let userInfo = $0.userInfo,
               let isAutoCapture = userInfo[NotificationKey.isAutoCapture] as? Bool {
                withAnimation {
                    isOnAutoCapture = isAutoCapture
                }
            }
        }
    }
}

struct DisplayView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayView()
    }
}
