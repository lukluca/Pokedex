//
//  XCTestCase+AvailableVersion.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 6/10/2020.
//

import XCTest

extension XCTestCase {

    var iOS11: OperatingSystemVersion {
        OperatingSystemVersion(majorVersion: 11, minorVersion: 0, patchVersion: 0)
    }

    var iOS13: OperatingSystemVersion {
        OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0)
    }

    func skipIfVersionBelow(_ version: OperatingSystemVersion, _ message: @autoclosure () -> String? = nil, file: StaticString = #filePath, line: UInt = #line) throws {
        try XCTSkipUnless(ProcessInfo.processInfo.isOperatingSystemAtLeast(iOS13), message(), file: file, line: line)
    }

    func skipIfVersionAtLeast(_ version: OperatingSystemVersion, _ message: @autoclosure () -> String? = nil, file: StaticString = #filePath, line: UInt = #line) throws {
        try XCTSkipIf(ProcessInfo.processInfo.isOperatingSystemAtLeast(iOS13), message(), file: file, line: line)
    }
}
