//
//  SwiftWhen.swift
//  SwiftWhen
//
//  Created by Sergey Makeev on 22/08/2019.
//  Copyright © 2019 SOME projects. All rights reserved.
//

open class When<Type, Result> {

	struct ConditionContainer {
		var param:   ((Type) -> Bool)?
		var noParam: (() -> Bool)?
		
		init(param: @escaping (Type) -> Bool) {
			self.param = param
		}
		
		init(noParam: @escaping () -> Bool) {
			self.noParam = noParam
		}
	}

	private var what: Type
	public init(_ what: Type) {
		self.what  = what
		cases      = [(()->Result?)?]()
		conditions = [ConditionContainer]()
	}

	private var cases: [(()->Result?)?]
	private var conditions: [ConditionContainer]
	
	public func `case`(_ condition: @escaping (Type) -> Bool,  handler: (() -> Result?)? = nil) -> When<Type, Result> {
		cases.append(handler)
		conditions.append(ConditionContainer(param:condition))
		return self
	}
	
	public func `case`(_ condition: @escaping () -> Bool,  handler: (() -> Result?)? = nil) -> When<Type, Result> {
		cases.append(handler)
		conditions.append(ConditionContainer(noParam:condition))
		return self
	}
	
	public func `default`(_ defaultValue: Result?) -> Result? {
		var currentCase: (()->Result?)? = nil
		for index in 0..<conditions.count {
			var result: Bool = false
			if let paramCondion = conditions[index].param {
				result = paramCondion(what)
			} else if let noParamCondition = conditions[index].noParam {
				result = noParamCondition()
			}
			if result {
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

public extension When where Type == Bool {
	convenience init() {
		self.init(true)
	}
}

public extension When where Type: Equatable {
	func `case`(_ condition: Type,  handler: (() -> Result?)? = nil) -> When<Type, Result> {
		cases.append(handler)
		conditions.append(ConditionContainer(param:{ what in
			return what == condition
		}))
		return self
	}
}

public func when<Type, ResultType> (_ source: Type, handler: (Type) -> ResultType) -> ResultType {
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


public func =? <Type>(lhs: inout Type, rhs: Type?) -> Void {
	lhs = rhs ?? lhs
}

public func => (lhs: Bool, rhs: Bool) -> Bool {
	let result = When<(Bool, Bool), Bool>((lhs, rhs))
		.case({$0.0 && $0.1})
		.case({!$0.0 && !$0.1}) {true}
		.default(false)
	
	return result ?? false
}

public func => <Type>(lhs: Bool, rhs: () -> Type) -> Type? {
	return lhs ? rhs() : nil
}

public func =>? <Type>(lhs: Type?, rhs: ()->Type?) -> Type? {
	if lhs == nil {
		return rhs()
	}
	return lhs
}

public func =>! <Type>(lhs: Type?, rhs: ()->Type) -> Type {
	return lhs ?? rhs()
}
