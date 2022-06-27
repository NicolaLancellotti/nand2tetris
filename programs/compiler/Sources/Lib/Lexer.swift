import Foundation

class Lexer {
  private let stream: LexerInputStream
  private var token: Token = .eof
  
  init(stream: LexerInputStream) {
    self.stream = stream
    self.token = lexImpl()
  }
  
  func nextToken() -> Token {
    let current = token
    switch current {
      case .eof: break
      default: token = lexImpl()
    }
    return current
  }
  
  private func lexImpl() -> Token {
    var charOptional = stream.next()
    while let c = charOptional {
      if c == " " || c == "\t" || c == "\n" || c == "\r" {
        charOptional = stream.next()
      } else {
        break
      }
    }
    
    guard let char = charOptional else {
      return .eof
    }
    
    switch char {
      case "{" : return .leftBrace
      case "}" : return .rightBrace
      case "(" : return .leftParen
      case ")" : return .rightParen
      case "[" : return .leftBracket
      case "]" : return .rightBracket
      case "." : return .dot
      case "," : return .comma
      case ";" : return .semi
      case "+" : return .plus
      case "-" : return .minus
      case "*" : return .times
      case "/" :
        let c = stream.next()
        if let c = c {
          switch c {
            case "/":
              lexOneLineComment()
              return lexImpl()
            case "*":
              return lexMultiLinesComment() ? lexImpl() : .error
            default:
              stream.retract()
              break
          }
        }
        return .div
      case "&" : return .and
      case "|" : return .or
      case "<" : return .lt
      case ">" : return .gt
      case "=" : return .eq
      case "~" : return .not
      default: break
    }
    
    if char.isNumber && char.isASCII {
      return lexInteger(char)
    }
    
    if char == "\"" {
      return lexString()
    }
    
    guard let lexeme = lexKeywordsOrIdentifier(char) else {
      return .error
    }
    
    switch lexeme {
      case "class": return .class
      case "constructor": return .constructor
      case "function": return .function
      case "method": return .method
      case "field": return .field
      case "static": return .static
      case "var": return .var
      case "int": return .int
      case "char": return .char
      case "boolean": return .boolean
      case "void": return .void
      case "true": return .true
      case "false": return .false
      case "null": return .null
      case "this": return .this
      case "let": return .let
      case "do": return .do
      case "if": return .if
        case "else": return .else
          case "while": return .while
          case "return": return .return
          case let lexeme: return .id(lexeme)
    }
  }
  
  private func lexString() -> Token {
    var lexeme = ""
    var current: Character? = stream.next()
    while let c = current {
      switch c {
        case "\n": return .error
        case  "\"": return .string(lexeme)
        default:
          lexeme.append(c)
          current = stream.next()
      }
    }
    return .error
  }
  
  private func lexKeywordsOrIdentifier(_ char: Character) -> String? {
    var lexeme = String(char)
    var current: Character? = stream.next()
    while let c = current {
      if c.isASCII && (c.isLetter || c.isNumber || c == "_") {
        lexeme.append(c)
        current = stream.next()
      } else {
        break
      }
    }
    
    if current != nil {
      stream.retract()
    }
    
    return lexeme
  }
  
  private func lexInteger(_ char: Character) -> Token {
    var n: UInt16 = 0
    var current: Character? = char
    while let c = current, let asciiValue = c.asciiValue {
      if c.isNumber {
        n = n * 10 + UInt16(asciiValue - 48)
        current = stream.next()
      } else {
        break
      }
    }
    
    if current != nil {
      stream.retract()
    }
    
    return .integer(n)
  }
  
  private func lexOneLineComment() {
    var current = stream.next()
    while let c = current {
      if c == "\n" {
        return
      }
      current = stream.next()
    }
  }
  
  private func lexMultiLinesComment() -> Bool {
    var current = stream.next()
    while let c = current {
      switch c {
        case "*":
          switch stream.next() {
            case "/": return true
            case .none: return false
            default: break
          }
        default: break
      }
      current = stream.next()
    }
    return false
  }
}
