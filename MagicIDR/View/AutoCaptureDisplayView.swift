//
//  AutoCaptureDisplayView.swift
//  MagicIDR
//
//  Created by 박재우 on 2/27/24.
//

import SwiftUI

struct AutoCaptureDisplayView: View {
    var body: some View {
        HStack {
            Circle()
                .fill(.clear)
                .frame(width: 30, height: 30)
                .overlay(
                    ZStack {
                        Image(systemName: "camera.metering.spot")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                            .foregroundColor(.yellow)

                        StrokeText(text: "A", width: 1, color: .tungsten)
                            .foregroundStyle(.yellow)
                            .font(.subheadline)
                            .offset(x: 6, y: 4)
                    }
                )

            Text("1.5초")
                .foregroundStyle(.yellow)
                .font(.subheadline)
                .offset(x: -5, y: 0.5)
        }
        .padding(.horizontal, 5)
        .background {
            Capsule()
                .fill(Color.lead)
                .stroke(.yellow, style: .init(lineWidth: 1))
        }
    }
}
