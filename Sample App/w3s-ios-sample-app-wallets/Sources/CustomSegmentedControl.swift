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

struct CustomSegmentedControl: View {
    let totalIndex: Int
    @Binding var selectedIndex: Int

    let selectedColor = Color(red: 41 / 255.0, green: 35 / 255.0, blue: 59 / 255.0)
    let unselectedColor = Color(red: 138 / 255.0, green: 132 / 255.0, blue: 156 / 255.0)

    var userTypes = UserType.allCases.map { $0.rawValue }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<totalIndex, id: \.self) { index in
                VStack(spacing: 0) {
                    Button {
                        selectedIndex = index
                    } label: {
                        Text("\(userTypes[index])")
                            .foregroundColor(selectedIndex == index ? selectedColor : unselectedColor)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 24)
                            .padding(.bottom, 16)
                    }
                    .buttonStyle(BorderlessButtonStyle())

                    Rectangle()
                        .fill(selectedIndex == index ? selectedColor : unselectedColor)
                        .frame(maxWidth: .infinity,
                               minHeight: selectedIndex == index ? 2 : 1,
                               maxHeight: selectedIndex == index ? 2 : 1)
                }
            }
        }
        .padding(.bottom, 24)
    }
}

#Preview {
    CustomSegmentedControl(totalIndex: UserType.allCases.count, selectedIndex: .constant(0))
}
