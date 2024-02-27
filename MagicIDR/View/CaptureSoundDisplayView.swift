//
//  CaptureSoundDisplayView.swift
//  MagicIDR
//
//  Created by 박재우 on 2/27/24.
//

import SwiftUI

struct CaptureSoundDisplayView: View {
    var body: some View {
        Circle()
            .fill(Color.lead)
            .stroke(.yellow, style: .init(lineWidth: 1))
            .frame(width: 30, height: 30)
            .overlay(
                Image(systemName: "speaker.wave.2.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                    .foregroundColor(.yellow)
            )

    }
}
