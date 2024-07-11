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

struct PinAuthView: View {
    let model: AuthViewModel

    private let adapter = WalletSdkAdapter()

    private let blueColor = Color(red: 0 / 255.0, green: 115 / 255.0, blue: 195 / 255.0)

    private let onForgetPINPub = NotificationCenter.default.publisher(for: Notification.Name.onForgetPIN, object: nil)

    private var endPoint: String { return apiParameters.endPoint }
    private var appId: String { return apiParameters.appId }
    private var userToken: String { return apiParameters.userToken }
    private var encryptionKey: String { return apiParameters.encryptionKey }
    private var challengeId: String { return apiParameters.challengeId }
    private var enableBiometrics: Bool { return apiParameters.enableBiometrics }

    @Binding var apiParameters: SDKApiParameters
    @State var isExecuteBtnEnable = false
    @State var isSetUpBiometricsBtnEnable = false
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        pinInputView()
            .onChange(of: endPoint) {
                if let errStr = self.adapter.updateEndPoint(endPoint, appId: appId) {
                    showToast(.failure, message: "Error: " + errStr)
                }
            }
            .onChange(of: appId) {
                if let errStr = self.adapter.updateEndPoint(endPoint, appId: appId) {
                    showToast(.failure, message: "Error: " + errStr)
                }
                self.adapter.storedAppId = appId
            }
            .onAppear {
                self.adapter.initSDK(endPoint: endPoint, appId: appId)

                if let storedAppId = self.adapter.storedAppId, !storedAppId.isEmpty {
                    apiParameters.appId = storedAppId
                }

                setButtonsEnableStatus()
            }
            .onReceive(onForgetPINPub) { _ in
                showToast(.failure, message: "Register a callback function is required during the actual implementation.")
            }
    }
}

extension PinAuthView {

    // MARK: View

    @ViewBuilder
    func pinInputView() -> some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                sectionInputField(model.parameters[0].title,
                                  isRequired: model.parameters[0].isRequired,
                                  binding: $apiParameters.endPoint,
                                  isFocused: $isTextFieldFocused) {
                    setButtonsEnableStatus()
                }
                sectionInputField(model.parameters[1].title,
                                  isRequired: model.parameters[1].isRequired,
                                  binding: $apiParameters.appId,
                                  isFocused: $isTextFieldFocused) {
                    setButtonsEnableStatus()
                }
                sectionInputField(model.parameters[2].title,
                                  isRequired: model.parameters[2].isRequired,
                                  binding: $apiParameters.userToken,
                                  isFocused: $isTextFieldFocused) {
                    setButtonsEnableStatus()
                }
                sectionInputField(model.parameters[3].title,
                                  isRequired: model.parameters[3].isRequired,
                                  binding: $apiParameters.encryptionKey,
                                  isFocused: $isTextFieldFocused) {
                    setButtonsEnableStatus()
                }
                sectionInputField(model.parameters[4].title,
                                  isRequired: model.parameters[4].isRequired,
                                  binding: $apiParameters.challengeId,
                                  isFocused: $isTextFieldFocused) {
                    setButtonsEnableStatus()
                }
                sectionBiometricsSetting(binding: $apiParameters.enableBiometrics)
            }

            VStack(spacing: 16) {
                executeButton(isBtnEnable: isExecuteBtnEnable) {
                    executeChallenge(userToken: userToken, encryptionKey: encryptionKey, challengeId: challengeId)
                }
                setBiometricsButton()
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    func sectionBiometricsSetting(binding: Binding<Bool>) -> some View {
        Toggle(isOn: binding) {
            HStack(spacing: 8) {
                Image("demoFaceID")
                    .resizable()
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading) {
                    Text("Enable Biometrics Setting")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                    Text("Please create PIN before setting up Biometrics")
                        .font(.system(size: 15))
                        .foregroundColor(Color(red: 0.54, green: 0.52, blue: 0.61))
                }
            }
        }
        .tint(blueColor)
        .onChange(of: binding.wrappedValue) {
            if let errStr = self.adapter.updateEndPoint(endPoint, appId: appId, biometrics: binding.wrappedValue) {
                showToast(.failure, message: "Error: " + errStr)
            }

            setButtonsEnableStatus()
        }
    }

    @ViewBuilder
    func setBiometricsButton() -> some View {
        let disableBgColor = Color(red: 241 / 255.0, green: 249 / 255.0, blue: 254 / 255.0)

        Button {
            biometricsPIN(userToken: userToken, encryptionKey: encryptionKey)
        } label: {
            Text("Set up Biometrics")
                .font(.system(size: 14, weight: .medium))
                .frame(maxWidth: .infinity)
        }
        .frame(height: 56)
        .foregroundColor(blueColor)
        .background(isSetUpBiometricsBtnEnable ? .white : disableBgColor)
        .cornerRadius(.infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(blueColor, lineWidth: 1)
                .opacity(isSetUpBiometricsBtnEnable ? 1 : 0.5)
        )
        .opacity(isSetUpBiometricsBtnEnable ? 1 : 0.5)
        .disabled(!isSetUpBiometricsBtnEnable)
        .buttonStyle(BorderlessButtonStyle())
    }

    // MARK: Internal

    func showToast(_ type: Toast.ToastType, message: String) {
        let notiObj = ToastInfo(type: type, message: message)
        NotificationCenter.default.post(name: .showToast, object: notiObj)
    }

    func setButtonsEnableStatus() {
        guard !endPoint.isEmpty, !appId.isEmpty,
              !userToken.isEmpty, !encryptionKey.isEmpty else {
            isExecuteBtnEnable = false
            isSetUpBiometricsBtnEnable = false
            return
        }

        isExecuteBtnEnable = !challengeId.isEmpty
        isSetUpBiometricsBtnEnable = enableBiometrics
    }

    func executeChallenge(userToken: String, encryptionKey: String, challengeId: String) {
        WalletSdk.shared.execute(userToken: userToken,
                                 encryptionKey: encryptionKey,
                                 challengeIds: [challengeId]) { response in
            executeResponseHandler(response)
        }
    }

    func biometricsPIN(userToken: String, encryptionKey: String) {
        WalletSdk.shared.setBiometricsPin(userToken: userToken, encryptionKey: encryptionKey) {
            response in
            switch response.result {
            case .success(let result):
                let challengeStatus = result.status.rawValue
                let challeangeType = result.resultType.rawValue
                showToast(.success, message: "\(challeangeType) - \(challengeStatus)")

            case .failure(let error):
                showToast(.failure, message: "Error: " + error.displayString)
                errorHandler(apiError: error, onErrorController: response.onErrorController)
            }
        }
    }

    func executeResponseHandler(_ response: ExecuteCompletionStruct) {
        switch response.result {
        case .success(let result):
            let challengeStatus = result.status.rawValue
            let challeangeType = result.resultType.rawValue
            let warningType = response.onWarning?.warningType
            let warningString = warningType != nil ?
            " (\(warningType!))" : ""
            showToast(.success, message: "\(challeangeType) - \(challengeStatus)\(warningString)")

            response.onErrorController?.dismiss(animated: true)

        case .failure(let error):
            showToast(.failure, message: "Error: " + error.displayString)
            errorHandler(apiError: error, onErrorController: response.onErrorController)
        }

        if let onWarning = response.onWarning {
            print(onWarning)
        }
    }

    func errorHandler(apiError: ApiError, onErrorController: UINavigationController?) {
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
