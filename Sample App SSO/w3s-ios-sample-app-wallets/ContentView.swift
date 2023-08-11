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

class AppState: ObservableObject {
    var authViewModel = AuthenticationViewModel()
    var circleWalletViewModel = CircleWalletViewModel()
}

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    var body: some View {
        
        switch authViewModel.state {
            //        case .signedIn: HomeView()
        case .signedIn: if UserDefaults.standard.string(forKey: "circleUserToken") == nil { CircleLoadingView() } else { HomeView() }
        case .signedOut: LoginView()
        case .circleSuccessful: HomeView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
