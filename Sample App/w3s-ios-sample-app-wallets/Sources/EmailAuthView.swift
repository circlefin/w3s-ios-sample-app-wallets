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

struct EmailAuthView: View {
    let model: AuthViewModel

    private let adapter = WalletSdkAdapter()

    private let deviceID: String = WalletSdk.shared.getDeviceId()

    private var endPoint: String { return apiParameters.endPoint }
    private var appId: String { return apiParameters.appId }
    private var deviceToken: String { return apiParameters.deviceTokenForEmail }
    private var deviceEncryptionKey: String { return apiParameters.deviceEncryptionKeyForEmail }
    private var otpToken: String { return apiParameters.otpToken }
    
    @Binding var apiParameters: SDKApiParameters
    @Binding var showExecuteChallengeButton: Bool
    @State private var userToken = ""
    @State private var encryptionKey = ""
    @State private var isEmailBtnEnable = false
    @State private var showExecuteView = false
    @FocusState private var isTextFieldFocused: Bool

    let onSendAgainPub = NotificationCenter.default.publisher(for: Notification.Name.onSendAgain, object: nil)

    var body: some View {
        emailInputView()
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
            .onReceive(onSendAgainPub) { _ in
                showToast(.failure, message: "Register a callback function is required during the actual implementation.")
            }
            .fullScreenCover(isPresented: $showExecuteView) {
                ExecuteChallengeView(endPoint: endPoint,
                                     appId: appId,
                                     userToken: userToken,
                                     encryptionKey: encryptionKey)
            }
    }
}

extension EmailAuthView {
    
    // MARK: View

    @ViewBuilder
    func emailInputView() -> some View {
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
                                  binding: $apiParameters.deviceTokenForEmail,
                                  isFocused: $isTextFieldFocused) {
                    setButtonsEnableStatus()
                }
                sectionInputField(model.parameters[3].title,
                                  isRequired: model.parameters[3].isRequired,
                                  binding: $apiParameters.deviceEncryptionKeyForEmail,
                                  isFocused: $isTextFieldFocused) {
                    setButtonsEnableStatus()
                }
                sectionInputField(model.parameters[4].title,
                                  isRequired: model.parameters[4].isRequired,
                                  binding: $apiParameters.otpToken,
                                  isFocused: $isTextFieldFocused) {
                    setButtonsEnableStatus()
                }
            }

            loginWithEmailButton()

            if !userToken.isEmpty, !encryptionKey.isEmpty {
                executeChallengeButton {
                    showExecuteView.toggle()
                }
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    func loginWithEmailButton() -> some View {
        let bgBlueColor = Color(red: 0 / 255.0, green: 115 / 255.0, blue: 195 / 255.0)
        let disableBgBlueColor = Color(red: 128 / 255.0, green: 185 / 255.0, blue: 225 / 255.0)

        Button {
            verifyEmailOTP(deviceToken: deviceToken,
                           deviceEncryptionKey: deviceEncryptionKey,
                           otpToken: otpToken)
        } label: {
            Text("Log in with Email")
                .font(.system(size: 14, weight: .medium))
                .frame(maxWidth: .infinity)
        }
        .frame(height: 56)
        .foregroundColor(.white)
        .background(isEmailBtnEnable ? bgBlueColor : disableBgBlueColor)
        .cornerRadius(.infinity)
        .disabled(!isEmailBtnEnable)
        .buttonStyle(BorderlessButtonStyle())
    }

    // MARK: Internal

    func showToast(_ type: Toast.ToastType, message: String) {
        let notiObj = ToastInfo(type: type, message: message)
        NotificationCenter.default.post(name: .showToast, object: notiObj)
    }

    func setButtonsEnableStatus() {
        guard !endPoint.isEmpty, !appId.isEmpty,
              !deviceToken.isEmpty, !deviceEncryptionKey.isEmpty,
              !otpToken.isEmpty else {
            isEmailBtnEnable = false
            return
        }

        isEmailBtnEnable = true
    }

    func verifyEmailOTP(deviceToken: String,
                        deviceEncryptionKey: String,
                        otpToken: String) {
        WalletSdk.shared.verifyOTP(deviceToken: deviceToken, encryptionKey: deviceEncryptionKey, otpToken: otpToken) { loginResult in
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
