# SwiftWhen

```When``` is similar to ```switch``` but could be used as an expression. 

```swift
let a = When(number)
        .case(0) {"Invalid number"}
        .case(1)
        .case(2) {"Number is too low"}
        .case(3) {"Number is correct"}
        .case(4) {"Numbe is almost correct"}
        .default("Number is too high")
```
```When``` must be finished with ```default```. This is due to the safe approach. In fact ```when``` returns an ```optional```, so you can return nil in ```case``` or in default.
After the first ```case``` matches ```When``` executes it's block (will be called an```action blockon``` -  on the right to the ```case``` statement).
```case``` might ommit the block, in this case the first ```action block``` after this ```case``` will be called. This is a way of grouping several ```case``` statements.
If no ```action block``` found the ```default``` value will be provided by ```When```.

```Action block``` is a block with any code returning value of the same type as is provided in ```default```.
```Action block``` and\or ```default``` could returns ```nil```
```When``` could be used with types it is using.

```swift
let b = When<Int, String>(number)
	.case(0) {"Invalid number"}
	.case(1)
	.case(2) {"Number is too low"}
	.case(3) {"Number is correct"}
	.case(4) {"Numbe is almost correct"}
	.default("Number is too high")
```
As always ```When``` returns an ```optional```, so the resulttype is ```String?```
If you whant ```When``` to return ```String``` instead do the following as one of possible solutions:
```swift
let b1 = When(number)
	.case(0) {"Invalid number"}
	.case(1)
	.case(2) {"Number is too low"}
	.case(3) {"Number is correct"}
	.case(4) {"Numbe is almost correct"}
	.default(nil) ?? "Number is too high"
```

```case``` could use not only a value but a condition block (``` (Type) -> Bool  ``` )
```swift
let state = When<State, Int>(stateToTest)
	.case({ $0 == .idle || $0 == .preparing || $0 == .ready}) { 0 }
	.case({ $0 == .working || $0 == .pausing}) { 1 }
	.case({ $0 == .finished }) {2}
	.default(3)
```

Note that  ```case``` with value could be used only for ```Equtable``` types while ```case``` with condition block could be used for any type.

You can combine ```case``` types.
```swift
let b2 = When(number)
	.case({$0 < 0}) {"Number should be > 0"}
	.case(0) {"Invalid number"}
	.case(1)
	.case(2) {"Number is too low"}
	.case(3) {"Number is correct"}
	.case(4) {"Numbe is almost correct"}
	.default(nil) ?? "Number is too high"
```

Sometimes you don't have many cases but the only one rule to make a result on one type from a value of another one.
In this case you may use ```when``` - a global function to have it as a statement and be used inline.
```swift
let c = when(number) {
	//Here could be any culculations 
	return $0 >= 10 ? "Big number" : "Small number"
}
```
# More functions in 2.0.0
```swift
 func with<Type>(_ source: Type, handler: (Type) -> Void)
 ```
 It could be used to
 
```Optinal``` has an extension with several new methods
```swift
func takeWhen(_ handler: (Wrapped) -> Bool) -> Wrapped?
func `let`<Result>(_ handler: (Wrapped) -> Result?) -> Result?
func apply(_ handler: (Wrapped) -> Void) -> Wrapped?
func run(_ handler: (Wrapped) -> Void)
```

In project's tests could be found examples:
```swift
	class A1 {
		var str: A2 = A2()
		class A2 {
			var str: A3 = A3()
			class A3 {
				var str: String = "A3"
			}
		}
	}
	
	func testWith() {
		let a = A1()
		with(a.str.str) {
			XCTAssert($0.str == "A3")
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
```

```When``` could be used without parameter

```swift
	let value = 3
	let result = When()
	    .case({ value == 1}) { 1 }
	    .case(100.2 == 100.3) { 2 }
	    .case({ value >= 3}) { 3 }
	    .case("str" == "str") { -100 }
	    .default(nil) ?? 0
```
Also see what's new in 2.0.0 to see how to use ```When``` without parameter in new 2.0.0 syntax.

# Operators:

```SwiftWhen``` provides shorter way to achive expression of casting one value to another type value using some operators.
This might be shorter but harder to read. 

```swift
let result = state == .finished => { 0 } =>? {
	state == .working || state == .pausing => { 1 } =>? {
		 state == .idle || state == .preparing || state == .ready => { 2 } =>! {
			3
		 }
	}
}
```
Comprehensive description of operators could be found in project wiki page https://github.com/smakeev/SwiftWhen/wiki. 
But to understand this you may think that:
```=>``` is an if statement. (Left part is a condition right is a then branch. 
```=>?``` works like ```else if``` (and it should contain ```=>``` in it's right part)
```=>!``` works like ```else``` and plays a role of a ```default``` statement.

The reault of this operator's chain will be an optional ```Int```. If you whant to have ```Some``` Int you will find that it is imposible just to add ?? to the end of the chain to unwrap it. The possible solution could be:
```swift
var nonOptionalResult = 3
nonOptionalResult =? state == .finished => { 0 } =>? {
	state == .working || state == .pausing => { 1 } =>? {
		state == .idle || state == .preparing || state == .ready => { 2 }
	}
}
```

Here ```=?``` is an operator which assign right value to the left local only if right value is not nil, otherwise it does not change it. The default result here was assigned to the ```nonOptionalResult``` at the initialization process.

# How to use:

```SwiftWhen``` source contains only one source file ```SwiftWhen.swift```, so the easiest way is to copy it inside your project as is.

Another way is to add ```SwiftWhen``` as a subproject.

In this case you will need to add importing in files where you want to use it.
```swift
import SwiftWhen
```

You may use cocoapods https://cocoapods.org/pods/SomeWhen
```
pod "SomeWhen"
```
Note, you will need add 
```swift 
import SomeWhen
```

# What's new in 2.0.0

New 2 variants of syntax available:
Symple: 
```swift
		let source = 5
		let result = When(.simple, source) {
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
		}.default("default")
```
By adding ```.simple``` you could just provide cases in ```$0``` statement and provide according value after ```=>```
In case of several cases have the same result you may just ommit ```=>``` for cases besides the last one.
But in this case the compiler will show a warning.
To remove the warning you could use ```.skip```
## Note: ```.simple``` case is only applicable when you provide a simple result.
In case of you need to call a function this is a bad idea due to all of them will be called.

```swift
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
```

The second variant of new syntax does not contain ```simple``` key word
```swift
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
```
In this variant you may also use ```=>``` to provide simple result. Also you could provide closures directly. As in case(5) here.

Also both variants of syntax supports ```When``` without an argument
```swift
		let result = When {
			$0.case(3 > 5)
			.case({$0 == false})
			.case(6 > 20)
			.case(false) { "No way" }
			$0.case(true) {"true"}
		}.default(nil) ?? "Default"
```
```swift
		let result = When(.simple) {
			$0(3 > 5) => "1"
			$0(6 > 20) => "2"
			$0(false) => "3"
			$0(true) => "true"
		}.default(nil) ?? "Default"
```

Old syntax also supported. And it could be combined with new.

### in 2.0.1 you can also use closure after =>. Closure will be called only in case of ```case``` is correct.
Here are examples:
```swift
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

```
### in 2.0.2 you can use closure in default. Closure will be executed only if no cases worked.
### Also now you can use `.else` instead of `.default`

```swift
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
```


