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
```case``` might ommit the block, in this case the first mantioned block will be called. This is a way of grouping several ```case``` statements.
If no block found the ```default``` value will be provided by ```When```.

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



