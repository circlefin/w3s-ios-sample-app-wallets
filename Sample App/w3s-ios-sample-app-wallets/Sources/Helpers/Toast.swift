// Copyright (c) 2024, Circle Internet Financial, LTD. All rights reserved.
//
// SPDX-License-Identifier: Apache-2.0
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

struct ToastInfo {
    let type: Toast.ToastType
    let message: String
}

struct Toast: ViewModifier {

    enum ToastType {
        case general
        case success
        case failure
    }

    static let short: TimeInterval = 2
    static let long: TimeInterval = 3.5

    let message: String
    @Binding var isShowing: Bool
    let config: Config

    func body(content: Content) -> some View {
        ZStack {
            content
            toastView
        }
    }

    private var toastView: some View {
        VStack {
            Spacer()
            if isShowing {
                HStack(alignment: .center, spacing: 12) {
                    HStack(alignment: .top, spacing: 8) {
                        if let statusImage = config.statusImage {
                            statusImage
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        Text(message)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(config.textColor)
                            .font(config.font)
                    }
                    .frame(alignment: .topLeading)
                    if let closeImage = config.closeImage {
                        Button {
                            isShowing = false
                        } label: {
                            closeImage
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(4)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(config.backgroundColor)
                .cornerRadius(8)
                .onTapGesture {
                    if config.closeImage == nil {
                        isShowing = false
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .inset(by: 0.5)
                        .stroke(config.borderColor ?? .clear, lineWidth: 1)
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + config.duration) {
                        isShowing = false
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 18)
        .animation(config.animation, value: isShowing)
        .transition(config.transition)
    }

    struct Config {
        let textColor: Color
        let font: Font
        let backgroundColor: Color
        let borderColor: Color?
        let duration: TimeInterval
        let transition: AnyTransition
        let animation: Animation
        let statusImage: Image?
        let closeImage: Image?

        init(textColor: Color = .white,
             font: Font = .system(size: 14),
             backgroundColor: Color = .black.opacity(0.588),
             borderColor: Color? = nil,
             duration: TimeInterval = Toast.short,
             transition: AnyTransition = .opacity,
             animation: Animation = .linear(duration: 0.3),
             statusImage: Image? = nil,
             closeImage: Image? = nil) {
            self.textColor = textColor
            self.font = font
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
            self.duration = duration
            self.transition = transition
            self.animation = animation
            self.statusImage = statusImage
            self.closeImage = closeImage
        }
    }
}

extension View {
    func toast(message: String,
               isShowing: Binding<Bool>,
               config: Toast.Config) -> some View {
        self.modifier(Toast(message: message,
                            isShowing: isShowing,
                            config: config))
    }

    func toast(message: String,
               isShowing: Binding<Bool>,
               duration: TimeInterval) -> some View {
        self.modifier(Toast(message: message,
                            isShowing: isShowing,
                            config: .init(duration: duration)))
    }
}
