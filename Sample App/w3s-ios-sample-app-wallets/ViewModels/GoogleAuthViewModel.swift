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
import GoogleSignIn

class GoogleAuthViewModel: ObservableObject {

    enum SignInState {
        case signedIn
        case signedOut
    }
    
    @Published var state: SignInState = .signedOut

    var token: String = ""

    func signInOutHandler() {
        state == .signedIn ? signOut() : signIn()
    }

    func signIn() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if error != nil || user == nil {
                    self.signOut()

                    if let error {
                        print(error.localizedDescription)
                    }
                } else {
                    self.state = .signedIn
                    print("Already signed in with Google!")

                    if let token = user?.idToken?.tokenString {
                        self.token = token
                        print("SSO token:\n\(token)")
                    }
                }
            }
        } else {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }

            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }

            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController, completion: { signResult, error in
                if let error {
                    print(error.localizedDescription)
                } else {
                    self.state = .signedIn
                    print("Google signed in successfully!")

                    if let token = signResult?.user.idToken?.tokenString {
                        self.token = token
                        print("SSO token:\n\(token)")
                    }
                }
            })
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()

        state = .signedOut
        print("Already Google signed out!")
    }

}
