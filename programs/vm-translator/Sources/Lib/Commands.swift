import Foundation

enum Command {
  case push(segment: Segment, index: UInt16)
  case pop(segment: Segment, index: UInt16)
  case unary(_ op: UnaryCommand)
  case binary(_ op: BinaryCommand)
  case comparison(_ op: ComparisonCommand)
  case label(_ string: String)
  case goto(_ string: String)
  case ifGoto(_ string: String)
  case function(name: String, localVarsCount: Int)
  case call(name: String, argsCount: Int)
  case `return`
}

enum Segment: String {
  case argument
  case local
  case `static`
  case constant
  case this
  case that
  case pointer
  case temp
  
  var register: String {
    switch self {
      case .argument: return "ARG"
      case .local: return "LCL"
      case .this: return "THIS"
      case .that: return "THAT"
      default: preconditionFailure()
    }
  }
}

enum UnaryCommand: String {
  case neg, not
  
  var assembly: String {
    switch self {
      case .neg: return "-"
      case .not: return "!"
    }
  }
}

enum BinaryCommand: String {
  case add, sub, and, or
  
  var assembly: String {
    switch self {
      case .add: return "+"
      case .sub: return "-"
      case .and: return "&"
      case .or:  return "|"
    }
  }
}

enum ComparisonCommand: String {
  case eq, gt, lt
  
  var assembly: String {
    switch self {
      case .eq: return "JEQ"
      case .gt: return "JGT"
      case .lt: return "JLT"
    }
  }
}
