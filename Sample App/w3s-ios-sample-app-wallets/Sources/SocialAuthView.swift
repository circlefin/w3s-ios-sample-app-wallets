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

struct SocialAuthView: View {
    let model: AuthViewModel

    private let adapter = WalletSdkAdapter()

    private let separatorColor = Color(red: 17 / 255.0, green: 24 / 255.0, blue: 39 / 255.0, opacity: 0.1)

        private let deviceID: String = WalletSdk.shared.getDeviceId()

    private var endPoint: String { return apiParameters.endPoint }
    private var appId: String { return apiParameters.appId }
    private var deviceToken: String { return apiParameters.deviceTokenForSocial }
    private var deviceEncryptionKey: String { return apiParameters.deviceEncryptionKeyForSocial }

    @Binding var apiParameters: SDKApiParameters
    @Binding var showExecuteChallengeButton: Bool
    @State private var userToken = ""
    @State private var encryptionKey = ""
    @State private var isSocialBtnEnable = false
    @State private var showExecuteView = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        socialInputView()
            .onChange(of: appId) {
                if let errStr = self.adapter.updateEndPoint(endPoint, appId: appId) {
                    showToast(.failure, message: "Error: " + errStr)
                }
                self.adapter.storedAppId = appId
            }
            .onChange(of: userToken) {
                if !userToken.isEmpty, !encryptionKey.isEmpty {
                    showExecuteChallengeButton = true
                }
            }
            .onAppear {
                self.adapter.initSDK(endPoint: endPoint, appId: appId)

                if let storedAppId = self.adapter.storedAppId, !storedAppId.isEmpty {
                    apiParameters.appId = storedAppId
                }

                setButtonsEnableStatus()
            }
            .fullScreenCover(isPresented: $showExecuteView) {
                ExecuteChallengeView(endPoint: endPoint,
                                     appId: appId,
                                     userToken: userToken,
                                     encryptionKey: encryptionKey)
            }
    }
}

extension SocialAuthView {

    // MARK: View

