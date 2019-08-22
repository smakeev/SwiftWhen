//
//  SwiftWhen.swift
//  SwiftWhen
//
//  Created by Sergey Makeev on 22/08/2019.
//  Copyright © 2019 SOME projects. All rights reserved.
//

func when<Type, ResultType> (_ source: Type, handler: (Type) -> ResultType) -> ResultType {
	return handler(source)
}

precedencegroup LogicalFollowng {
	lowerThan: LogicalDisjunctionPrecedence
	higherThan: OptionalLogicalFollowng
	associativity: none
	assignment: false
}

precedencegroup OptionalLogicalFollowng {
	lowerThan: LogicalDisjunctionPrecedence
	higherThan: DefaultPrecedence
	associativity: left
	assignment: false
}

infix operator =? : AssignmentPrecedence

infix operator => : LogicalFollowng

infix operator =>?: OptionalLogicalFollowng
infix operator =>!: OptionalLogicalFollowng


func =? <Type>(lhs: inout Type, rhs: Type?) -> Void {
	lhs = rhs ?? lhs
}

func =><Type>(lhs: Bool, rhs: () -> Type) -> Type? {
	return lhs ? rhs() : nil
}

func =>? <Type>(lhs: Type?, rhs: ()->Type?) -> Type? {
	if lhs == nil {
		return rhs()
	}
	return lhs
}

func =>! <Type>(lhs: Type?, rhs: ()->Type) -> Type {
	return lhs ?? rhs()
}
