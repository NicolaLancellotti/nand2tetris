import Foundation

class Parser {
  private let lexer: Lexer
  private var token: Token
  
  init(lexer: Lexer)  {
    self.lexer = lexer
    token = lexer.nextToken()
  }
  
  func parse() -> ClassAST {
    return parseClass()
  }
  
  private func parseClass() -> ClassAST {
    consume(.class)
    let className = parseID();
    consume(.leftBrace)
    
    var classVarDecList = [ClassVarDecAST]()
    while let decl = tryParseClassVarDec() {
      classVarDecList.append(decl)
    }
    
    var subroutineDecList = [SubroutineDecAST]()
    while let subroutine = tryParseSubroutine() {
      subroutineDecList.append(subroutine)
    }
    
    consume(.rightBrace)
    
    return ClassAST(className: className, classVarDecList: classVarDecList,
                    subroutineDecList: subroutineDecList)
  }
  
  private func tryParseClassVarDec() -> ClassVarDecAST? {
    let kind: VarKind
    switch token {
      case .static: kind = .static
      case .field: kind = .field
      default: return nil
    }
    consume(nil)
    
    let type = parseType()
    
    var varNameList = [String]()
    repeat {
      let varName = parseID()
      varNameList.append(varName)
      if !consumeIf(.comma) {
        break
      }
    } while (true)
    consume(.semi)
    
    return ClassVarDecAST(kind: kind, type: type, varNameList: varNameList)
  }
  
  private func tryParseSubroutine() -> SubroutineDecAST? {
    let kind: SubroutineDecAST.Kind
    switch token {
      case .constructor:
        kind = .constructor
      case .function:
        kind = .function
      case .method:
        kind = .method
      default: return nil
    }
    consume(nil)
    
    let type = token == .void ? nil : parseType()
    if type == nil { consume(nil) }
    let subroutineName = parseID()
    let parameterList = ParameterListAST(list: parseParameterList())
    let subroutineBody = parseSubroutineBody()
    
    return SubroutineDecAST(kind: kind, type: type, subroutineName: subroutineName, parameterList: parameterList, subroutineBody: subroutineBody)
  }
  
  private func parseParameterList() -> [(type: TypeAST, varName: String)] {
    var list = [(type: TypeAST, varName: String)]()
    consume(.leftParen)
    while token != .rightParen {
      let type = parseType()
      let varName = parseID()
      list.append((type, varName))
      if !consumeIf(.comma) {
        break
      }
    }
    consume(.rightParen)
    return list
  }
  
  private func parseSubroutineBody() -> SubroutineBodyAST {
    consume(.leftBrace)
    var varDecList = [VarDecAST]()
    while let varDecl = parseVarDec() {
      varDecList.append(varDecl)
    }
    let statementList = parseStatements()
    consume(.rightBrace)
    return SubroutineBodyAST(varDecList: varDecList, statemens: StatementsAST(list: statementList))
  }
  
  private func parseVarDec() -> VarDecAST? {
    guard consumeIf(.var) else { return nil }
    
    let type = parseType()
    
    var varNameList = [String]()
    repeat {
      let varName = parseID()
      varNameList.append(varName)
      if !consumeIf(.comma) {
        break
      }
    } while (true)
    consume(.semi)
    
    return VarDecAST(type: type, varNameList: varNameList)
  }
  
  private func parseStatements() -> [StatementAST] {
    var list = [StatementAST]()
    
  L: while true {
    let statement: StatementAST
    switch token {
      case .let: statement = parseLet()
      case .if: statement = parseIf()
      case .while: statement = parseWhile()
      case .do: statement = parseDo()
      case .return: statement = parseReturn()
      default: break L
    }
    list.append(statement)
  }
    
    return list
  }
  
  private func parseLet() -> LetStatementAST {
    consume(.let)
    let varName = parseID()
    
    let arrayExpression: ExpressionAST?
    if consumeIf(.leftBracket) {
      arrayExpression = parseExpression()
      consume(.rightBracket)
    } else {
      arrayExpression = nil
    }
    
    consume(.eq)
    
    let expression = parseExpression()
    consume(.semi)
    
    return LetStatementAST(varName: varName, arrayExpression: arrayExpression, expression: expression)
  }
  
  private func parseIf() -> IfStatementAST {
    consume(.if)
    consume(.leftParen)
    let expression = parseExpression()
    consume(.rightParen)
    
    consume(.leftBrace)
    let thenStatements = StatementsAST(list: parseStatements())
    consume(.rightBrace)
    
    let elseStatements: StatementsAST?
    if consumeIf(.else) {
      consume(.leftBrace)
      elseStatements = StatementsAST(list: parseStatements())
      consume(.rightBrace)
    } else {
      elseStatements = nil
    }
    
    return IfStatementAST(expression: expression, thenStatements:thenStatements , elseStatements: elseStatements)
  }
  
