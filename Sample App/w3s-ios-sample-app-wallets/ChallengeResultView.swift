//
//  ChallengeResultView.swift
//  w3s-ios-sample-app-wallets
//
//  Created by CIRCLE on 2023/11/1.
//

import SwiftUI
import CircleProgrammableWalletSDK

struct ChallengeResultView: View {
    var executeResult: CircleProgrammableWalletSDK.ExecuteCompletionStruct

    @Binding var path: NavigationPath

    @State var challengeId: String = ""

    @State var showToast = false
    @State var toastMessage: String?
    @State var toastConfig: Toast.Config = .init()

    var body: some View {
        VStack {
            List {
                /// Section I
                if let challengeId = executeResult.challenges.first {
                    sectionInputField("Challenge ID", text: challengeId)
                }

                /// Section II
                switch executeResult.result {
                case .success(let result):
                    let challeangeType = result.resultType.rawValue
                    sectionInputField("Challeange Type", text: challeangeType)

                    let challengeStatus = result.status.rawValue
                    sectionInputField("Challenge Status", text: challengeStatus)

                    /// Support from version 1.0.11 (622)
                    if let signature = result.data?.signature {
                        sectionInputField("Signature", text: signature)
                    }

                case .failure(let error):
                    let errorCode = error.errorCode
                    sectionInputField("Error Code", text: String(describing: errorCode))

                    let errorDisplayString = error.displayString
                    sectionInputField("Error Message", text: errorDisplayString)
                }

                /// Section III
                if let executeWarning = executeResult.onWarning {
                    let warningType = executeWarning.warningType
                    sectionInputField("Warning Type", text: String(describing: warningType))

                    let warningString = executeWarning.warningString
                    sectionInputField("Warning Message", text: warningString)
                }
            }
            .listStyle(InsetGroupedListStyle())
            versionText
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.navigationBarLeading) {
                Button {
                    path.removeLast()
                } label: {
                    Image(uiImage: UIImage(named: "ic_navi_back")!)
                }
            }
        }
        .toast(message: toastMessage ?? "",
               isShowing: $showToast,
               config: toastConfig)
    }

    var versionText: some View {
        Text("CircleProgrammableWalletSDK - \(WalletSdk.shared.sdkVersion() ?? "")").font(.footnote)
    }

    func sectionInputField(_ title: String, text: String) -> Section<Text, some View, EmptyView> {
        Section {
            Button(action: {
                UIPasteboard.general.string = text
                showToast(message: "Copied: \(text)")
            }) {
                Text(text)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle)
        } header: {
            Text(title + " :")
        }
    }
}

extension ChallengeResultView {

    func showToast(message: String) {
        toastMessage = message
        showToast = true

        toastConfig = Toast.Config()
    }

}
