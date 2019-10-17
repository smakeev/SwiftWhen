//
//  SwiftWhen.swift
//  SwiftWhen
//
//  Created by Sergey Makeev on 22/08/2019.
//  Copyright © 2019 SOME projects. All rights reserved.
//

public enum WhenOptions{
	case simple
}

public enum WhenCaseOptions {
	case skip
}

open class When<Type, Result> {

	public class Case {
		var owner: When
		init(owner: When) {
			self.owner = owner
		}

		@discardableResult public func `case`(_ condition: @escaping (Type) -> Bool,  handler: (() -> Result?)? = nil) -> Case {
			owner.case(condition, handler: handler)
			return self
		}
		@discardableResult public func `case`(_ condition: @escaping () -> Bool,  handler: (() -> Result?)? = nil) -> Case {
			owner.case(condition, handler: handler)
			return self
		}
		
		fileprivate func add(_ result: Result?) {
			owner.cases.remove(at: owner.cases.count - 1)
			owner.cases.append({result})
		}
		
		fileprivate func addClosure(_ closure: @escaping () -> Result?) {
			owner.cases.remove(at: owner.cases.count - 1)
			owner.cases.append(closure)
		}
	}

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
	
	public convenience init(_ what: Type, caseProvider: (Case) -> Void) {
		self.init(what)
		let provider = Case(owner: self)
		caseProvider(provider)
	}

	public init(_ what: Type) {
		self.what  = what
		cases      = [(()->Result?)?]()
		conditions = [ConditionContainer]()
	}
	
	private var cases: [(()->Result?)?]
	private var conditions: [ConditionContainer]
	
	@discardableResult public func `case`(_ condition: @escaping (Type) -> Bool,  handler: (() -> Result?)? = nil) -> When<Type, Result> {
		cases.append(handler)
		conditions.append(ConditionContainer(param:condition))
		return self
	}
	
	@discardableResult public func `case`(_ condition: @escaping () -> Bool,  handler: (() -> Result?)? = nil) -> When<Type, Result> {
		cases.append(handler)
		conditions.append(ConditionContainer(noParam:condition))
		return self
	}
	
	public func `else`(_ defaultValue: Result?) -> Result? {
		return `default`({defaultValue})
	}
	
	public func `else`(_ defaultBlock: () -> Result?) -> Result? {
		return `default`(defaultBlock)
	}
	
	public func `default`(_ defaultValue: Result?) -> Result? {
		return `default`({defaultValue})
	}
	
	public func `default`(_ defaultBlock: () -> Result?) -> Result? {
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
		return defaultBlock()
	}
}

public extension When where Type == Bool {
	convenience init() {
		self.init(true)
	}
	
	convenience init(_ caseProvider: (Case) -> Void) {
		self.init(true)
		let provider = Case(owner: self)
		caseProvider(provider)
	}
	convenience init(_ simple: WhenOptions, _ caseProvider: ((Any)->Case) -> Void) {
		self.init(true)
		caseProvider(caseReturner())
	}
}

public extension When where Type: Equatable {
	@discardableResult func `case`(_ condition: Type,  handler: (() -> Result?)? = nil) -> When<Type, Result> {
		cases.append(handler)
		conditions.append(ConditionContainer(param:{ what in
			return what == condition
		}))
		return self
	}

	 convenience init(_ simple: WhenOptions,_ what: Type, caseProvider: ((Any)->Case) -> Void) {
		self.init(what)
		caseProvider(caseReturner())
	}
								//(Type) -> Bool
	 func caseReturner() -> (Any) -> Case {
		
		return { value in
			let provider = Case(owner: self)
			//caseProvider(provider)
			
			if let handler = value as? (Type) -> Bool {
				provider.case(handler)
			} else if let handler = value as? () -> Bool {
				let result = handler()
				provider.case({result})
			} else if let validValue = value as? Type {
					provider.case(validValue )
			} else if let validValue = value as? Bool {
				provider.case({validValue})
			} else {
				provider.case({false})
			}
			
			return provider
		}
	}
}

public extension When.Case where Type: Equatable {
	@discardableResult func `case`(_ condition: Type,  handler: (() -> Result?)? = nil) -> When.Case {
		owner.case(condition, handler: handler)
		return self
	}
}

public func when<Type, ResultType> (_ source: Type?, handler: (Type) -> ResultType) -> ResultType? {
	if let validSource = source {
		return handler(validSource)
	}
	
	return nil
}

public func with<Type>(_ source: Type?, handler: (Type) -> Void) {
	if let valiSource = source {
		handler(valiSource)
	}
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

public func =? <Type>(lhs: inout Type?, rhs: Type?) -> Void {
	if rhs == nil {
		return
	}
	lhs = rhs!
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

public func => <Type, Result>(lhs: When<Type, Result>.Case, rhs: Result?) -> Void {
	lhs.add(rhs)
}

public func => <Type, Result>(lhs: When<Type, Result>.Case, rhs: WhenCaseOptions) -> Void {
	switch (rhs) {
	case .skip:
			//do nothing
			break
	}
}

public func => <Type, Result>(lhs: When<Type, Result>.Case, rhs: @escaping () -> Result?) -> Void {
	lhs.addClosure(rhs)
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

public extension Optional {
	@discardableResult func takeWhen(_ handler: (Wrapped) -> Bool) -> Wrapped? {
		switch(self) {
		case .some(let value):
			if handler(value) {
				return value
			}
		case _: return nil
		}
		
		return nil
	}
	
	@discardableResult func `let`<Result>(_ handler: (Wrapped) -> Result?) -> Result? {
		switch(self) {
		case .some(let value):
			return handler(value)
		case _: return nil
		}
	}
	
	@discardableResult func apply(_ handler: (Wrapped) -> Void) -> Wrapped? {
		switch(self) {
		case .some(let value):
			handler(value)
			return self
		case _: return nil
		}
	}
	
	func run(_ handler: (Wrapped) -> Void) {
		switch(self) {
		case .some(let value):
			handler(value)
		case _: return
		}
		
	}
}
