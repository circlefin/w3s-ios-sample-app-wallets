// Copyright (c) 2023, Circle Technologies, LLC. All rights reserved.
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

struct ContentView: View {

    let adapter = WalletSdkAdapter()

    let endPoint = "https://enduser-sdk.circle.com/v1/w3s"
    @State var appId = "your-app-id" // put your App ID here programmatically

    @State var userToken = ""
    @State var encryptionKey = ""
    @State var challengeId = ""
    @State var enableBiometrics = false

    @State var showToast = false
    @State var toastMessage: String?
    @State var toastConfig: Toast.Config = .init()

    @State var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                List {
                    titleText
                    sectionEndPoint
                    sectionInputField("App ID", binding: $appId)
                    sectionInputField("User Token", binding: $userToken)
                    sectionInputField("Encryption Key", binding: $encryptionKey)
                    sectionInputField("Challenge ID", binding: $challengeId)
                    sectionToggle("Biometrics", binding: $enableBiometrics)
                    sectionButtons

//                    TestButtons
                }
                .listStyle(InsetGroupedListStyle())
                versionText
            }
            .navigationDestination(for: CircleProgrammableWalletSDK.ExecuteCompletionStruct.self) { executeResult in
                ChallengeResultView(executeResult: executeResult, path: $path)
            }
        }
        .scrollContentBackground(.hidden)
        .onAppear {
            self.adapter.initSDK(endPoint: endPoint, appId: appId)

            if let storedAppId = self.adapter.storedAppId, !storedAppId.isEmpty {
                self.appId = storedAppId
            }
        }
        .onChange(of: appId) { newValue in
            if let errStr = self.adapter.updateEndPoint(endPoint, appId: newValue, biometrics: enableBiometrics) {
                showToast(.failure, message: "Error: " + errStr)
            }
            self.adapter.storedAppId = newValue
        }
        .onChange(of: enableBiometrics) { newValue in
            if let errStr = self.adapter.updateEndPoint(endPoint, appId: appId, biometrics: newValue) {
                showToast(.failure, message: "Error: " + errStr)
            }
        }
        .toast(message: toastMessage ?? "",
               isShowing: $showToast,
               config: toastConfig)
    }

    var titleText: some View {
        Text("Programmable Wallet SDK\nSample App").font(.title2)
    }

    var versionText: some View {
        Text("CircleProgrammableWalletSDK - \(WalletSdk.shared.sdkVersion() ?? "")").font(.footnote)
    }

    var sectionEndPoint: some View {
        Section {
            Text(endPoint)
        } header: {
            Text("End Point :")
        }
    }

    func sectionInputField(_ title: String, binding: Binding<String>) -> Section<Text, some View, EmptyView> {
        Section {
            TextField(title, text: binding)
                .textFieldStyle(.roundedBorder)
        } header: {
            Text(title + " :")
        }
    }

    func sectionToggle(_ title: String, binding: Binding<Bool>) -> some View {
        Section {
            Toggle(isOn: binding) {
                HStack {
                    Text(title)
                    Image(systemName: "faceid")
                }
            }
        }
    }

    var sectionButtons: some View {
        Section {
            executeButton
            setBiometricsButton
            Spacer()
        }
    }

    var executeButton: some View {
        Button {
            guard !userToken.isEmpty else { showToast(.general, message: "User Token is Empty"); return }
            guard !encryptionKey.isEmpty else { showToast(.general, message: "Encryption Key is Empty"); return }
            guard !challengeId.isEmpty else { showToast(.general, message: "Challenge ID is Empty"); return }
            executeChallenge(userToken: userToken, encryptionKey: encryptionKey, challengeId: challengeId)

        } label: {
            Text("Execute")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .listRowSeparator(.hidden)
    }

    var setBiometricsButton: some View {
        Button {
            biometricsPIN(userToken: userToken, encryptionKey: encryptionKey)
        } label: {
            Text("Set Biometrics")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .listRowSeparator(.hidden)
        .padding([.top], 8)
    }
}

extension CircleProgrammableWalletSDK.ExecuteCompletionStruct: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(challenges)
    }

    public static func == (lhs: CircleProgrammableWalletSDK.ExecuteCompletionStruct, rhs: CircleProgrammableWalletSDK.ExecuteCompletionStruct) -> Bool {
        return lhs.challenges.first == rhs.challenges.first
    }
}

extension ContentView {

    enum ToastType {
        case general
        case success
        case failure
    }

    func showToast(_ type: ToastType, message: String) {
        toastMessage = message
        showToast = true

        switch type {
        case .general:
            toastConfig = Toast.Config()
        case .success:
            toastConfig = Toast.Config(backgroundColor: .green, duration: 2.0)
        case .failure:
            toastConfig = Toast.Config(backgroundColor: .pink, duration: 10.0)
        }
    }

    func executeChallenge(userToken: String, encryptionKey: String, challengeId: String) {
        var showChallengeResult = true

        WalletSdk.shared.execute(userToken: userToken,
                                 encryptionKey: encryptionKey,
                                 challengeIds: [challengeId]) { response in
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

                if error.errorCode == .userCanceled {
                    showChallengeResult = false
                }
            }

            if let onWarning = response.onWarning {
                print(onWarning)
            }

            if showChallengeResult {
                path.append(response)
            }
        }
    }

    func biometricsPIN(userToken: String, encryptionKey: String) {
        guard !userToken.isEmpty else { showToast(.general, message: "User Token is Empty"); return }
        guard !encryptionKey.isEmpty else { showToast(.general, message: "Encryption Key is Empty"); return }

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

    var TestButtons: some View {
        Section {
            Button("New PIN", action: newPIN)
            Button("Change PIN", action: changePIN)
            Button("Restore PIN", action: restorePIN)
            Button("Enter PIN", action: enterPIN)
            Button("Set Biometrics PIN") {
                biometricsPIN(userToken: userToken, encryptionKey: encryptionKey)
            }

        } header: {
            Text("UI Customization Entry")
                .font(.title3)
                .fontWeight(.semibold)
        }
    }

    func newPIN() {
        WalletSdk.shared.execute(userToken: "", encryptionKey: "", challengeIds: ["ui_new_pin"])
    }

    func enterPIN() {
        WalletSdk.shared.execute(userToken: "", encryptionKey: "", challengeIds: ["ui_enter_pin"])
    }

    func changePIN() {
        WalletSdk.shared.execute(userToken: "", encryptionKey: "", challengeIds: ["ui_change_pin"])
    }

    func restorePIN() {
        WalletSdk.shared.execute(userToken: "", encryptionKey: "", challengeIds: ["ui_restore_pin"])
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
