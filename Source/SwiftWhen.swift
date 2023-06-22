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

    static func buildIf(_ value: [WhenItem<R>]?) -> [WhenItem<R>] {
        value ?? []
    }

    static func buildEither(first components: [WhenItem<R>]) -> [WhenItem<R>] {
        components
    }

    static func buildEither(second components: [WhenItem<R>]) -> [WhenItem<R>] {
        components
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
        if let caseItems = item.valueToCompare as? Array<Any> {
            for caseItem in caseItems {
                if let boolValue = caseItem as? Bool, boolValue == true {
                    return item.result()
                }

                if let value = caseItem as? T, value == conditionVariable {
                    return item.result()
                }

                // range
                if let value = caseItem as? Range<T>,
                    value.contains(conditionVariable) {
                    return item.result()
                }
                //closed range
                if let value = caseItem as? ClosedRange<T>,
                    value.contains(conditionVariable) {
                    return item.result()
                }
                // PartialRangeFrom
                 if let value = caseItem as? PartialRangeFrom<T>,
                    conditionVariable >= value.lowerBound {
                    return item.result()
                }
                //PartialRangeUpTo
                if let value = caseItem as? PartialRangeUpTo<T>,
                    conditionVariable < value.upperBound {
                    return item.result()
                }
                //PartialRangeUpTo
                if let value = caseItem as? PartialRangeThrough<T>,
                    conditionVariable <= value.upperBound {
                    return item.result()
                }
            }
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

@discardableResult func when<T: Equatable, R>(_ conditionVariable: T, @SwiftWhen<R> items: () -> [WhenItem<R>]) -> R? {
    for item in items() {
        if item.condition == true {
            return item.result()
        }
        if let caseItems = item.valueToCompare as? Array<Any> {
           for arrayItem in caseItems {
                if let boolValue = arrayItem as? Bool, boolValue == true {
                    return item.result()
                }
                 if let value = arrayItem as? T {
                    switch conditionVariable {
                    case value:
                        return item.result()
                    default:
                    continue
                    }
                }
           }
        }
        if let value = item.valueToCompare as? T {

            switch conditionVariable {
            case value:
                return item.result()
            default:
                continue
            }
        }
    }
    return nil
}

@discardableResult func when<T, R>(_ conditionVariable: T, rule: (T, T) -> Bool, @SwiftWhen<R> items: () -> [WhenItem<R>]) -> R? {
    for item in items() {
        if item.condition == true {
            return item.result()
        }
         if let caseItems = item.valueToCompare as? Array<Any> {
            for arrayItem in caseItems {
                if let boolValue = arrayItem as? Bool, boolValue == true {
                    return item.result()
                }
                if let tValue = arrayItem as? T {
                    if rule(conditionVariable, tValue) {
                        return item.result()
                    }
                }
            }
         }
         if let value = item.valueToCompare as? T {
            if rule(conditionVariable, value) {
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
        if let caseItems = item.valueToCompare as? Array<Any> {
            for arrayItem in caseItems {
                if let boolValue = arrayItem as? Bool, boolValue == true {
                    return item.result()
                }
            }
        }
    }
    return nil
}

func checkSameCaseRule<T>() -> (T, T) -> Bool {
    return { (value1, value2) -> Bool in
        let mirror1 = Mirror(reflecting: value1)
        let mirror2 = Mirror(reflecting: value2)
        
        guard let case1 = mirror1.children.first?.label, let case2 = mirror2.children.first?.label else {
            return false
        }
        return case1 == case2
    }
}

func checkSameCaseAndValuesRule<T>() -> (T, T) -> Bool {
    return { (value1, value2) -> Bool in
        let mirror1 = Mirror(reflecting: value1)
        let mirror2 = Mirror(reflecting: value2)

        guard let case1 = mirror1.children.first?.label,
              let case2 = mirror2.children.first?.label,
              case1 == case2
        else {
            return false
        }

        guard let associatedValues1 = mirror1.children.first?.value,
              let associatedValues2 = mirror2.children.first?.value else { return false }
        let array1 = Mirror(reflecting: associatedValues1).children.map { $0.value }
        let array2 = Mirror(reflecting: associatedValues2).children.map { $0.value }

        if array1.count != array2.count {
            return false
        }

        for (el1, el2) in zip(array1, array2) {
            if String(describing: el1) != String(describing: el2) {
                return false
            }
        }

        return true
    }
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

// cases joint

let result51 = when(a) {
    [
        11,
        10,
        12,
        15
    ] => "<= 15"
    16 => "> 15"
    when_else => "unknown"
}

print(result51 ?? "nil")


let result52 = when(a) {
    [
      1..<20,
      1...20,
      5...,
      ..<25,
      ...15
    ] => "In One of ranges"
    15 => "15"
    10 => "ten"
    0 => "thero"
    when_else => "unknown"
}

print(result52 ?? "nil")

/////////////////
enum SomeEnum {
    case first
    case second
}

let enumV1 = SomeEnum.second

let resultEnumTest = when(enumV1) {
    SomeEnum.first => "first"
    SomeEnum.second => "second"
    when_else => "unknown"
}

print(resultEnumTest ?? "nil")

// associated type
enum SomeEnumWithString: String {
    case first = "first_str"
    case second = "second_str"
}

let enumV2 = SomeEnumWithString.second

let resultEnumTest1 = when(enumV2) {
    [
        SomeEnumWithString.first,
        SomeEnumWithString.second
    ] => enumV2.rawValue
    when_else => "unknown"
}

print(resultEnumTest1 ?? "nil")

// associated values

enum SomeEnumWithValues {
    case first(name: String, value: Int)
    case second(name: String, value: Double)
}

let enumV3 = SomeEnumWithValues.second(name: "second_value", value: 3.1415)

let resultEnumTest2 = when(enumV3, rule: { value1, value2 in
    switch (value1, value2) {
    case (.first, .first), (.second, .second):
        return true
    default:
        return false
    }
}) {
    SomeEnumWithValues.first(name: "name", value: 123) => "FIRST"
    SomeEnumWithValues.second(name: "name", value: 123) => "SECOND"
    when_else => "unknown"
}

print(resultEnumTest2 ?? "nil")

let resultEnumTest3 = when(enumV3, rule: checkSameCaseRule()) {
    SomeEnumWithValues.first(name: "name", value: 123) => "FIRST"
    SomeEnumWithValues.second(name: "name", value: 123) => "SECOND"
    when_else => "unknown"
}

print(resultEnumTest3 ?? "nil")

let resultEnumTest4 = when(enumV3, rule: checkSameCaseAndValuesRule()) {
    SomeEnumWithValues.second(name: "name", value: 123) => "wrong"
    SomeEnumWithValues.second(name: "second_value", value: 3.1415) => "SECOND"
    when_else => "unknown"
}

print(resultEnumTest4 ?? "nil")

// check ifs


var several = true
let result60 = when(a) {
    if several {
        [
            1..<20,
            1...20,
            5...,
            ..<25,
            ...15
        ] => "In One of ranges"
    }
    15 => "15"
    10 => "ten"
    0 => "thero"
    when_else => "unknown"
}

several = false
let result61 = when(a) {
    if several {
        [
            1..<20,
            1...20,
            5...,
            ..<25,
            ...15
        ] => "In One of ranges"
    }
    15 => "15"
    10 => "ten"
    0 => "thero"
    when_else => "unknown"
}

let result62 = when(a) {
    if several {
        [
            1..<20,
            1...20,
            5...,
            ..<25,
            ...15
        ] => "In One of ranges"
    } else {
        15 => "15"
    }
    10 => "ten"
    0 => "thero"
    when_else => "unknown"
}

several = true

let result63 = when(a) {
    if several {
        [
            1..<20,
            1...20,
            5...,
            ..<25,
            ...15
        ] => "In One of ranges"
    } else {
        15 => "15"
    }
    10 => "ten"
    0 => "thero"
    when_else => "unknown"
}


print(result60 ?? "nil")
print(result61 ?? "nil")
print(result62 ?? "nil")
print(result63 ?? "nil")
