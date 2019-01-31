# iOS Dashboard UI
[![Travis](https://img.shields.io/travis/stripe/ios-dashboard-ui/master.svg?style=flat)](https://travis-ci.org/stripe/ios-dashboard-ui)
[![CocoaPods](https://img.shields.io/cocoapods/v/StripeDashboardUI.svg?style=flat)](http://cocoapods.org/?q=name%3Astripedashboardui)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/l/StripeDashboardUI.svg?style=flat)](https://github.com/stripe/ios-dashboard-ui/blob/master/LICENSE)
[![CocoaPods](https://img.shields.io/cocoapods/p/StripeDashboardUI.svg?style=flat)](https://github.com/stripe/ios-dashboard-ui#)

This is a collection of UI components used in the [Stripe Dashboard](https://itunes.apple.com/us/app/stripe-dashboard/id978516833?mt=8). Currently, it only contains one component, `MoneyTextField`, but there's more to come!

## Installation
* [Cocoapods](https://cocoapods.org/pods/StripeDashboardUI)
  * `pod "StripeDashboardUI"`
* [Carthage](https://github.com/Carthage/Carthage#installing-carthage)
  * `github "stripe/ios-dashboard-ui"`
* Manual
  * drag source files from the `DashboardUI` directory into your project.
* Development
  * Run `make bootstrap` to install dependencies.

Swift 4

## Components
### MoneyTextField
MoneyTextField is a text field for handling money. It includes many customization options, and supports most currencies and locales. 💸

<img src="https://cloud.githubusercontent.com/assets/894119/17221400/c4afee62-54c1-11e6-943e-6f3b81a573aa.gif" width="400px">
