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

import FBSDKLoginKit

class FacebookAuthViewModel: ObservableObject {

    enum SignInState {
        case signedIn
        case signedOut
    }

    let loginManager = LoginManager()

    @Published var state: SignInState = .signedOut

    var token: String = ""

    func signInOutHandler() {
        state == .signedIn ? signOut() : signIn()
    }

    func signIn() {
        loginManager.logIn(permissions: ["public_profile", "email"], from: nil) { loginResult, error in
            if let loginResult {
                if loginResult.isCancelled {
                    print("User cancel sign in with Facebook")
                } else {
                    self.state = .signedIn
                    print("Facebook signed in successfully!")

                    if let jwtToken = loginResult.token?.tokenString {
                        self.token = jwtToken
                    }
                }
            } else if let error {
                print("Facebook authorisation failed: \(error.localizedDescription)")
            }
        }
    }

    func signOut() {
        loginManager.logOut()

        state = .signedOut
        print("Already Facebook signed out!")
    }

}
