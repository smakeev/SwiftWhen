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

