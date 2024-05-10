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
import CircleProgrammableWalletSDK
import FBSDKLoginKit

struct SSOSignInView: View {

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var appleViewModel: AppleAuthViewModel
    @EnvironmentObject var googleViewModel: GoogleAuthViewModel
    @EnvironmentObject var facebookViewModel: FacebookAuthViewModel

    @Binding var deviceID: String
    @State var providerName = "{Provider Name}"
    @State var ssoToken = "SSO Token"

    @State var showToast = false
    @State var toastMessage: String?
    @State var toastConfig: Toast.Config = .init()

    var body: some View {
        VStack {
            List {
                sectionInputField("Device ID", text: deviceID)
                appleViewModel.SignInButton()
                    .listRowSeparator(.hidden)
                Button(action: googleViewModel.signInOutHandler) {
                    let isGoogleSign = googleViewModel.state == .signedIn
                    let buttonTitle = isGoogleSign ? "Sign out Google" : "Sign in with Google"
                    
                    Text(buttonTitle)
                        .font(.system(size: 23))
                        .padding([.top, .bottom], 18)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 5,
                                style: .continuous
                            ).fill(Color(red: 61 / 255, green: 54 / 255, blue: 82 / 255))
                        )
                }
                .listRowSeparator(.hidden)
                Button(action: facebookViewModel.signInOutHandler) {
                    let isGoogleSign = facebookViewModel.state == .signedIn
                    let buttonTitle = isGoogleSign ? "Sign out Facebook" : "Sign in with Facebook"

                    Text(buttonTitle)
                        .font(.system(size: 23))
                        .padding([.top, .bottom], 18)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 5,
                                style: .continuous
                            ).fill(Color(red: 24 / 255, green: 119 / 255, blue: 242 / 255))
                        )
                }
                sectionInputField("SSO Token", binding: $ssoToken)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: appleViewModel.token) { newValue in
            providerName = "Apple"
            ssoToken = newValue
        }
        .onChange(of: googleViewModel.state) { newValue in
            providerName = "Google"
            switch newValue {
            case .signedIn:
                ssoToken = googleViewModel.token
            case .signedOut:
                ssoToken = "SSO Token"
            }
        }
        .onChange(of: facebookViewModel.state) { newValue in
            providerName = "Facebook"
            switch newValue {
            case .signedIn:
                ssoToken = facebookViewModel.token
            case .signedOut:
                ssoToken = "SSO Token"
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(uiImage: UIImage(named: "ic_navi_back")!)
                }
            }
        }
        .toast(message: toastMessage ?? "",
               isShowing: $showToast,
               config: toastConfig)
    }

    func sectionInputField(_ title: String, text: String) -> Section<Text, some View, EmptyView> {
        Section {
            Button(action: {
                UIPasteboard.general.string = text
                showToast(message: "Copied: \(text)")
            }) {
                Text(text)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle)
        } header: {
            Text(title + " :")
        }
    }

    func sectionInputField(_ title: String, binding: Binding<String>) -> Section<Text, some View, EmptyView> {
        Section {
            Button(action: {
                UIPasteboard.general.string = binding.wrappedValue
                showToast(message: "SSO token copied!")
            }) {
                Text(binding.wrappedValue)
                    .foregroundColor(colorScheme == .light ? Color.black : Color.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .truncationMode(.tail)
            }
        } header: {
            var content: AttributedString {
                var content = AttributedString("SSO (\(providerName)) Token" + " :")
                content.inlinePresentationIntent = .stronglyEmphasized
                return content
            }
            Text(content)
        }
    }
}

extension SSOSignInView {

    func showToast(message: String) {
        toastMessage = message
        showToast = true

        toastConfig = Toast.Config()
    }

}
