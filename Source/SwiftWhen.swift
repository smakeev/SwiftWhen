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

func => <T, R>(lhs: WhenElse, rhs:@escaping () -> R?) -> WhenItem<T, R> {
    WhenItem<T, R>(condition: true, result: rhs)
}

func => <T, R>(lhs: T, rhs: @escaping () -> R?) -> WhenItem<T, R> {
    if let value = lhs as? Bool {
        return WhenItem<T, R>(condition: value, result: rhs)
    }
    return WhenItem<T, R>(valueToCompare: lhs, result: rhs)
}

func => <T, R>(lhs: T, rhs: R?) -> WhenItem<T, R> {
    lhs => {rhs}
}

public struct WhenItem<T, R> {
    let valueToCompare: T?
    let condition: Bool
    let result: () -> R?

    init(condition: Bool, result: @escaping () -> R?) {
        self.valueToCompare = nil
        self.condition = condition
        self.result = result
    }

    init(valueToCompare: T,  result: @escaping () -> R?) {
        self.condition = false
        self.valueToCompare = valueToCompare
        self.result = result
    }
}

@resultBuilder
struct SwiftWhen<T, R> {
    static func buildBlock(_ components: [WhenItem<T, R>]...) -> [WhenItem<T, R>] {
        components.flatMap {$0}
    }

    static func buildExpression(_ expression: WhenItem<T, R>) -> [WhenItem<T, R>] {
        [expression]
    }
}

@discardableResult func when<T: Equatable, R>(_ conditionVariable: T, @SwiftWhen<T, R> items: () -> [WhenItem<T, R>]) -> R? {
    for item in items() {
        if item.condition == true ||
            item.valueToCompare == conditionVariable {
            return item.result()
        }
    }
    return nil
}

@discardableResult func when<T, R>(@SwiftWhen<T, R> items: () -> [WhenItem<T, R>]) -> R? {
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
    a == 15 => {print("15")}
    a == 10 => {print("ten")}
    a == 0 => {print("thero")}
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
   // when_else => "unknown"
}

str1 = result11! // To check that result is not Any.
print(result11 ?? "nil")


print("SSS2")

let result21: String? = when {
    a == 15 => "15"
    a == 10 => "ten"
    a == 0 => "thero"
   // when_else => "unknown"
}

print(result21 ?? "nil")
print("SSS3")
let result22 = when(a) {
    15 => "15"
    10 => "ten"
    0 => "thero"
  //  when_else => "unknown"
}

print(result22 ?? "nil")
print("SSS4")
let result23: String? = when(a) {
    15 => "15"
    10 => "ten"
    0 => "thero"
  //  when_else => "unknown"
}
print(result23 ?? "nil")
