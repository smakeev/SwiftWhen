//
//  Tests.swift
//  Tests
//
//  Created by Sergey Makeev on 22/08/2019.
//  Copyright © 2019 SOME projects. All rights reserved.
//

import XCTest

class Tests: XCTestCase {
	
	override func setUp() {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	enum TestState {
		case idle
		case preparing
		case ready
		case working
		case pausing
		case finished
		case wrong //be not active but only by default
	}
	
	let unknown = 0
	let notActive = 1
	let active = 2
	let finished = 3
	
	func checkRight(_ intState: Int, _ state: TestState) -> Bool {
		switch state {
		case .idle,
			.preparing,
			.ready: return intState == notActive
		case .working,
			.pausing: return intState == active
		case .finished: return intState == finished
		default: return intState == unknown
		}
	}
	
	func helperTests(_ stateToTest: TestState) {
		let state: TestState = stateToTest

		let intState = when(state) { state -> Int in

			var result = unknown

			result =? state == .finished => { finished } =>?
						{state == .working || state == .pausing => { active } =>?
						{state == .idle || state == .preparing || state == .ready => { notActive }}}

			return result

		}
		
		XCTAssert(checkRight(intState, state))
	}
	
	func helper1Tests(_ stateToTest: TestState) {
		let state: TestState = stateToTest

		let intState = when(state) { state -> Int in

			let result = state == .finished => { finished } =>?
					{state == .working || state == .pausing => { active } =>?
					{state == .idle || state == .preparing || state == .ready => { notActive }}}
			return result ?? unknown
		}

		XCTAssert(checkRight(intState, state))
	}

	func helper2Tests(_ stateToTest: TestState) {
		let state: TestState = stateToTest
		let intState = when(state) { state -> Int in
			let result = state == .finished => { finished } =>! {
				state == .working || state == .pausing => { active } =>! {
					state == .idle || state == .preparing || state == .ready => { notActive } =>! {
						unknown
					}
				}
			}
			return result
		}
		XCTAssert(checkRight(intState, state))

		
	}
	
	func testChaining() {
		var left: Int? = 1
		var right: Int? = 2

		var right1: Int? = 3
		let right2: Int? = 4

		let result = left =>? { right} =>? { right1 } =>? { right2 }
		XCTAssert(result == 1)
		let result1 = left =>! { right! } =>! { right1! } =>! { right2! }
		XCTAssert(result1 == 1)
		left = nil
		let result2 = left =>? { right } =>? { right1 } =>? { right2 }
		XCTAssert(result2 == 2)
		right = nil
		let result3 = left =>? { right } =>! { right1! } =>! { right2! }
		XCTAssert(result3 == 3)
		right1 = nil
		let result4 = left =>? { right } =>? { right1 } =>! { right2! }
		XCTAssert(result4 == 4)
	}
	
	func testWhen() {
		helperTests(.idle)
		helperTests(.preparing)
		helperTests(.ready)
		helperTests(.working)
		helperTests(.pausing)
		helperTests(.finished)
		helperTests(.wrong)
		
		helper1Tests(.idle)
		helper1Tests(.preparing)
		helper1Tests(.ready)
		helper1Tests(.working)
		helper1Tests(.pausing)
		helper1Tests(.finished)
		helper1Tests(.wrong)
		
		helper2Tests(.idle)
		helper2Tests(.preparing)
		helper2Tests(.ready)
		helper2Tests(.working)
		helper2Tests(.pausing)
		helper2Tests(.finished)
		helper2Tests(.wrong)
	}
}
