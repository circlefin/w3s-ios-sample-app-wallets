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

extension View {

    @ViewBuilder
    func sectionText(_ title: String, context: String, enableCopy: Bool) -> some View {
        let titleColor = Color(red: 61 / 255.0, green: 61 / 255.0, blue: 61 / 255.0)
        let contextColor = Color(red: 37 / 255.0, green: 37 / 255.0, blue: 37 / 255.0, opacity: 0.82)

        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(titleColor)
            HStack(alignment: .top, spacing: 8) {
                Text(context)
                    .font(.system(size: 16))
                    .foregroundColor(contextColor)
                
                if enableCopy {
                    Button {
                        UIPasteboard.general.string = context
                        
                        let notiObj = ToastInfo(type: .general, message: "Copied: \(context)")
                        NotificationCenter.default.post(name: .showToast,
                                                        object: notiObj)
                    } label: {
                        Image("copy")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(2)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
    }

    @ViewBuilder
    func sectionInputField(_ title: String,
                           isRequired: Bool,
                           binding: Binding<String>,
                           isFocused: FocusState<Bool>.Binding,
                           onChangeAction: (() -> Void)? = nil) -> some View {
        let titleColor = Color(red: 61 / 255.0, green: 61 / 255.0, blue: 61 / 255.0)
        let textFieldBorderColor = Color(red: 221 / 255.0, green: 221 / 255.0, blue: 221 / 255.0)
        let starColor = Color(red: 255 / 255.0, green: 59 / 255.0, blue: 48 / 255.0)
        var starCharacter: AttributedString {
            var starCharacter = AttributedString("*")
            starCharacter.foregroundColor = starColor
            return starCharacter
        }
        var attributedStr: AttributedString {
            let str = AttributedString(isRequired ? "\(title) " : title)
            return isRequired ? str + starCharacter : str
        }

        @FocusState var campaignTitleIsFocussed: Bool

        VStack(alignment: .leading, spacing: 8) {
            Text(attributedStr)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(titleColor)

            TextField(title, text: binding, axis: .vertical)
                .font(.system(size: 16))
                .padding(.vertical, 11)
                .padding(.horizontal, 16)
                .overlay(textFieldBorderColor, in: .rect(cornerRadius: 10).stroke(lineWidth: 1))
                .foregroundColor(.black)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.none)
                .autocorrectionDisabled()
                .focused(isFocused)
                .onChange(of: binding.wrappedValue) { _, newValue in
                    if newValue.last?.isNewline == .some(true) {
                        binding.wrappedValue.removeLast()
                        /// Dismiss keyboard
                        isFocused.wrappedValue = false
                    } else {
                        onChangeAction?()
                    }
                }
        }
    }

    @ViewBuilder
    func executeButton(isBtnEnable: Bool, action: (() -> Void)? = nil) -> some View {
        let bgBlueColor = Color(red: 0 / 255.0, green: 115 / 255.0, blue: 195 / 255.0)
        let disableBgBlueColor = Color(red: 128 / 255.0, green: 185 / 255.0, blue: 225 / 255.0)

        Button {
            action?()
        } label: {
            Text("Execute")
                .font(.system(size: 14, weight: .medium))
                .frame(maxWidth: .infinity)
        }
        .frame(height: 56)
        .foregroundColor(.white)
        .background(isBtnEnable ? bgBlueColor : disableBgBlueColor)
        .cornerRadius(.infinity)
        .disabled(!isBtnEnable)
        .buttonStyle(BorderlessButtonStyle())
    }

    @ViewBuilder
    func executeChallengeButton(action: (() -> Void)? = nil) -> some View {
        let backgroundBgColor = Color(red: 225 / 255.0, green: 242 / 255.0, blue: 255 / 255.0)
        let textColor = Color(red: 41 / 255.0, green: 35 / 255.0, blue: 59 / 255.0)
        let descColor = Color(red: 107 / 255.0, green: 101 / 255.0, blue: 128 / 255.0)

        Button(action: {
            action?()
        }) {
            HStack(alignment: .top, spacing: 12) {
                ZStack(alignment: .center) {
                    backgroundBgColor
                        .frame(width: 48, height: 48)
                        .cornerRadius(.infinity)

                    Image("pencil")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color(red: 0.09, green: 0.58, blue: 0.91))
                }

                VStack(alignment: .leading) {
                    Text("Execute Challenge")
                        .font(.system(size: 17, weight: .semibold))

                        .foregroundColor(textColor)
                    Text("Enter Challenge ID to test wallet creation or signing flows.")
                        .font(.system(size: 16))
                        .multilineTextAlignment(.leading)
                        .foregroundColor(descColor)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .cornerRadius(16)
        }
        .buttonStyle(BorderlessButtonStyle())
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(Color(red: 0.91, green: 0.91, blue: 0.91), lineWidth: 1)
        )
    }
}
