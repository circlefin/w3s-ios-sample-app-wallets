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

import UIKit
import CircleProgrammableWalletSDK

class WalletSdkAdapter {

    @UserDefault("storedAppId", defaultValue: nil)
    var storedAppId: String?

    func initSDK(endPoint: String, appId: String) {
        self.updateEndPoint(endPoint, appId: appId)

        WalletSdk.shared.setLayoutProvider(self)
        WalletSdk.shared.setErrorMessenger(self)
        WalletSdk.shared.setDelegate(self)
    }

    @discardableResult
    func updateEndPoint(_ endPoint: String, appId: String, biometrics: Bool = false) -> String? {
        let _appId = appId.trimmingCharacters(in: .whitespacesAndNewlines)
        let settings: WalletSdk.SettingsManagement = .init(enableBiometricsPin: biometrics)
        let configuration = WalletSdk.Configuration(endPoint: endPoint, appId: _appId, settingsManagement: settings)

        do {
            try WalletSdk.shared.setConfiguration(configuration)
            print("Configuration Success")
            return nil
        } catch {
            let configurationErrorString: String

            if let apiError = error as? ApiError {
                print(apiError)
                configurationErrorString = apiError.displayString
            } else {
                print(error.localizedDescription)
                configurationErrorString = error.localizedDescription
            }

            return configurationErrorString
        }
    }
}

extension WalletSdkAdapter: WalletSdkLayoutProvider {

    func securityQuestions() -> [SecurityQuestion] {
        return [
            SecurityQuestion(title: "What is your father’s middle name?", inputType: .text),
            SecurityQuestion(title: "What is your favorite sports team?", inputType: .text),
            SecurityQuestion(title: "What is your mother’s maiden name?", inputType: .text),
            SecurityQuestion(title: "What is the name of your first pet?", inputType: .text),
            SecurityQuestion(title: "What is the name of the city you were born in?", inputType: .text),
            SecurityQuestion(title: "What is the name of the first street you lived on?", inputType: .text),
            SecurityQuestion(title: "When is your father’s birthday?", inputType: .datePicker),
        ]
    }

    func securityQuestionsRequiredCount() -> Int {
        return 2
    }

    func securityConfirmItems() -> [SecurityConfirmItem] {
        return [
            SecurityConfirmItem(image: UIImage(named: "img_item_1"),
                                text: "This is the only way to recover my account access."),
            SecurityConfirmItem(image: UIImage(named: "img_item_2"),
                                text: "Circle won’t store my answers so it’s my responsibility to remember them."),
            SecurityConfirmItem(image: UIImage(named: "img_item_3"),
                                text: "I will lose access to my wallet and my digital assets if I forget my answers."),
        ]
    }

    func imageStore() -> ImageStore {
        let local: [ImageStore.Img: UIImage] = [
            .naviBack: UIImage(named: "ic_navi_back")!,
            .naviClose: UIImage(named: "ic_navi_close")!,
            .selectCheckMark: UIImage(named: "ic_checkmark")!,
            .dropdownArrow: UIImage(named: "ic_trailing_down")!,
            .errorInfo: UIImage(named: "ic_warning_alt")!,
            .securityIntroMain: UIImage(named: "img_security_intro")!,
            .securityConfirmMain: UIImage(named: "img_confirmation")!,
            .biometricsAllowMain: UIImage(named: "ic_biometrics")!,
            .hidePin: UIImage(named: "eye_closed")!,
            .showPin: UIImage(named: "eye_open")!
        ]

        let remote: [ImageStore.Img: URL] = [:]

        // MARK: Sample - Remote images
//        let remote: [ImageStore.Img: URL]
//        let imageUrl1 = URL(string: "https://www.circle.com/hs-fs/hubfs/Sundaes/810/global-payments-810x810.png")
//        let imageUrl2 = URL(string: "https://www.circle.com/hs-fs/hubfs/Sundaes/810/Trust-810x810.png")
//        if let imageUrl1, let imageUrl2 {
//            remote = [
//                .securityIntroMain: imageUrl1,
//                .securityConfirmMain: imageUrl2,
//            ]
//        } else {
//            remote = [:]
//        }

        return ImageStore(local: local, remote: remote)
    }

    func displayDateFormat() -> String {
        return "yyyy/MM/dd"
    }

    // MARK: Sample - Set theme & font programmatically
//    func themeFont() -> ThemeConfig.ThemeFont? {
//        return ThemeConfig.ThemeFont(
//            ultraLight: nil,
//            thin: nil,
//            light: "CustomFont-Light",
//            regular: "CustomFont-Regular",
//            medium: "CustomFont-Medium",
//            semibold: "CustomFont-SemiBold",
//            bold: "CustomFont-Bold",
//            heavy: nil,
//            black: nil
//        )
//    }
}


extension WalletSdkAdapter: WalletSdkDelegate {

    func walletSdk(willPresentController controller: UIViewController) {
        print("willPresentController: \(controller)")

        // MARK: Sample - UI manipuation in run time
//        if let controller = controller as? NewPINCodeViewController {
//            controller.titleLabel1.text = "Hello World"
//            controller.titleLabel1.textColor = .blue
//            controller.titleLabel1.font = .systemFont(ofSize: 28, weight: .black)
//
//        }
//
//        if let controller = controller as? SecurityConfirmViewController {
//            controller.imageBgView.backgroundColor = .blue
//            controller.imageView.contentMode = .scaleAspectFill
//        }
    }

    func walletSdk(controller: UIViewController, onForgetPINButtonSelected onSelect: Void) {
        print("onForgetPINButtonSelected")
    }
}

extension WalletSdkAdapter: ErrorMessenger {

    func getErrorString(_ code: ApiError.ErrorCode) -> String? {

        return nil

        // MARK: Sample - Error message customization
//        switch code {
//        case .hintsMatchAnswers:
//            return "Your custom error message."
//
//        case .networkError:
//            return "Your custom error message."
//
//        default:
//            return nil
//        }
    }
}
