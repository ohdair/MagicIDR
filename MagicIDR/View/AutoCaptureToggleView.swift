//
//  AutoCaptureToggleView.swift
//  MagicIDR
//
//  Created by 박재우 on 2/27/24.
//

import SwiftUI

struct AutoCaptureToggleView: View {
    @Binding var isSelected: Bool
    @Binding var isOn: Bool

    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                if isSelected {
                    Spacer()
                    Spacer()
                    
                    Text("자동 촬영")
                        .foregroundStyle(.yellow)
                    
                    Spacer()
                    
                    Button(action: {
                        isOn = false
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSelected.toggle()
                        }
                    }) {
                        Text("끔")
                            .foregroundStyle(isOn ? .white : .yellow)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isOn = true
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isSelected.toggle()
                        }
                    }) {
                        Text("켬")
                            .foregroundStyle(isOn ? .yellow : .white)
                    }
                    
                    Spacer()
                }
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
                    ZStack {
                        Image(systemName: "camera.metering.spot")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(isOn ? .yellow : .white)

                        StrokeText(text: "Auto", width: 1, color: .tungsten)
                            .foregroundStyle(isOn ? .yellow : .white)
                            .font(.caption)
                            .offset(x: 12, y: 13)
                    }
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

private struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:  width, y:  width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y:  width)
                Text(text).offset(x:  width, y: -width)
            }
            .foregroundColor(color)
            Text(text)
        }

    }
}
