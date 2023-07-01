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
        WalletSdk.shared.setDelegate(self)
    }

    func updateEndPoint(_ endPoint: String, appId: String) {
        let _appId = appId.trimmingCharacters(in: .whitespacesAndNewlines)
        let configuration = WalletSdk.Configuration(endPoint: endPoint, appId: _appId)

        do {
            try WalletSdk.shared.setConfiguration(configuration)
            print("Configuration Success")
        } catch {

        }
    }
}

extension WalletSdkAdapter: WalletSdkLayoutProvider {

    func securityQuestions() -> [SecurityQuestion] {
        return [
            SecurityQuestion(title: "What is your childhood nickname?", inputType: .text),
            SecurityQuestion(title: "What is the middle name of your oldest child?", inputType: .text),
            SecurityQuestion(title: "What is your favorite team?", inputType: .text),
            SecurityQuestion(title: "When was your birthday?", inputType: .datePicker),
            SecurityQuestion(title: "When is your marriage anniversary?", inputType: .datePicker),
        ]
    }

    func securityQuestionsRequiredCount() -> Int {
        return 2
    }

    func securityConfirmItems() -> [SecurityConfirmItem] {
        return [
            SecurityConfirmItem(image: UIImage(named: "img_info"),
                                text: "This is the only way to recover my account access."),
            SecurityConfirmItem(image: UIImage(named: "img_claim_success"),
                                text: "Circle won’t store my answers so it’s my responsibility to remember them."),
            SecurityConfirmItem(image: UIImage(named: "img_claim_success"),
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
            .securityConfirmMain: UIImage(named: "img_driver_blog")!
        ]

        let remote: [ImageStore.Img : URL] = [:]

        return ImageStore(local: local, remote: remote)
    }

    func displayDateFormat() -> String {
        return "yyyy/MM/dd"
    }
}


extension WalletSdkAdapter: WalletSdkDelegate {

    func walletSdk(willPresentController controller: UIViewController) {
        print("willPresentController: \(controller)")
    }

    func walletSdk(controller: UIViewController, onForgetPINButtonSelected onSelect: Void) {
        print("onForgetPINButtonSelected")
    }
}
