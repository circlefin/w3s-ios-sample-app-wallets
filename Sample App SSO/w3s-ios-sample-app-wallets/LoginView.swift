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
import AuthenticationServices

struct LoginView: View {
    
    // 1
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var circleViewModel: CircleWalletViewModel
    
    var body: some View {
        VStack (alignment: .center) {
            Image("circle-logo-ondark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding([.leading, .trailing],50)
                .padding([.bottom], 10)
            
            // 2
            Text("Superapp")
                .fontWeight(.black)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(.white))
                .font(.largeTitle)
                .padding([.bottom], 20)
            
            Text("Unleash the power of USDC \nand Circle Wallets.")
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 159/255, green: 114/255, blue: 255/255))
                .padding([.top, .bottom], 40)
            
            Button(action: authViewModel.signIn) {
                Text("Sign in with Google")
                    .font(.system(size:23))
                    .padding([.trailing, .leading], 43)
                    .padding([.top, .bottom], 18)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(
                            cornerRadius: 5,
                            style: .continuous
                        ).fill(Color(red: 61/255, green: 54/255, blue: 82/255))
                    )
            }
            
            authViewModel.SignInButton(SignInWithAppleButton.Style.whiteOutline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 31/255, green: 26/255, blue: 48/255))
        .onAppear(perform: {
            circleViewModel.userWallets.removeAll()
            circleViewModel.state = .notCreated
            circleViewModel.userData = nil
            circleViewModel.challengeId = ""
            circleViewModel.secretKey = ""
            circleViewModel.userToken = ""
        })
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(CircleWalletViewModel())
    }
}

