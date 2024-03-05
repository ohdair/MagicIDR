//
//  AbilitiesView.swift
//  MagicIDR
//
//  Created by 박재우 on 2/27/24.
//

import SwiftUI

struct AbilitiesView: View {
    @State var isMuted = true
    @State var isAuto = true

    @State private var isCaptureSoundViewSelected = false
    @State private var isAutoCaptureViewSelected = false


    var body: some View {
        HStack {
            Spacer()

            if !isAutoCaptureViewSelected {
                CaptureSoundToggleView(isSelected: $isCaptureSoundViewSelected,
                                       isMuted: $isMuted)
            }

            Spacer()

            if !isCaptureSoundViewSelected {
                AutoCaptureToggleView(isSelected: $isAutoCaptureViewSelected,
                                      isOn: $isAuto)
            }

            Spacer()
        }
    }
}

struct AbilitiesView_Previews: PreviewProvider {
    static var previews: some View {
        AbilitiesView()
    }
}
