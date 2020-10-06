//
//  XCTestCase+DummyError.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 6/10/2020.
//

import XCTest

extension XCTestCase {

    var iOS13: OperatingSystemVersion {
        OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0)
    }

    func skipIfVersionBelow(_ version: OperatingSystemVersion) throws {
        try XCTSkipUnless(ProcessInfo.processInfo.isOperatingSystemAtLeast(iOS13))
    }

    func skipIfVersionAtLeast(_ version: OperatingSystemVersion) throws {
        try XCTSkipIf(ProcessInfo.processInfo.isOperatingSystemAtLeast(iOS13))
    }
}
