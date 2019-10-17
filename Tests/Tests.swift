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

		XCTAssert(checkRight(intState ?? -100, state))
	}

	func helper1Tests(_ stateToTest: TestState) {
		let state: TestState = stateToTest

		let intState = when(state) { state -> Int in

			let result = state == .finished => { finished } =>?
			{state == .working || state == .pausing => { active } =>?
				{state == .idle || state == .preparing || state == .ready => { notActive }}}
			return result ?? unknown
		}

		XCTAssert(checkRight(intState ?? -100, state))
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
		XCTAssert(checkRight(intState  ?? -100, state))


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

	func helperClassTest(_ stateToTest: TestState) {
		let state = When(stateToTest)
			.case(.idle)
			.case(.preparing)
			.case(.ready) {self.notActive}
			.case(.working)
			.case(.pausing) {self.active}
			.case(.finished) {self.finished}
			.default(unknown) ?? unknown
		XCTAssert(checkRight(state, stateToTest))
	}

	func helperClassBoolTest(_ stateToTest: TestState) {
		let state = When<TestState, Int>(stateToTest)
			.case({ $0 == .idle || $0 == .preparing || $0 == .ready}) { self.notActive }
			.case({ $0 == .working || $0 == .pausing}) { self.active }
			.case({ $0 == .finished }) {self.finished}
			.default(unknown)
		XCTAssert(checkRight(state!, stateToTest))
	}

	func helperClassMixedTest(_ stateToTest: TestState) {
		let state = When<TestState, Int>(stateToTest)
			.case({ $0 == .idle || $0 == .preparing || $0 == .ready}) { self.notActive }
			.case({ $0 == .working || $0 == .pausing}) { self.active }
			.case(.finished) {self.finished}
			.case(.wrong) {self.unknown}
			.default(unknown)
		XCTAssert(checkRight(state!, stateToTest))
	}

	func testWhenClass() {
		helperClassTest(.idle)
		helperClassTest(.preparing)
		helperClassTest(.ready)
		helperClassTest(.working)
		helperClassTest(.pausing)
		helperClassTest(.finished)
		helperClassTest(.wrong)

		helperClassBoolTest(.idle)
		helperClassBoolTest(.preparing)
		helperClassBoolTest(.ready)
		helperClassBoolTest(.working)
		helperClassBoolTest(.pausing)
		helperClassBoolTest(.finished)
		helperClassBoolTest(.wrong)

		helperClassMixedTest(.idle)
		helperClassMixedTest(.preparing)
		helperClassMixedTest(.ready)
		helperClassMixedTest(.working)
		helperClassMixedTest(.pausing)
		helperClassMixedTest(.finished)
		helperClassMixedTest(.wrong)
	}

	func testBooltoBoolOperatorImplication() {
		XCTAssert(true => true == true)
		XCTAssert(false => false == true)
		XCTAssert(false => true == false)
		XCTAssert(true => false == false)

		XCTAssert(true => true => true == true)
		XCTAssert(true => true => false == false)
		XCTAssert(false => false => false == false)
		XCTAssert(false => true => false == true)
	}
	
	func testExamplesFromReadme() {
		var number = 0
		let a = When(number)
			.case(0) {"Invalid number"}
			.case(1)
			.case(2) {"Number is too low"}
			.case(3) {"Number is correct"}
			.case(4) {"Numbe is almost correct"}
			.default("Number is too high")
		
		XCTAssert(a == "Invalid number")
		
		number = 10
		let b = When<Int, String>(number)
			.case(0) {"Invalid number"}
			.case(1)
			.case(2) {"Number is too low"}
			.case(3) {"Number is correct"}
			.case(4) {"Numbe is almost correct"}
			.default(nil)
		XCTAssert(b == nil)
		let b1 = When(number)
			.case(0) {"Invalid number"}
			.case(1)
			.case(2) {"Number is too low"}
			.case(3) {"Number is correct"}
			.case(4) {"Numbe is almost correct"}
			.default(nil) ?? "Number is too high"
		XCTAssert(b1 == "Number is too high")
		
		let c = when(number) {
			return $0 >= 10 ? "Big number" : "Small number"
		}
		XCTAssert(c == "Big number")
		let state: TestState = .wrong
		let result = state == .finished => { 0 } =>? {
			state == .working || state == .pausing => { 1 } =>? {
				state == .idle || state == .preparing || state == .ready => { 2 } =>! {
					3
				}
			}
		}

		XCTAssert(result == 3)
		var nonOptionalResult = 3
		nonOptionalResult =? state == .finished => { 0 } =>? {
			state == .working || state == .pausing => { 1 } =>? {
				state == .idle || state == .preparing || state == .ready => { 2 }
			}
		}

		XCTAssert(nonOptionalResult == 3)
	}
	
	func testWhenWithNoParam() {
		let z = 3
		let result = When()
			.case({ z == 1}) { 1 }
			.case({ Double(100.2) == Double(100.3)}) { 2 }
			.case({ z == 3}) { 3 }
			.case({"str" == "str"}) { -100 }
			.default(nil) ?? 0
		
		XCTAssert(z == result)
		
		let result1 = When()
			.case(3 > 5)
			.case({0 == 10}) {0}
			.case({15 > 7})
			.case({0 > 6})
			.case({100 < 3}) {1}
			.case({3 == 3}) {2}
			.case({true}) {3}
			.default(nil) ?? 4
		
		XCTAssert(1 == result1)
	}
	
	class A1 {
		var str: A2 = A2()
		class A2 {
			var str: A3 = A3()
			class A3 {
				var str: String = "A3"
			}
		}
	}

	class B1 {
		var str: B2 = B2()
		class B2 {
			var str: B3? = B3()
			class B3 {
				var str: String = "A3"
			}
		}
	}

	class C1 {
		var str: C2 = C2()
		class C2 {
			var str: C3!
			class C3 {
				var str: String = "A3"
			}

			init() {
				str = C3()
			}
		}
	}

	class D1 {
		var str: D2 = D2()
		class D2 {
			var str: D3? = nil
			class D3 {
				var str: String = "A3"
			}
		}
	}
	
	func testWith() {
		let a = A1()
		let b: B1 = B1()
		let c: C1 = C1()
		let d: D1 = D1()
		with(a.str.str) {
			XCTAssert($0.str == "A3")
		}

		with(b.str.str) {
			XCTAssert($0.str == "A3")
		}

		with(c.str.str) {
			XCTAssert($0.str == "A3")
		}

		with(d.str.str) { _ in
			XCTAssert(false)
		}
	}
	
	func testLet() {
		let a: A1? = A1()
		let str = a.let {
			$0.str.str.str
		}
		XCTAssert(str == "A3")
	}
	
	func testRunMethod() {
		let a: A1? = A1()
		a.run {
			let str = $0.str.str.str
			XCTAssert(str == "A3")
		}
	}
	
	func testApply() {
		let a: A1? = A1()
		_ = a?.str.str.str
		a.apply {
			$0.str.str.str = "New A3"
		}
		
		a.map {
			XCTAssert($0.str.str.str == "New A3")
		}
		
		a.apply {
			$0.str.str.str = "first iteration"
			}.apply {
				$0.str.str.str = "second iteration"
			}.apply {
				$0.str.str.str = "third iteration"
		}

		a.map {
			XCTAssert($0.str.str.str == "third iteration")
		}
	}
	
	func testTakeWhen() {
		var a: Int? = 2

		if let validA = a.takeWhen({$0 > 1}) {
			XCTAssert(validA == 2)
		} else {
			XCTAssert(false)
		}
		
		a = 1
		if let _ = a.takeWhen({$0 > 1}) {
			XCTAssert(false)
		} else {
			XCTAssert(a == 1)
		}

		a = nil
		if let _ = a.takeWhen({$0 > 1}) {
			XCTAssert(false)
		} else {
			XCTAssert(a == nil)
		}

		a = 100
		if let _ = a.takeWhen({$0 > 1}) {
			XCTAssert(a == 100)
		} else {
			XCTAssert(false)
		}
		
		if let validA = a.takeWhen({$0 > 1}).takeWhen({$0 == 100}) {
			XCTAssert(validA == 100)
		} else {
			XCTAssert(false)
		}
	}
	
	func testWhenNewSyntax() {
		let a = 5
		let b = When(a) {
			$0.case(0) { "Zero" }
			$0.case(1) { "One"  }
			$0.case(2) { "Two"  }
			$0.case(3) { "Three"}
			$0.case(4) { "Four" }
			$0.case(5) { "Five" }
			$0.case(6) { "Six"  }
			$0.case(7) { "Seven"}
			$0.case(8) { "Eight"}
			$0.case(9) { "Nine" }
			}.default(nil) ?? "Unknown"
		XCTAssert(b == "Five")
		
		let c = When(a) {
			$0.case({ $0 > 10 })
			$0.case({$0 == 10})
			$0.case(9)            { "Too much" }
			$0.case({$0 == -100})
			$0.case({$0 == -200})
			$0.case({$0 == -300}) {"Unreal"}
			$0.case(8)
			$0.case(7)
			$0.case(6)            { ">5"}
			$0.case(5)            { "5"}
			$0.case({$0 < 5})     {"Too low"}
			}.default(nil) ?? "Unknown"
		XCTAssert(c == "5")
		
		let d = When {
			$0.case(3 > 5)
			$0.case(6 > 20)
			$0.case(false) {"No way"}
			$0.case(true) {"true"}
			}.default(nil) ?? "Default"
		XCTAssert(d == "true")
		
		let d1 = When {
			$0.case(3 > 5)
				.case({$0 == false})
				.case(6 > 20)
				.case(false) {"No way"}
				.case(true) {"true"}
			}.default(nil) ?? "Default"
		XCTAssert(d1 == "true")
		
		let d2 = When {
			$0.case(3 > 5)
			$0.case({$0 == false})
			$0.case(6 > 20)
			$0.case(false) {"No way"}
			$0.case(true) {"true"}
			}.default(nil) ?? "Default"
		XCTAssert(d2 == "true")
	}
	
	func testNewSyntax2() {
		let a = 5
		let b = When(a) {
			$0.case(0) => "Zero"
			$0.case(1) => "One"
			$0.case(2) => "Two"
			$0.case(3) => "Three"
			$0.case(4) => "Four"
			$0.case(5) => "Five"
			$0.case(6) => "Six"
			$0.case(7) => "Seven"
			$0.case(8) => "Eight"
			$0.case(9) =>  "Nine"
			}.default(nil) ?? "Unknown"
		XCTAssert(b == "Five")
		
		let b1 = When(a) {
			$0.case(0) => "Zero"
			$0.case(1) => "One"
			$0.case(2) => "Two"
			$0.case(3) => "Three"
			$0.case(4)
			$0.case(5) { "Five" }
			$0.case(6) => "Six"
			$0.case(7) => "Seven"
			$0.case(8) => "Eight"
			$0.case(9) =>  "Nine"
			}.default(nil) ?? "Unknown"
		XCTAssert(b1 == "Five")
		
		let b2 = When(a) {
			$0.case(0) => "Zero"
			$0.case(1) => "One"
			$0.case(2)
				.case(3)
				.case(4)
			$0.case(5) => "More than one, less then 6"
			$0.case(6) => "Six"
			$0.case(7) => "Seven"
			$0.case(8) => "Eight"
			$0.case(9) =>  "Nine"
			}.default(nil) ?? "Unknown"
		XCTAssert(b2 == "More than one, less then 6")
		
		let d2 = When {
			$0.case(3 > 5)
				.case({$0 == false})
				.case(6 > 20)
				.case(false) { "No way" }
			$0.case(true) {"true"}
			}.default(nil) ?? "Default"
		XCTAssert(d2 == "true")
	}
	
	func test3dSyntax() {

		let d = When(.simple) {
			$0(3 > 5) => "1"
			$0(6 > 20) => "2"
			$0(false) => "3"
			$0(true) => "true"
			}.default(nil) ?? "Default"
		XCTAssert(d == "true")

		let a = 5
		let b = When(.simple, a) {
			$0(0) => "Zero"
			$0(1) => "One"
			$0(2) => "Two"
			$0(3) => "Three"
			$0(4) => "Four"
			$0(5) => "Five"
			$0(6) => "Six"
			$0(7) => "Seven"
			$0(8) => "Eight"
			$0(9) =>  "Nine"
			}.default(nil) ?? "Unknown"
		XCTAssert(b == "Five")
		
		let a1 = 2
		let b1 = When(.simple, a1) {
			$0(0) => "Zero"
			$0(1) => "One"
			$0(2) => .skip
			$0(3) => .skip
			$0(4) => .skip
			$0(5) => "Five"
			$0(6) => "Six"
			$0(7) => "Seven"
			$0(8) => "Eight"
			$0(9) =>  "Nine"
			}.default(nil) ?? "Unknown"
		XCTAssert(b1 == "Five")
		
		let n1 = 5
		let r1 = When(.simple, n1) {
			$0(0) => "Zero"
			$0(1) => "One"
			$0(2) => "Two"
			$0(3) => "Three"
			$0(4) => "Four"
			$0(5) => nil
			$0(6) => "Six"
			$0(7) => "Seven"
			$0(8) => "Eight"
			$0(9) =>  "Nine"
			}.default("dd")
		XCTAssert(r1 == nil)
		
		let n2 = 5
		let r2 = When(.simple, n2) {
			$0(0) => "Zero"
			$0(1) => "One"
			$0(2) => "Two"
			$0(3) => "Three"
			$0(4) => "Four"
			$0(5) => {
				return "Five"
				}()
			$0(6) => "Six"
			$0(7) => "Seven"
			$0(8) => "Eight"
			$0(9) =>  "Nine"
			}.default("dd")
		XCTAssert(r2 == "Five")
		
		let n3 = 5
		let r3 = When(.simple, n3) {
			$0(0) => "Zero"
			$0(1) => "One"
			$0(2) => "Two"
			$0(3) => "Three"
			$0(false) => "Four"
			$0({$0 == 5}) => {
				return "Five"
				}()
			$0(6) => "Six"
			$0(7) => "Seven"
			$0(8) => "Eight"
			$0(9) =>  "Nine"
			}.default("dd")
		XCTAssert(r3 == "Five")
		
		let n4 = 5
		let r4 = When(.simple, n4) {
			$0(0) => "Zero"
			$0(1) => "One"
			$0(2) => "Two"
			$0(3) => "Three"
			$0(false) => "Four"
			$0(true) => {
				return "Five"
				}()
			$0(6) => "Six"
			$0(7) => "Seven"
			$0(8) => "Eight"
			$0(9) =>  "Nine"
			}.default("dd")
		XCTAssert(r4 == "Five")
		
		let n5 = 5
		let r5 = When(.simple, n5) {
			$0(0) => "Zero"
			$0(1) => "One"
			$0(2) => "Two"
			$0(3) => "Three"
			$0({false}) => "Four"
			$0({true}) => {
				return "Five"
				}()
			$0(6) => "Six"
			$0(7) => "Seven"
			$0(8) => "Eight"
			$0(9) =>  "Nine"
			}.default("dd")
		XCTAssert(r5 == "Five")
	}
	
	func testComplex() {
		let testState = TestState.idle
		
		let stateInt = When(testState)
			.case(.idle)      { 0 }
			.case(.preparing) { nil }
			.case(.ready)     { 2 }
			.case(.working)   { 3 }
			.case(.pausing)   { 4 }
			.case(.finished)  { 5 }
			.case(.wrong) 	  { 6 }
			.default(nil) ?? 0
		
		XCTAssert(stateInt == 0)

		let stateInt1 = When<TestState, Int>(testState)
			.case({ $0 == .idle })      { 0 }
			.case({ $0 == .preparing }) { nil }
			.case({ $0 == .ready })     { 2 }
			.case({ $0 == .working })   { 3 }
			.case({ $0 == .pausing })   { 4 }
			.case({ $0 == .finished })  { 5 }
			.case({ $0 == .wrong })     { 6 }
			.default(nil) ?? 0
		
		XCTAssert(stateInt1 == 0)

		let stateInt2 = When(testState) {
			$0.case(.idle)      { 0 }
			$0.case(.preparing) { nil }
			$0.case(.ready)     { 2 }
			$0.case(.working)   { 3 }
			$0.case(.pausing)   { 4 }
			$0.case(.finished)  { 5 }
			$0.case(.wrong)     { 6 }
			}
			.default(nil) ?? 0
		
		XCTAssert(stateInt2 == 0)

		let stateInt3 = When(testState) {
			$0.case(.idle)      => { 0 }()
			$0.case(.preparing) => { nil }()
			$0.case(.ready)     => { 2 }()
			$0.case(.working)   => { 3 }()
			$0.case(.pausing)   => { 4 }()
			$0.case(.finished)  => { 5 }()
			$0.case(.wrong)     => { 6 }()
			}
			.default(nil) ?? 0
		
		XCTAssert(stateInt3 == 0)

		let stateInt4 = When(testState) {
			$0.case(.idle)      => 0
			$0.case(.preparing) => nil
			$0.case(.ready)     => 2
			$0.case(.working)   => 3
			$0.case(.pausing)   => 4
			$0.case(.finished)  => 5
			$0.case(.wrong)     => 6
			}
			.default(nil) ?? 0
		
		XCTAssert(stateInt4 == 0)

		let stateInt5 = When(testState) {
			$0.case({ $0 == .idle })      => 0
			$0.case({ $0 == .preparing }) => nil
			$0.case({ $0 == .ready })     => 2
			$0.case({ $0 == .working })   => 3
			$0.case({ $0 == .pausing })   => 4
			$0.case({ $0 == .finished })  => 5
			$0.case({ $0 == .wrong })     => 6
			}
			.default(nil) ?? 0
		
		XCTAssert(stateInt5 == 0)


		let stateInt6 = When(.simple, testState) {
			$0(TestState.idle)      => 0
			$0(TestState.preparing) => nil
			$0(TestState.ready)     => 2
			$0(TestState.working)   => 3
			$0(TestState.pausing)   => 4
			$0(TestState.finished)  => 5
			$0(TestState.wrong)     => 6
			}
			.default(nil) ?? 0

		XCTAssert(stateInt6 == 0)
		
		let stateInt7 = When(.simple, testState) {
			$0({ $0 == TestState.idle })      => 0
			$0({ $0 == TestState.preparing }) => nil
			$0({ $0 == TestState.ready })     => 2
			$0({ $0 == TestState.working })   => 3
			$0({ $0 == TestState.pausing })   => 4
			$0({ $0 == TestState.finished })  => 5
			$0({ $0 == TestState.wrong })     => 6
			}
			.default(nil) ?? 0

		XCTAssert(stateInt7 == 0)
	}
	
	func testSimpleAndClosure() {

		let testState = TestState.idle

		let stateInt = When(.simple, testState) {
			$0(TestState.idle)      => { 0 }
			$0(TestState.preparing) => { nil }
			$0(TestState.ready)     => { 2 }
			$0(TestState.working)   => { 3 }
			$0(TestState.pausing)   => { 4 }
			$0(TestState.finished)  => { 5 }
			$0(TestState.wrong)     => { 6 }
			}
			.default(nil) ?? 0

		XCTAssert(stateInt == 0)
		
		let stateInt1 = When(testState) {
			$0.case(TestState.idle)      => { 0 }
			$0.case(TestState.preparing) => { nil }
			$0.case(TestState.ready)     => { 2 }
			$0.case(TestState.working)   => { 3 }
			$0.case(TestState.pausing)   => { 4 }
			$0.case(TestState.finished)  => { 5 }
			$0.case(TestState.wrong)     => { 6 }
			}
			.default(nil) ?? 0

		XCTAssert(stateInt1 == 0)

		let stateInt2 = When(.simple) {
			$0({testState == TestState.idle})      => { 0 }
			$0({testState == TestState.preparing}) => { nil }
			$0({testState == TestState.ready})     => { 2 }
			$0({testState == TestState.working})   => { 3 }
			$0({testState == TestState.pausing})   => { 4 }
			$0({testState == TestState.finished})  => { 5 }
			$0({testState == TestState.wrong})     => { 6 }
			}
			.default(nil) ?? 0

		XCTAssert(stateInt2 == 0)
		
		let stateInt3 = When {
			$0.case({testState == TestState.idle})      => { 0 }
			$0.case({testState == TestState.preparing}) => { nil }
			$0.case({testState == TestState.ready})     => { 2 }
			$0.case({testState == TestState.working})   => { 3 }
			$0.case({testState == TestState.pausing})   => { 4 }
			$0.case({testState == TestState.finished})  => { 5 }
			$0.case({testState == TestState.wrong})     => { 6 }
			}
			.default(nil) ?? 0

		XCTAssert(stateInt3 == 0)
	}

	class SubClass {

	}

	class TestOpEqQu {
		var a: SubClass?

		func setA(_ newA: SubClass?) {
			a =? newA
		}
	}

	func testEqQuWithOptional() { //fix in 2.0.2
		var a: Int? = nil
		let b: Int? = 3
		a =? b
		XCTAssert(a == 3)
		a =? nil
		XCTAssert(a == 3)

		let tester = TestOpEqQu()
		XCTAssert(tester.a == nil)
		tester.a =? SubClass()
		XCTAssert(tester.a != nil)
		tester.a =? nil
		XCTAssert(tester.a != nil)
		tester.setA(nil)
		XCTAssert(tester.a != nil)  // here was a problem
	}

	func testNewDefaultWithBlock() {
		let a: Int = 5
		
		let b = When(a)
			.case(0) {"0"}
			.case(1) {"1"}
			.default {
				if a < 5 {
					return "less then 5"
				} else {
					return " >= 5"
				}
		}
		XCTAssert(b == " >= 5")
		
		let c =  When<Int, String>(a) {
			$0.case(0) => "0"
			$0.case(1) => "1"
			}
			.else {
				if a < 5 {
					return "less then 5"
				} else {
					return " >= 5"
				}
		}
		XCTAssert(c == " >= 5")
	}
}
