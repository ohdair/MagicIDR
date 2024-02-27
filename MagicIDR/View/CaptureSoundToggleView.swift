//
//  CaptureSoundToggleView.swift
//  MagicIDR
//
//  Created by 박재우 on 2/27/24.
//

import SwiftUI

struct CaptureSoundToggleView: View {
    @Binding var isSelected: Bool
    @Binding var isMuted: Bool

    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                Spacer()
                Spacer()

                Text("셔터음")
                    .foregroundStyle(.yellow)

                Spacer()

                Button(action: {
                    isMuted.toggle()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSelected.toggle()
                    }
                }) {
                    Text("끔")
                        .foregroundStyle(isMuted ? .yellow : .white)
                }

                Spacer()

                Button(action: {
                    isMuted.toggle()
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSelected.toggle()
                    }
                }) {
                    Text("켬")
                        .foregroundStyle(isMuted ? .white : .yellow)
                }

                Spacer()
            }
            .frame(width: isSelected ? .infinity : 0, height: 60)
            .frame(maxWidth: isSelected ? .infinity : nil)
            .background(Capsule().fill(Color.lead))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isSelected.toggle()
                }
            }

            Circle()
                .fill(isSelected ? Color.tungsten : Color.lead)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(isMuted ? .white : .yellow)
                )
                .frame(maxWidth: isSelected ? .infinity : nil, alignment: .leading)
                .onTapGesture {
                    withAnimation {
                        isSelected.toggle()
                    }
                }
        }
        .padding()
    }
}