    @ViewBuilder
    func socialInputView() -> some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                sectionText(model.parameters[0].title,
                            context: deviceID, enableCopy: true)
                sectionInputField(model.parameters[1].title,
                                  isRequired: model.parameters[1].isRequired,
                                  binding: $apiParameters.appId,
                                  isFocused: $isTextFieldFocused) {
                    setButtonsEnableStatus()
                }
                sectionInputField(model.parameters[2].title,
                                  isRequired: model.parameters[2].isRequired,
                                  binding: $apiParameters.deviceTokenForSocial,
                                  isFocused: $isTextFieldFocused) {
                    setButtonsEnableStatus()
                }
                sectionInputField(model.parameters[3].title,
                                  isRequired: model.parameters[3].isRequired,
                                  binding: $apiParameters.deviceEncryptionKeyForSocial,
                                  isFocused: $isTextFieldFocused) {
                    setButtonsEnableStatus()
                }
            }

            ZStack(alignment: .center) {
                Rectangle()
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(separatorColor)

                HStack(spacing: 0) {
                    Rectangle()
                        .fill(.white)
                        .frame(width: 16, height: 1)
                    Text("Log in with")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.24, green: 0.24, blue: 0.26).opacity(0.6))
                        .background(.white)
                    Rectangle()
                        .fill(.white)
                        .frame(width: 16, height: 1)
                }
            }

            VStack(spacing: 12) {
                socialLoginButton(isBtnEnable: isSocialBtnEnable,
                                  provider: .Google)
                socialLoginButton(isBtnEnable: isSocialBtnEnable,
                                  provider: .Facebook)
                socialLoginButton(isBtnEnable: isSocialBtnEnable,
                                  provider: .Apple)
            }

            socialDocText()

            if !userToken.isEmpty, !encryptionKey.isEmpty {
                executeChallengeButton {
                    showExecuteView.toggle()
                }
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    func socialLoginButton(isBtnEnable: Bool,
                           provider: CircleProgrammableWalletSDK.SocialProvider) -> some View {
        let disableTextColor = Color(red: 142 / 255.0, green: 142 / 255.0, blue: 147 / 255.0)
        let btnBorderColor = Color(red: 221 / 255.0, green: 221 / 255.0, blue: 221 / 255.0)

        Button(action: {
            performSocialLogin(provider: provider)
        }) {
            HStack(spacing: 10) {
                Image("\(provider.rawValue)")
                    .resizable()
                    .frame(width: 24, height: 24)
                Text("\(provider.rawValue)")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(isBtnEnable ? .black : disableTextColor)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40, alignment: .center)
        .background(isBtnEnable ? .white : btnBorderColor)
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .inset(by: 0.5)
                .stroke(btnBorderColor, lineWidth: 1)
        )
        .onTapGesture {
            performSocialLogin(provider: provider)
        }
        .disabled(!isBtnEnable)
        .buttonStyle(BorderlessButtonStyle())
    }

    func socialDocText() -> some View {
        let strFont = Font.system(size: 14)
        let urlFont = Font.system(size: 14, weight: .semibold)
        let strColor = Color(red: 78 / 255.0, green: 71 / 255.0, blue: 99 / 255.0)
        let urlColor = Color(red: 0 / 255.0, green: 115 / 255.0, blue: 195 / 255.0)
        let docUrlStr = "https://developers.circle.com/w3s/docs/authentication-methods#create-a-wallet-with-social-logins"
        let attributedString: AttributedString = {
            var str1 = AttributedString("Please configure your OAuth credentials in the Console first. View")
            str1.font = strFont
            str1.foregroundColor = strColor
            var urlStr = AttributedString(" docs ")
            urlStr.link = URL(string: docUrlStr)!
            urlStr.font = urlFont
            urlStr.foregroundColor = urlColor
            var str2 = AttributedString("for more guidance.")
            str2.font = strFont
            str2.foregroundColor = strColor
            return str1 + urlStr + str2
        }()

        func handleURL(_ url: URL) -> OpenURLAction.Result {
            print("Handle \(url) somehow")
            return .systemAction
        }

        return Text(attributedString)
            .frame(maxWidth: .infinity)
            .environment(\.openURL, OpenURLAction(handler: handleURL))
    }

    // MARK: Internal

    func showToast(_ type: Toast.ToastType, message: String) {
        let notiObj = ToastInfo(type: type, message: message)
        NotificationCenter.default.post(name: .showToast, object: notiObj)
    }

    func setButtonsEnableStatus() {
        guard !endPoint.isEmpty, !appId.isEmpty,
              !deviceToken.isEmpty, !deviceEncryptionKey.isEmpty else {
            isSocialBtnEnable = false
            return
        }

        isSocialBtnEnable = true
    }

    func performSocialLogin(provider: CircleProgrammableWalletSDK.SocialProvider) {
        WalletSdk.shared.performLogout(provider: provider)  // Clean cache data

        WalletSdk.shared.performLogin(provider: provider,
                                      deviceToken: deviceToken,
                                      encryptionKey: deviceEncryptionKey) { loginResult in
            switch loginResult.result {
            case .success(let result):
                showToast(.success, message: "Login Successful")
                userToken = result.userToken
                encryptionKey = result.encryptionKey
            case .failure(let error):
                showToast(.failure, message: "Error: " + error.displayString)
                errorHandler(apiError: error, onErrorController: loginResult.onErrorController)
            }
        }
    }

    func errorHandler(apiError: ApiError, onErrorController: UIViewController?) {
        switch apiError.errorCode {
        case .userHasSetPin,
             .biometricsSettingNotEnabled,
             .deviceNotSupportBiometrics,
             .biometricsKeyPermanentlyInvalidated,
             .biometricsUserSkip,
             .biometricsUserDisableForPin,
             .biometricsUserLockout,
             .biometricsUserLockoutPermanent,
             .biometricsUserNotAllowPermission,
             .biometricsInternalError:
            onErrorController?.dismiss(animated: true)
        default:
            break
        }
    }
}
