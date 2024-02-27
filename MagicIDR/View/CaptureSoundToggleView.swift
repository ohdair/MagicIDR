//
//  CaptureSoundToggleView.swift
//  MagicIDR
//
//  Created by 박재우 on 2/27/24.
//

import SwiftUI

struct CaptureSoundToggleView: View {
    @State private var isSelected = false
    @State private var isOn = false

    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                Spacer()
                Spacer()

                Button(action: {
                    isOn.toggle()
                    withAnimation {
                        isSelected.toggle()
                    }
                }) {
                    Text("끔")
                        .foregroundStyle(isOn ? .white : .yellow)
                }

                Spacer()

                Button(action: {
                    isOn.toggle()
                    withAnimation {
                        isSelected.toggle()
                    }
                }) {
                    Text("켬")
                        .foregroundStyle(isOn ? .yellow : .white)
                }

                Spacer()
            }
            .frame(width: isSelected ? 180 : 0, height: 60)
            .frame(maxWidth: isSelected ? 250 : nil)
            .background(Capsule().fill(Color.lead))

            Circle()
                .fill(isSelected ? Color.tungsten : Color.lead)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: isOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(isOn ? .yellow : .white)
                )
                .frame(maxWidth: isSelected ? 250 : nil, alignment: .leading)
                .onTapGesture {
                    withAnimation(.snappy) {
                        isSelected.toggle()
                    }
                }
        }
        .padding()
    }
}

struct CaptureSoundToggleView_Previews: PreviewProvider {
    static var previews: some View {
        CaptureSoundToggleView()
    }
}
