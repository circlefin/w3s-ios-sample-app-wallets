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
import Combine
import CircleProgrammableWalletSDK

struct ExecuteChallengeView: View {
    @Environment(\.presentationMode) var presentationMode

    let headerTitleColor = Color(red: 29 / 255.0, green: 27 / 255.0, blue: 32 / 255.0)
    let showToastPub = NotificationCenter.default.publisher(for: Notification.Name("showToast"), object: nil)

    let endPoint: String
    let appId: String
    let userToken: String
    let encryptionKey: String

    private let adapter = WalletSdkAdapter()

    @State var challengeId = ""
    @State var isExecuteBtnEnable = false

    @State var showToast = false
    @State var toastMessage: String?
    @State var toastConfig: Toast.Config = .init()

    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image("ic_navi_close")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .padding(12)
                }
                .padding(.leading, 4)

                Spacer()
            }

            VStack(spacing: 24) {
                Text("Execute Challenge")
                    .font(.system(size: 22, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(headerTitleColor)
                    .frame(maxWidth: .infinity, alignment: .top)

                ScrollViewReader { scrollViewReader in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            sectionText("Encryption Key",
                                        context: encryptionKey,
                                        enableCopy: false)
                            sectionText("User Token",
                                        context: userToken,
                                        enableCopy: true)
                            sectionInputField("Challenge ID",
                                              isRequired: true,
                                              binding: $challengeId,
                                              isFocused: $isTextFieldFocused) {
                                setButtonsEnableStatus()
                            }
                            .id(3)
                        }
                        .padding(.horizontal, 16)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                    }
                    .listStyle(PlainListStyle())
                    .onAppear {
                        withAnimation(.linear(duration: 3).delay(3)) {
                            scrollViewReader.scrollTo(3)
                        }
                    }
                }

                executeButton(isBtnEnable: isExecuteBtnEnable) {
                    executeChallenge(userToken: userToken, encryptionKey: encryptionKey, challengeId: challengeId)
                }
                .padding(.horizontal, 16)
            }
        }
        .onReceive(showToastPub) { noti in
            if let toastInfo = noti.object as? ToastInfo {
                showToast(toastInfo.type, message: toastInfo.message)
            }
        }
        .onAppear {
            self.adapter.initSDK(endPoint: endPoint, appId: appId)

            setButtonsEnableStatus()
        }
        .toast(message: toastMessage ?? "",
               isShowing: $showToast,
               config: toastConfig)
    }
}

extension ExecuteChallengeView {

    // MARK: Internal

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
                                       duration: 2.0,
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
                                       duration: 10.0,
                                       statusImage: statusImage,
                                       closeImage: closeImage)
        }
    }

    func setButtonsEnableStatus() {
        guard !endPoint.isEmpty, !appId.isEmpty,
              !userToken.isEmpty, !encryptionKey.isEmpty else {
            isExecuteBtnEnable = false
            return
        }

        isExecuteBtnEnable = !challengeId.isEmpty
    }

    func executeChallenge(userToken: String, encryptionKey: String, challengeId: String) {
        WalletSdk.shared.execute(userToken: userToken,
                                 encryptionKey: encryptionKey,
                                 challengeIds: [challengeId]) { response in
            executeResponseHandler(response)
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

#Preview {
    ExecuteChallengeView(endPoint: "",
                         appId: "",
                         userToken: "User Token",
                         encryptionKey: "Encryption Key")
}
