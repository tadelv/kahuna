//
//  KahunaTests.swift
//  KahunaTests
//
//  Created by Vid Tadel on 04/12/14.
//  Copyright (c) 2014 Vid Tadel. All rights reserved.
//

import UIKit
import XCTest
import RealmSwift

class KahunaTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

	func testNewMemberWorks() {
		let member = Member(name: "Frieda")
		let group = Group(name: "Assistants")


		let realm = try! Realm()
		do {
			try realm.write {
				group.members.append(member)
			}
		} catch let error {
			XCTAssert(false, "\(error)")
		}

	}
    
}
