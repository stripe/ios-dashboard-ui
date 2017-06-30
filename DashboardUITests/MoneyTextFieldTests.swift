//
//  MoneyTextFieldTests.swift
//  MoneyTextFieldTests
//
//  Created by Ben Guo on 6/28/16.
//  Copyright © 2016 stripe. All rights reserved.
//

import XCTest
import FBSnapshotTestCase
import StripeDashboardUI

class MoneyTextFieldTests: FBSnapshotTestCase {

    override func setUp() {
        super.setUp()
//        self.recordMode = true
    }
    
    func testInit() {
        var sut = MoneyTextField(amount: 100000, currency: "usd")
        sut.sizeToFit()
        FBSnapshotVerifyView(sut, identifier: "100000_usd")

        sut = MoneyTextField(amount: 50, currency: "usd")
        sut.sizeToFit()
        FBSnapshotVerifyView(sut, identifier: "50_usd")

        sut = MoneyTextField(amount: 0, currency: "usd")
        sut.sizeToFit()
        FBSnapshotVerifyView(sut, identifier: "0_usd")

        sut = MoneyTextField(amount: 100000, currency: "jpy")
        sut.sizeToFit()
        FBSnapshotVerifyView(sut, identifier: "1000000_jpy")

        sut = MoneyTextField(amount: 50, currency: "jpy")
        sut.sizeToFit()
        FBSnapshotVerifyView(sut, identifier: "50_jpy")

        sut = MoneyTextField(amount: 0, currency: "jpy")
        sut.sizeToFit()
        FBSnapshotVerifyView(sut, identifier: "0_jpy")

        sut = MoneyTextField(amount: 123, currency: "jod")
        sut.sizeToFit()
        FBSnapshotVerifyView(sut, identifier: "123_jod")
    }

    func testConfigure() {
        let sut = MoneyTextField(amount: 100000, currency: "usd")
        sut.sizeToFit()
        FBSnapshotVerifyView(sut, identifier: "1-original")
        sut.usesGroupingSeparator = false
        sut.sizeToFit()
        FBSnapshotVerifyView(sut, identifier: "2-usesGroupingSeparator=false")
        sut.currency = "gbp"
        sut.sizeToFit()
        FBSnapshotVerifyView(sut, identifier: "3-currency=gbp")
        sut.amount = 50
        sut.sizeToFit()
        FBSnapshotVerifyView(sut, identifier: "4-amount=50")
    }

}
