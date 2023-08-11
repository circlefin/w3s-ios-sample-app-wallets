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
import GoogleSignIn

struct HomeView: View {
    // 1
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @EnvironmentObject var circleWalletViewModel: CircleWalletViewModel
    
    // 2
    private let user = GIDSignIn.sharedInstance.currentUser
    @State var buttonText = "Copy"
    @State var showToast = false
    @State var toastMessage: String?
    @State var toastConfig: Toast.Config = .init()
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let fullname = UserDefaults.standard.string(forKey: "userFullName")
    let email = UserDefaults.standard.string(forKey: "userEmail")
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Wallet")
                                .font(.system(size: 30, weight: .bold))
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    if self.fullname != nil || self.email != nil || user?.profile != nil {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user?.profile?.name ?? self.fullname ?? "")
                                    .font(.headline)
                                
                                Text(user?.profile?.email ?? self.email ?? "")
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(5)
                        .padding()
                    }
                    
                    ForEach(circleWalletViewModel.userWallets.indices, id:\.self) { i in
                        VStack(alignment: .leading) {
                            Text("Blockchain")
                                .font(.headline)
                            Text("\(circleWalletViewModel.userWallets[i].blockchain)")
                                .font(.subheadline)
                            Text("Address")
                                .font(.headline)
                            HStack{
                                Text("\(circleWalletViewModel.userWallets[i].address)")
                                //.frame(width: UIScreen.main.bounds.width)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .font(.subheadline)
                                    .textSelection(.enabled)
                                Button {
                                    UIPasteboard.general.string = circleWalletViewModel.userWallets[i].address
                                } label: {
                                    Label(buttonText, systemImage: "doc.on.doc")
                                        .font(.subheadline)
                                        .onTapGesture {
                                            // show toast
                                            showToast(.success, message: "Address copied.");
                                        }
                                }
                            }
                            if circleWalletViewModel.userWallets[i].balances.isEmpty {
                                HStack {
                                    self.getTokenIcon(tokenSymbol: "USDC")
                                    
                                    Text("USDC")
                                        .font(.headline)
                                        .padding()
                                    
                                    Spacer()
                                    
                                    Text("0.00")
                                        .font(.headline)
                                        .padding(.trailing, 50)
                                }
                                .frame(height: 30)
                            }
                            ForEach(circleWalletViewModel.userWallets[i].balances.indices, id:\.self) { j in
                                HStack {
                                    self.getTokenIcon(tokenSymbol: circleWalletViewModel.userWallets[i].balances[j].token.symbol)
                                    
                                    Text("\(circleWalletViewModel.userWallets[i].balances[j].token.symbol)")
                                        .font(.headline)
                                        .padding()
                                    
                                    Spacer()
                                    
                                    if circleWalletViewModel.userWallets[i].balances.indices.contains(j) {
                                        Text("\(circleWalletViewModel.userWallets[i].balances[j].amount)")
                                            .font(.headline)
                                            .padding(.trailing, 50)
                                    } else {
                                        Text("0.00")
                                            .font(.headline)
                                            .padding(.trailing, 50)
                                    }
                                }
                                .frame(height: 30)
                            }
                            
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(5)
                        .padding()
                        
                        //                        HStack {
                        //                            // 3
                        //                            VStack(alignment: .leading) {
                        //                                Group{
                        //                                    Text("Id")
                        //                                        .font(.headline)
                        //                                    Text(String(circleWalletViewModel.userWallets[i].id))
                        //                                        .font(.subheadline)
                        //
                        //                                    Text("Blockchain")
                        //                                        .font(.headline)
                        //                                    Text("\(circleWalletViewModel.userWallets[i].blockchain)")
                        //                                        .font(.subheadline)
                        //                                    Text("Address")
                        //                                        .font(.headline)
                        //                                    Text("\(circleWalletViewModel.userWallets[i].address)")
                        //                                        .font(.subheadline)
                        //                                    Button {
                        //                                        UIPasteboard.general.string = circleWalletViewModel.userWallets[i].address
                        //                                    } label: {
                        //                                        Label(buttonText, systemImage: "doc.on.doc")
                        //                                            .font(.subheadline)
                        //                                            .onTapGesture {
                        //                                                // show toast
                        //                                                showToast(.success, message: "Address copied.");
                        //                                            }
                        //                                    }
                        //                                    Text("Balance")
                        //                                        .font(.headline)
                        //                                    if circleWalletViewModel.userWalletBalances.indices.contains(i) {
                        //                                        Text("\(circleWalletViewModel.userWalletBalances[i]?.amount ?? "0")")
                        //                                            .font(.subheadline)
                        //                                    } else {
                        //                                        Text("0")
                        //                                            .font(.subheadline)
                        //                                    }
                        //                                }
                        //                                .textSelection(.enabled)
                        //                                /*Group {
                        //                                 Text("Id")
                        //                                 .font(.headline)
                        //                                 Text(String(wallet.id))
                        //                                 .font(.subheadline)
                        //
                        //                                 Text("State")
                        //                                 .font(.headline)
                        //                                 Text("\(wallet.state)")
                        //                                 .font(.subheadline)
                        //
                        //                                 Text("Wallet Set Id")
                        //                                 .font(.headline)
                        //                                 Text("\(wallet.walletSetId)")
                        //                                 .font(.subheadline)
                        //
                        //                                 Text("Custody Type")
                        //                                 .font(.headline)
                        //                                 Text("\(wallet.custodyType)")
                        //                                 .font(.subheadline)
                        //                                 }
                        //                                 Group {
                        //                                 Text("User Id")
                        //                                 .font(.headline)
                        //                                 Text("\(wallet.userId)")
                        //                                 .font(.subheadline)
                        //
                        //                                 Text("Address")
                        //                                 .font(.headline)
                        //                                 Text("\(wallet.address)")
                        //                                 .font(.subheadline)
                        //
                        //                                 Text("Blockchain")
                        //                                 .font(.headline)
                        //                                 Text("\(wallet.blockchain)")
                        //                                 .font(.subheadline)
                        //                                 }*/
                        //                            }
                        //
                        //                        }
                        //                        .padding()
                        //                        .frame(maxWidth: .infinity)
                        //                        .background(Color(.secondarySystemBackground))
                        //                        .cornerRadius(5)
                        //                        .padding()
                    }
                    
                    Spacer()
                    
                    // 4
                    Button(action: viewModel.signOut) {
                        Text("SIGN OUT")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 24/255, green: 148/255, blue: 232/255))
                            .cornerRadius(5)
                            .padding()
                    }
                }
                .toolbar(content: {
                    Image("circle-logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    //.padding([.leading, .trailing], 100)
                        .padding([.top, .bottom], 10)
                })
            }
            .refreshable {
                circleWalletViewModel.getWallets()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 225/255, green: 223/255, blue: 232/255))
            .navigationViewStyle(StackNavigationViewStyle())
            .task{
                circleWalletViewModel.getWallets()
            }
            .toast(message: toastMessage ?? "",
                   isShowing: $showToast,
                   config: toastConfig)
        }
    }
    
}

extension HomeView {
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
    
    func getTokenIcon(tokenSymbol: String) -> some View {
        let imageName: String
        switch tokenSymbol {
        case "AVAX-FUJI", "AVAX":
            imageName = "icon-AVAX"
        case "MATIC-MUMBAI", "MATIC":
            imageName = "icon-MATIC"
        case "USDC":
            imageName = "icon-USDCoin"
        default:
            imageName = ""
        }
        
        return Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(.leading, 10)
    }
}

/// A generic view that shows images from the network.
struct NetworkImage: View {
    let url: URL?
    
    var body: some View {
        if let url = url,
           let data = try? Data(contentsOf: url),
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            Image(systemName: "person.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthenticationViewModel())
            .environmentObject(CircleWalletViewModel())
    }
}