  private func parseWhile() -> WhileStatementAST {
    consume(.while)
    consume(.leftParen)
    let expression = parseExpression()
    consume(.rightParen)
    
    consume(.leftBrace)
    let statements = StatementsAST(list: parseStatements())
    consume(.rightBrace)
    
    return WhileStatementAST(expression: expression, statements: statements)
  }
  
  private func parseDo() -> DoStatementAST {
    consume(.do)
    let id = parseID()
    let subroutineCall = parseSubroutineCall(id: id)
    consume(.semi)
    return DoStatementAST(subroutineCall: subroutineCall)
  }
  
  private func parseReturn() -> ReturnStatementAST {
    consume(.return)
    if consumeIf(.semi) {
      return ReturnStatementAST(expression: nil)
    }
    let expression = parseExpression()
    consume(.semi)
    return ReturnStatementAST(expression: expression)
  }
  
  private func parseExpression() -> ExpressionAST {
    let term = parseTerm()
    if let op = tryParseOp() {
      let rhs = parseTerm()
      return ExpressionAST(term: term, other: (op, rhs))
    }
    return ExpressionAST(term: term, other: nil)
  }
  
  private func parseTerm() -> Term {
    switch token {
      case .integer(let value):
        consume(nil)
        return .integer(value)
      case .string(let value):
        consume(nil)
        return .string(value)
      case .true:
        consume(nil)
        return .keyword(.true)
      case .false:
        consume(nil)
        return .keyword(.false)
      case .null:
        consume(nil)
        return .keyword(.null)
      case .this:
        consume(nil)
        return .keyword(.this)
      case .id(let varName):
        consume(nil)
        switch token {
          case .leftBracket:
            consume(nil)
            let expression = parseExpression()
            consume(.rightBracket)
            return .arrayExpression(varName: varName, expression: expression)
          case .dot, .leftParen:
            let subroutineCall = parseSubroutineCall(id: varName)
            return .subroutineCall(subroutineCall)
          default:
            return .varName(varName)
        }
      case .leftParen:
        consume(nil)
        let expression = parseExpression()
        consume(.rightParen)
        return .expression(expression)
      case .minus:
        consume(nil)
        let term = parseTerm()
        return .unary(.minus, term)
      case .not:
        consume(nil)
        let term = parseTerm()
        return .unary(.not, term)
      default: preconditionFailure()
    }
  }
  
  private func parseSubroutineCall(id: String) -> SubroutineCallAST {
    func parseExpressionList() -> [ExpressionAST] {
      var expressionList = [ExpressionAST]()
      while token != .rightParen {
        let expression = parseExpression()
        expressionList.append(expression)
        if !consumeIf(.comma) {
          break
        }
      }
      consume(.rightParen)
      return expressionList
    }
    
    if consumeIf(.leftParen) {
      let subroutineName = id
      let expressionList = ExpressionListAST(list: parseExpressionList())
      return SubroutineCallAST(classOrVarName: nil, subroutineName: subroutineName, expressionList: expressionList)
    } else {
      let classOrVarName = id
      consume(.dot)
      let subroutineName = parseID()
      consume(.leftParen)
      let expressionList = ExpressionListAST(list: parseExpressionList())
      return SubroutineCallAST(classOrVarName: classOrVarName, subroutineName: subroutineName, expressionList: expressionList)
    }
  }
  
  private func parseID() -> String {
    guard case .id(let varName) = token else {
      preconditionFailure()
    }
    consume(nil)
    return varName
  }
  
  private func parseType() -> TypeAST {
    let type: TypeAST
    switch token {
      case .int: type =  .int
      case .char: type =  .char
      case .boolean: type =  .boolean
      case .id(let id): type = .className(id)
      default: preconditionFailure()
    }
    consume(nil)
    return type
  }
  
  private func tryParseOp() -> ExpressionAST.Op? {
    let op: ExpressionAST.Op
    switch token {
      case .plus: op = .plus
      case .minus: op = .minus
      case .times: op = .times
      case .div: op = .div
      case .and: op = .and
      case .or: op = .or
      case .lt: op = .lt
      case .gt: op = .gt
      case .eq: op = .eq
      default: return nil
    }
    consume(nil)
    return op
  }
  
  private func consume(_ token: Token?) {
    if let token = token {
      precondition(self.token == token)
    }
    self.token = lexer.nextToken()
  }
  
  private func consumeIf(_ token: Token) -> Bool {
    if self.token == token {
      consume(token)
      return true
    }
    return false
  }
}
