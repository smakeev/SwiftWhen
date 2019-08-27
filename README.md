# SwiftWhen

```When``` is similar to ```switch``` but could be used as an expression. 

```swift
let a = When(number)
        .case(0) {"Invalid number"}
        .case(1)
        .case(2) {Number is too low}
        .case(3) {Number is correct}
        .case(4) {Numbe is almost correct}
        .default("Number is too high")
```
```When``` must be finished with ```default```. This is due to the safe approach. In fact ```when``` returns an ```optional```, so you can return nil in ```case``` or in default.
After the first ```case``` matches ```When``` executes it's block (on the right of ```case``` statement).
```case``` might ommit the block, in this case the first mantioned block will be called. This is a way of grouping several ```case``` statements.
If no block found the ```default``` value will be provided by ```When```.
