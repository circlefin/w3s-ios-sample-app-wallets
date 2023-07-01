# w3s-ios-sample-app-wallets

This is a sample project for iOS beginners to integrate with CircleProgrammableWalletSDK

- Bookmark
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Run the project](#run-the-project)
---

## Requirements

### Xcode
Install Apple’s Xcode development software: [Xcode in the Apple App Store](https://apps.apple.com/tw/app/xcode/id497799835?mt=12).

### CocoaPods
**CocoaPods** is a dependency manager for iOS projects. [Install CocoaPods by Homebrew](https://formulae.brew.sh/formula/cocoapods). (suggested)

> Check if Homebrew is installed:
```shell
$ brew
```
> How to install Homebrew in MacOS: [Link](https://mac.install.guide/homebrew/3.html)

## Installation

1. Clone this repo
2. Open project folder `$ cd w3s-ios-sample-app-wallets`
3. Run `$ pod install` to install `CircleProgrammableWalletSDK`
4. Run `$ pod update` to update SDK (Optional)
5. Open the `.xcworkspace` file in Xcode
<img src="readme_images/screenshot_2.png" width="400"/>

## Run the project

1. Select a simulator as run target
2. press `Run` button (Command + R)
![image](readme_images/screenshot_3.png)

3. Set your `AppID` in the simulator
<img src="readme_images/screenshot_1.png" width="350"/>

4. (Optional) Setup configs programmatically

    ![image](readme_images/screenshot_4.png)
    - Set the `appId` in the `ContentView.swift`
    - Set the `endPoint` in the `ContentView.swift`
