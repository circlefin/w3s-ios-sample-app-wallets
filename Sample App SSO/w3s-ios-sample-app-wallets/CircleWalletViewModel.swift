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

class CircleWalletViewModel: ObservableObject {
    enum CircleWalletState {
        case notCreated
        case userTokenSecretKeychallengeIdCreated
        case userTokenSecretKeychallengeIdCreationFailed
        case challengeSuccessful
        case challengeFailed
    }
    
    struct UserData: Codable {
        let userId: String
        let userToken: String
        let secretKey: String
        let challengeId: String
    }
    
    struct UserWallet: Identifiable, Decodable {
        let id: String
        let state: String
        let walletSetId: String
        let custodyType: String
        let userId: String
        let address: String
        let addressIndex: Int
        let blockchain: String
        let updateDate: String
        let createDate: String
        var balances = [TokenBalance]()
        
        private enum CodingKeys: String, CodingKey {
            case id, state, walletSetId, custodyType, userId, address, addressIndex, blockchain, updateDate, createDate
        }
    }
    
    struct Token: Identifiable, Codable {
        let id: String
        let blockchain: String
        let tokenAddress: String
        let standard: String
        let name: String
        let symbol: String
        let decimals: Int
        let isNative: Bool
        let updateDate: String
        let createDate: String
    }
    
    struct TokenBalance: Codable {
        let token: Token
        let amount: String
        let updateDate: String
    }
    
    struct CircleCode: Codable {
        let code: Int
        let message: String
    }
    
    @Published var userWallets: [UserWallet] = []
    
    @Published var state: CircleWalletState = .notCreated
    @Published var userData: UserData?
    
    @Published var userToken: String = ""
    @Published var secretKey: String = ""
    @Published var challengeId: String = ""
    @Published var userId: String = ""
    
    let circleBaseURI: String = "http://localhost:3000"
    
    func createAndInitUser() {
        var request = URLRequest(url: URL(string: circleBaseURI + "/api/user")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let userData = try? JSONDecoder().decode(UserData.self, from: data) {
                    print(userData)
                    DispatchQueue.main.async{
                        self.userToken = userData.userToken
                        UserDefaults.standard.set(self.userToken, forKey: "circleUserToken")
                        self.secretKey = userData.secretKey
                        self.challengeId = userData.challengeId
                        self.userId = userData.userId
                        UserDefaults.standard.set(self.userId, forKey: "circleUserId")
                        self.state = .userTokenSecretKeychallengeIdCreated
                    }
                } else {
                    print("Invalid Response")
                    self.state = .userTokenSecretKeychallengeIdCreationFailed
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
                self.state = .userTokenSecretKeychallengeIdCreationFailed
            }
        }
        
        task.resume()
    }
    
    func executeChallenge() {
        WalletSdk.shared.execute(userToken: self.userToken,
                                 encryptionKey: self.secretKey,
                                 challengeIds: [self.challengeId]) { response in
            switch response.result {
            case .success(let result):
                let challengeStatus = result.status.rawValue
                let challeangeType = result.resultType.rawValue
                print("\(challeangeType) - \(challengeStatus)")
                self.state = .challengeSuccessful
                
            case .failure(let error):
                self.errorHandler(apiError: error, onErrorController: response.onErrorController)
                self.state = .challengeFailed
            }
        }
    }
    
    func refreshUserToken() {
        var request = URLRequest(url: URL(string: circleBaseURI + "/api/user/token")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        let userId = UserDefaults.standard.string(forKey: "circleUserId")!
        let body: [String: String] = ["userId": userId]
        let finalBody = try? JSONSerialization.data(withJSONObject: body)
        
        request.httpBody = finalBody
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let userData = try? JSONDecoder().decode(UserData.self, from: data) {
                    //print(userData)
                    DispatchQueue.main.async{
                        self.userToken = userData.userToken
                        UserDefaults.standard.set(self.userToken, forKey: "circleUserToken")
                        self.secretKey = userData.secretKey
                        self.challengeId = userData.challengeId
                        self.userId = userData.userId
                        UserDefaults.standard.set(self.userId, forKey: "circleUserId")
                        self.state = .userTokenSecretKeychallengeIdCreated
                        self.getWallets()
                    }
                } else {
                    print("Invalid Response")
                    self.state = .userTokenSecretKeychallengeIdCreationFailed
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
                self.state = .userTokenSecretKeychallengeIdCreationFailed
            }
        }
        
        task.resume()
    }
    
    func getWallets() {
        var request = URLRequest(url: URL(string: circleBaseURI + "/api/wallets")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(UserDefaults.standard.string(forKey: "circleUserToken") ?? "", forHTTPHeaderField: "X-User-Token")
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 500:
                    print(String(data: data, encoding: .utf8) ?? "")
                    if let codeObj = try? JSONDecoder().decode(CircleCode.self, from: data) {
                        print(codeObj)
                        DispatchQueue.main.async{
                            if codeObj.code == 155104 {
                                self.refreshUserToken();
                            }
                        }
                    } else {
                        print("Error")
                    }
                    
                default:
                    if let wallets = try? JSONDecoder().decode([UserWallet].self, from: data) {
                        DispatchQueue.main.async{
                            //print(wallets)
                            if wallets.isEmpty {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    //print("Getting wallets again...")
                                    self.getWallets()
                                }
                            } else {
                                //print("Received wallets...")
                                // Re-populate arrays with updated wallets and balances
                                self.userWallets.removeAll()
                                var walletIndex = 0
                                for wallet in wallets {
                                    self.userWallets.append(wallet)
                                    //print(wallet)
                                    self.getWalletBalance(walletIndex: walletIndex, walletId: wallet.id)
                                    walletIndex += 1
                                }
                            }
                        }
                    }
                }
                
            }
        }
        task.resume()
    }
    
    func getWalletBalance(walletIndex: Int, walletId: String) {
        var request = URLRequest(url: URL(string: circleBaseURI + "/api/wallets/" + walletId + "/balances")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(UserDefaults.standard.string(forKey: "circleUserToken") ?? "", forHTTPHeaderField: "X-User-Token")
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let balances = try? JSONDecoder().decode([TokenBalance].self, from: data) {
                    //print(balances)
                    DispatchQueue.main.async{
                        for balance in balances {
                            self.userWallets[walletIndex].balances.append(balance)
                            //print(self.userWallets[walletIndex].balances)
                        }
                    }
                } else {
                    print("Invalid Response")
                }
            } else if let error = error {
                print("HTTP Request Failed \(error)")
            }
        }
        
        task.resume()
    }
    
    func errorHandler(apiError: ApiError, onErrorController: UINavigationController?) {
        switch apiError.errorCode {
        case .userHasSetPin:
            onErrorController?.dismiss(animated: true)
        default:
            break
        }
    }
}
