import Foundation

enum Token: Equatable {
  case eof
  case error
  
  // Keywords
  case `class`
  case constructor
  case function
  case method
  case field
  case `static`
  case `var`
  case int
  case char
  case boolean
  case void
  case `true`
  case `false`
  case null
  case this
  case `let`
  case `do`
  case `if`
  case `else`
  case `while`
  case `return`
  
  // Symbols
  case leftBrace    // {
  case rightBrace   // }
  case leftParen    // (
  case rightParen   // }
  case leftBracket  // [
  case rightBracket // ]
  case dot          // .
  case comma        // ,
  case semi         // ;
  case plus         // +
  case minus        // -
  case times        // *
  case div          // /
  case and          // &
  case or           // |
  case lt           // <
  case gt           // >
  case eq           // =
  case not          // ~
  
  // Integers: 0...32767
  case integer(UInt16)
  
  // Strings: a sequence of Unicode characters, not including double quote or newline
  case string(String)
  
  // Identifiers: a sequence of letters, digits, and underscore, not starting
  // with a digit
  case id(String)
  
  var classification: String {
    switch self {
      case .class, .constructor, .function, .method, .field, .static, .var,
          .int, .char, .boolean, .void, .true, .false, .null, .this, .let, .do,
          .if, .else, .while, .return:
        return "keyword"
      case .leftBrace, .rightBrace, .leftParen, .rightParen, .leftBracket,
          .rightBracket, .dot, .comma, .semi, .plus, .minus, .times, .div, .and,
          .or, .lt, .gt, .eq, .not:
        return "symbol"
      case .integer(_):
        return "integerConstant"
      case .string(_):
        return "stringConstant"
      case .id(_):
        return "identifier"
      case .eof:
        return "eof"
      case .error:
        return "error"
    }
  }
  
  var value: String {
    switch self {
      case .class: return "class"
      case .constructor: return "constructor"
      case .function: return "function"
      case .method: return "method"
      case .field: return "field"
      case .static: return "static"
      case .var: return "var"
      case .int: return "int"
      case .char: return "char"
      case .boolean: return "boolean"
      case .void: return "void"
      case .true: return "true"
      case .false: return "false"
      case .null: return "null"
      case .this: return "this"
      case .let: return "let"
      case .do: return "do"
      case .if: return "if"
      case .else: return "else"
      case .while: return "while"
      case .return: return "return"
      case .leftBrace: return "{"
      case .rightBrace: return "}"
      case .leftParen: return "("
      case .rightParen: return ")"
      case .leftBracket: return "["
      case .rightBracket: return "]"
      case .dot: return "."
      case .comma: return ","
      case .semi: return ";"
      case .plus: return "+"
      case .minus: return "-"
      case .times: return "*"
      case .div: return "/"
      case .and: return "&"
      case .or: return "|"
      case .lt: return "<"
      case .gt: return ">"
      case .eq: return "="
      case .not: return "~"
      case .integer(let value): return "\(value)"
      case .string(let value): return value
      case .id(let value): return value
      case .eof: return "eof"
      case .error: return "error"
    }
  }
}
