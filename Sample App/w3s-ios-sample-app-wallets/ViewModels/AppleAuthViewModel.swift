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
import AuthenticationServices

class AppleAuthViewModel: ObservableObject {

    enum SignInState {
        case signedIn
        case signedOut
    }
    
    @Published var token: String = ""
    
    var state: SignInState = .signedOut
    
    func SignInButton(_ type: SignInWithAppleButton.Style = .black) -> some View {
        return SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case .success(let authResults):
                switch authResults.credential {
                case let appleIDCredential as ASAuthorizationAppleIDCredential:
                    self.state = .signedIn
                    print("Apple signed in successfully!")

                    if let identityToken = appleIDCredential.identityToken {
                        let jwtToken = String(decoding: identityToken, as: UTF8.self)
                        self.token = jwtToken
                        print("SSO token:\n\(jwtToken)")
                    }
                case let singleSignOnCredential as ASAuthorizationSingleSignOnCredential:
                    self.state = .signedIn
                    print("Single signed in successfully!")

                    if let identityToken = singleSignOnCredential.identityToken {
                        let jwtToken = String(decoding: identityToken, as: UTF8.self)
                        self.token = jwtToken
                        print("SSO token:\n\(jwtToken)")
                    }
                case _ as ASPasswordCredential:
                    // Sign in using an existing iCloud Keychain credential.
                    print("iCloud Keychain signed in successfully, maybe the JWT token need to get from backend service!")
                default:
                    break
                }

            case .failure(let error):
                print("Apple authorisation failed: \(error.localizedDescription)")
            }
        }
        .frame(width: nil, height: 60, alignment: .center)
        .signInWithAppleButtonStyle(type)
    }

}
