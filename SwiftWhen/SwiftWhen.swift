//
//  SwiftWhen.swift
//  SwiftWhen
//
//  Created by Sergey Makeev on 22/08/2019.
//  Copyright © 2019 SOME projects. All rights reserved.
//

class When<Type, Result> {
	
	private var what: Type
	init(_ what: Type) {
		self.what  = what
		cases      = [(()->Result?)?]()
		conditions = [(Type) -> Bool]()
	}
	
	private var cases: [(()->Result?)?]
	private var conditions: [(Type) -> Bool]
	
	func `case`(_ condition: @escaping (Type) -> Bool,  handler: (() -> Result?)? = nil) -> When<Type, Result> {
		cases.append(handler)
		conditions.append(condition)
		return self
	}
	
	func `default`(_ defaultValue: Result?) -> Result? {
		var currentCase: (()->Result?)? = nil
		for index in 0..<conditions.count {
			if conditions[index](what) {
				var currentIndex = index
				while currentIndex < conditions.count {
					currentCase = cases[currentIndex]
					if currentCase != nil {
						break
					}
					currentIndex += 1
				}
				
				break
			}
		}
		if let validCase = currentCase {
			return validCase()
		}
		return defaultValue
	}
}

extension When where Type: Equatable {
	func `case`(_ condition: Type,  handler: (() -> Result?)? = nil) -> When<Type, Result> {
		cases.append(handler)
		conditions.append({ what in
			return what == condition
		})
		return self
	}
}

func when<Type, ResultType> (_ source: Type, handler: (Type) -> ResultType) -> ResultType {
	return handler(source)
}

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

infix operator =? : AssignmentPrecedence

infix operator => : LogicalFollowng

infix operator =>?: OptionalLogicalFollowng
infix operator =>!: OptionalLogicalFollowng


func =? <Type>(lhs: inout Type, rhs: Type?) -> Void {
	lhs = rhs ?? lhs
}

func => (lhs: Bool, rhs: Bool) -> Bool {
	let result = When<(Bool, Bool), Bool>((lhs, rhs))
		.case({$0.0 && $0.1})
		.case({!$0.0 && !$0.1}) {true}
		.default(false)
	
	return result ?? false
}

func => <Type>(lhs: Bool, rhs: () -> Type) -> Type? {
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
