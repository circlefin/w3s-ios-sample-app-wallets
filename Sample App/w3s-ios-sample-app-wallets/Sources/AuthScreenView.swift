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
import Observation

struct SDKApiParameters {
    var endPoint = "https://enduser-sdk.circle.com/v1/w3s"
    var appId = "your-app-id" // put your App ID here programmatically
    var challengeId = ""
    var enableBiometrics = false

    // For PIN user
    var userToken = ""
    var encryptionKey = ""

    // For Social user
    var deviceTokenForSocial = ""
    var deviceEncryptionKeyForSocial = ""

    // For Email user
    var deviceTokenForEmail = ""
    var deviceEncryptionKeyForEmail = ""
    var otpToken = ""
}

struct AuthViewModel {
    let userType: UserType
    let parameters: [(title: String, isEditable: Bool, isRequired: Bool)]
}

@Observable class AuthScreenViewModel {
    var tabIndex: Int = 0

    var sdkInputParameters = SDKApiParameters()

    let authViewModels: [AuthViewModel] = [
        .init(userType: .social, parameters: [
            (title: "Device ID", isEditable: false, isRequired: true),
            (title: "App ID", isEditable: true, isRequired: true),
            (title: "Device Token", isEditable: true, isRequired: true),
            (title: "Device Encryption Key", isEditable: true, isRequired: true),
        ]),
        .init(userType: .email, parameters: [
            (title: "Device ID", isEditable: false, isRequired: true),
            (title: "App ID", isEditable: true, isRequired: true),
            (title: "Device Token", isEditable: true, isRequired: true),
            (title: "Device Encryption Key", isEditable: true, isRequired: true),
            (title: "OTP Token", isEditable: true, isRequired: true),
        ]),
        .init(userType: .pin, parameters: [
            (title: "End Point", isEditable: false, isRequired: true),
            (title: "App ID", isEditable: true, isRequired: true),
            (title: "User Token", isEditable: true, isRequired: true),
            (title: "Encryption Key", isEditable: true, isRequired: true),
            (title: "Challenge ID", isEditable: true, isRequired: false),
        ]),
    ]
}

struct AuthScreenView: View {

    let headerTitleColor = Color(red: 29 / 255.0, green: 27 / 255.0, blue: 32 / 255.0)
    let descriptionColor = Color(red: 142 / 255.0, green: 142 / 255.0, blue: 147 / 255.0)
    let showToastPub = NotificationCenter.default.publisher(for: Notification.Name("showToast"), object: nil)

    @Bindable private var viewModel = AuthScreenViewModel()
    @State private var showExecuteChallengeButton = false

    @State var showToast = false
    @State var toastMessage: String?
    @State var toastConfig: Toast.Config = .init()

    var authViews: [any View] = []

    var body: some View {
        /// Fack Navigation Bar
        Spacer().frame(width: UIScreen.main.bounds.width, height: 1)

        ScrollViewReader { scrollViewReader in
            List(0..<2, id: \.self) { listIndex in
                if listIndex == 0 {
                    VStack(spacing: 16) {
                        Text("User Controlled Wallet \nSample App")
                            .font(.system(size: 22, weight: .bold))
                            .multilineTextAlignment(.center)
                            .foregroundColor(headerTitleColor)
                            .frame(maxWidth: .infinity, alignment: .top)

                        Text("Choose one Auth Method to start")
                            .font(.system(size: 15))
                            .multilineTextAlignment(.center)
                            .foregroundColor(descriptionColor)
                    }
                    .padding(.top, 24)
                    /// For decrease the section header top padding
                    .padding(.bottom, -22)
                    .padding(.horizontal, 16)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())

                    Section(header:
                                CustomSegmentedControl(
                                    totalIndex: viewModel.authViewModels.count,
                                    selectedIndex: $viewModel.tabIndex)
                                    .background(.white)
                                    .listRowInsets(EdgeInsets())
                    ) {
                        ZStack(alignment: .center) {
                            switch viewModel.authViewModels[viewModel.tabIndex].userType {
                            case .social:
                                socialAuthView
                            case .email:
                                emailAuthView
                            case .pin:
                                pinAuthView
                            }
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                    }
                } else {
                    /// Just design for scrolling to the list bottom
                    Spacer()
                        .hidden()
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .id(listIndex)
                }
            }
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, 24)
            .onChange(of: showExecuteChallengeButton) {
                if showExecuteChallengeButton {
                    withAnimation {
                        scrollViewReader.scrollTo(1)
                    }
                    showExecuteChallengeButton.toggle() /// For reset state
                }
            }
        }
        .onReceive(showToastPub) { noti in
            if let toastInfo = noti.object as? ToastInfo {
                showToast(toastInfo.type, message: toastInfo.message)
            }
        }
        .toast(message: toastMessage ?? "",
               isShowing: $showToast,
               config: toastConfig)
    }

    var socialAuthView: some View {
        SocialAuthView(model: viewModel.authViewModels[0],
                       apiParameters: $viewModel.sdkInputParameters,
                       showExecuteChallengeButton: $showExecuteChallengeButton)
    }

    var emailAuthView: some View {
        EmailAuthView(model: viewModel.authViewModels[1],
                      apiParameters: $viewModel.sdkInputParameters,
                      showExecuteChallengeButton: $showExecuteChallengeButton)
    }

    var pinAuthView: some View {
        PinAuthView(model: viewModel.authViewModels[2],
                    apiParameters: $viewModel.sdkInputParameters)
    }
}

extension AuthScreenView {

    func showToast(_ type: Toast.ToastType = .general, message: String) {
        toastMessage = message
        showToast = true

        switch type {
        case .general:
            toastConfig = Toast.Config()
        case .success:
            let font = Font.system(size: 14).weight(.bold)
            let successColor = Color(red: 0 / 255.0, green: 131 / 255.0, blue: 57 / 255.0)
            let statusImage = Image("check-circle")
            let closeImage = Image("success_X")
            toastConfig = Toast.Config(font: font,
                                       backgroundColor: successColor,
                                       duration: 3.0,
                                       statusImage: statusImage,
                                       closeImage: closeImage)
        case .failure:
            let failureTextColor = Color(red: 188 / 255.0, green: 0 / 255.0, blue: 22 / 255.0)
            let failureColor = Color(red: 255 / 255.0, green: 234 / 255.0, blue: 239 / 255.0)
            let statusImage = Image("exclamation-circle")
            let closeImage = Image("failure_X")
            toastConfig = Toast.Config(textColor: failureTextColor,
                                       backgroundColor: failureColor,
                                       borderColor: failureTextColor,
                                       duration: 3.0,
                                       statusImage: statusImage,
                                       closeImage: closeImage)
        }
    }
}

#Preview {
    AuthScreenView()
}
