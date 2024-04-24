//
//  Tests.swift
//  Tests
//
//  Created by Alex Khuala on 24.04.24.
//

import XCTest
@testable import homework_img_ly

final class Tests: XCTestCase 
{
    var sut: KHContentManager!
    let networkMonitor = KHNetworkMonitor.shared

    override func setUpWithError() throws 
    {
        try super.setUpWithError()
        self.sut = KHContentManager.shared
    }

    override func tearDownWithError() throws 
    {
        self.sut = nil
        try super.tearDownWithError()
    }

    func testTreeParser() throws
    {
        XCTAssert(self.sut.entries.isEmpty)
     
        // given
        let promise = expectation(description: "Completion handler invoked")
        self.sut.local = true
        
        // when
        self.sut.loadTree {
            promise.fulfill()
        }
        wait(for: [promise], timeout: 3)
        
        // then
        XCTAssertFalse(self.sut.entries.isEmpty)
    }
    
    func testDetailsParser() throws
    {
        // given
        let promise = expectation(description: "Completion handler invoked")
        self.sut.local = true
        var entry: KHDetailsEntry?
        
        // when
        self.sut.loadDetails("id_1") { result in
            entry = result
            promise.fulfill()
        }
        wait(for: [promise], timeout: 3)
        
        // then
        XCTAssertNotNil(entry)
    }
    
    func testRemoteTreeDataParser() throws
    {
        try XCTSkipUnless(self.networkMonitor.isReachable, "Network connectivity needed for this test.")
        XCTAssert(self.sut.entries.isEmpty)
        
        // given
        let promise = expectation(description: "Completion handler invoked")
        self.sut.local = false
        
        // when
        self.sut.loadTree {
            promise.fulfill()
        }
        wait(for: [promise], timeout: 3)
        
        // then
        XCTAssertFalse(self.sut.entries.isEmpty)
    }
}
