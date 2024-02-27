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
                if isSelected {
                    Spacer()
                    Spacer()
                    
                    Text("셔터음")
                        .foregroundStyle(.yellow)
                    
                    Spacer()
                    
                    Button(action: {
                        isMuted = true
                        NotificationCenter.default.post(
                            name: .isMuted,
                            object: nil,
                            userInfo: [NotificationKey.isMuted: true]
                        )
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSelected.toggle()
                        }
                    }) {
                        Text("끔")
                            .foregroundStyle(isMuted ? .yellow : .white)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isMuted = false
                        NotificationCenter.default.post(
                            name: .isMuted,
                            object: nil,
                            userInfo: [NotificationKey.isMuted: false]
                        )
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSelected.toggle()
                        }
                    }) {
                        Text("켬")
                            .foregroundStyle(isMuted ? .white : .yellow)
                    }
                    
                    Spacer()
                }
            }
            .frame(height: 50)
            .frame(maxWidth: isSelected ? .infinity : nil)
            .background(Capsule().fill(Color.lead))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isSelected.toggle()
                }
            }

            Circle()
                .fill(isSelected ? Color.tungsten : Color.lead)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .foregroundColor(isMuted ? .white : .yellow)
                )
                .frame(maxWidth: isSelected ? .infinity : nil, alignment: .leading)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSelected.toggle()
                    }
                }
        }
    }
}
