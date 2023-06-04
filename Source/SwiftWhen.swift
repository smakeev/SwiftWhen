//
//  SwiftWhen.swift
//  SwiftWhen
//
//  Created by Sergey Makeev on 22/08/2019.
//  Copyright © 2019 SOME projects. All rights reserved.
//

let when_else = WhenElse()

class WhenElse {}

precedencegroup LogicalFollowng {
	lowerThan: LogicalDisjunctionPrecedence
	higherThan: OptionalLogicalFollowng
	associativity: left
	assignment: false
}

precedencegroup OptionalLogicalFollowng {
	lowerThan: LogicalDisjunctionPrecedence
	higherThan: DefaultPrecedence
	associativity: left
	assignment: false
}

infix operator => : LogicalFollowng

func => <T, R>(lhs: T, rhs: @escaping () -> R?) -> WhenItem<R> {
    let leftValue: Any = {
        if let closure = lhs as? () -> Bool {
            return closure()
        }
        return lhs
    }()

    if let value = leftValue as? Bool {
        return WhenItem<R>(condition: value, result: rhs)
    }

    if leftValue is WhenElse {
        return WhenItem<R>(condition: true, result: rhs)
    }
    return WhenItem<R>(valueToCompare: leftValue, result: rhs)
}

func => <R>(lhs: Any, rhs: @escaping @autoclosure () -> R?) -> WhenItem<R> {
    lhs => rhs
}

public struct WhenItem<R> {
    let valueToCompare: Any?
    let condition: Bool
    let result: () -> R?

    init(condition: Bool, result: @escaping () -> R?) {
        self.valueToCompare = nil
        self.condition = condition
        self.result = result
    }

    init(valueToCompare: Any,  result: @escaping () -> R?) {
        self.condition = false
        self.valueToCompare = valueToCompare
        self.result = result
    }
}

@resultBuilder
struct SwiftWhen<R> {
    static func buildBlock(_ components: [WhenItem<R>]...) -> [WhenItem<R>] {
        components.flatMap {$0}
    }

    static func buildExpression(_ expression: WhenItem<R>) -> [WhenItem<R>] {
        [expression]
    }
}

@discardableResult func when<T: Comparable, R>(_ conditionVariable: T, @SwiftWhen<R> items: () -> [WhenItem<R>]) -> R? {
    for item in items() {
        if item.condition == true {
            return item.result()
        }
        if let itemValue = item.valueToCompare as? T,
           itemValue == conditionVariable {
            return item.result()
        }
        // check for range
        if let range = item.valueToCompare as? Range<T> {
            if range.contains(conditionVariable) {
                return item.result()
            }
        }
        // check for closed range
        if let range = item.valueToCompare as? ClosedRange<T> {
            if range.contains(conditionVariable) {
                return item.result()
            }
        }
        // check for PartialRangeFrom
        if let range = item.valueToCompare as? PartialRangeFrom<T> {
            if conditionVariable >= range.lowerBound {
                return item.result()
            }
        }
        // chekc for PartialRangeUpTo
        if let range = item.valueToCompare as? PartialRangeUpTo<T> {
            if conditionVariable < range.upperBound {
                return item.result()
            }
        }
        // chack PartialRangeThrough
        if let range = item.valueToCompare as? PartialRangeThrough<T> {
            if conditionVariable <= range.upperBound {
                return item.result()
            }
        }
    }
    return nil
}

@discardableResult func when<R>(@SwiftWhen<R> items: () -> [WhenItem<R>]) -> R? {
    for item in items() {
        if item.condition == true {
            return item.result()
        }
    }
    return nil
}

let a = 15
print("SSS")
when {
    a == 10 => {print("ten")}
    a == 0 => {print("thero")}
    a == 15 => {print("15")}
    when_else => {print("unknown")}
}
print("SSS1")

var str: String = ""
let result = when {
    a == 15 => {"15"}
    a == 10 => {"ten"}
    a == 0 => {"thero"}
    when_else => {"unknown"}
}

str = result! // To check that result is not Any.
print(result ?? "nil")


print("SSS2")

let result1: String? = when {
    a == 15 => {"15"}
    a == 10 => {"ten"}
    a == 0 => {"thero"}
    when_else => {"unknown"}
}

print(result1 ?? "nil")
print("SSS3")
let result2 = when(a) {
    15 => {"15"}
    10 => {"ten"}
    0 => {"thero"}
    when_else => {"unknown"}
}

print(result2 ?? "nil")
print("SSS4")
let result3: String? = when(a) {
    15 => {"15"}
    10 => {"ten"}
    0 => {"thero"}
    when_else => {"unknown"}
}
print(result3 ?? "nil")


print("==========")

print("SSS1")

var str1: String = ""
let result11 = when {
    a == 15 => "15"
    a == 10 => "ten"
    a == 0 => "thero"
    when_else => "unknown"
}

str1 = result11! // To check that result is not Any.
print(result11 ?? "nil")


print("SSS2")

let result21: String? = when {
    a == 15 => "15"
    a == 10 => "ten"
    a == 0 => "thero"
    when_else => "unknown"
}

print(result21 ?? "nil")
print("SSS3")
let result22 = when(a) {
    15 => "15"
    10 => "ten"
    0 => "thero"
    when_else => "unknown"
}

print(result22 ?? "nil")
print("SSS4")
let result23: String? = when(a) {
    15 => "15"
    10 => "ten"
    0 => "thero"
    when_else => "unknown"
}
print(result23 ?? "nil")

print("=========")
print("MIXED")
let result31: String? = when(a) {
    15 => "15"
    10 => {"ten"}
    true => "true"
    true => {"true in closure"}
    0 => "thero"
    when_else => "unknown"
}

print(result31 ?? "nil")

// ranged


let result41 = when(a) {
    //1..<20 => "In Range"
    //1...20 => "In Closed Range"
    //5... => "In ParticialRangeFrom"
    //..<25 => "In PartialRangeUpTo"
    ...15 => "In PartialRangeThrough"
    15 => "15"
    10 => "ten"
    0 => "thero"
    when_else => "unknown"
}

print(result41 ?? "nil")
