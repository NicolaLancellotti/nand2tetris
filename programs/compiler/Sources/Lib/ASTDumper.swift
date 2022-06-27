import Foundation
#if os(Linux)
import FoundationXML
#endif

enum ASTDumper {
  
  static func dump(_ ast: ClassAST) -> String {
    let xml: XMLElement = dump(ast)
    return xml.xmlString(options: [.nodePrettyPrint])
  }
  
  private enum Name: String {
    case `class`
    case classVarDec
    case subroutineDec
    case parameterList
    case subroutineBody
    case varDec
    case statements
    case letStatement
    case ifStatement
    case whileStatement
    case doStatement
    case returnStatement
    case expression
    case term
    case subroutineCall
    case expressionList
  }
  
  private static func dumpElem(name: Name, value: String? = nil) -> XMLElement {
    return XMLElement(name: name.rawValue, stringValue: value)
  }
  
  private static func dumpToken(_ toke: Token) -> XMLElement {
    return XMLElement(name: toke.classification, stringValue: toke.value)
  }
  
  private static func dump(_ node: ClassAST) -> XMLElement {
    let e = dumpElem(name: .class)
    e.addChild(dumpToken(.class))
    e.addChild(dumpToken(.id(node.className)))
    e.addChild(dumpToken(.leftBrace))
    for classVarDec in node.classVarDecList {
      e.addChild(dump(classVarDec))
    }
    for subroutineDec in node.subroutineDecList {
      e.addChild(dump(subroutineDec))
    }
    e.addChild(dumpToken(.rightBrace))
    return e
  }
  
  private static func dump(_ node: ClassVarDecAST) -> XMLElement {
    let e = dumpElem(name: .classVarDec)
    switch node.kind {
      case .static: e.addChild(dumpToken(.static))
      case .field: e.addChild(dumpToken(.field))
      default: preconditionFailure()
    }
    e.addChild(dump(node.type))
    for (index, varName) in node.varNameList.enumerated() {
      e.addChild(dumpToken(.id(varName)))
      if index != node.varNameList.count - 1 {
        e.addChild(dumpToken(.comma))
      }
    }
    e.addChild(dumpToken(.semi))
    return e
  }
  
  private static func dump(_ node: TypeAST) -> XMLElement {
    switch node {
      case .int: return dumpToken(.int)
      case .char: return dumpToken(.char)
      case .boolean: return dumpToken(.boolean)
      case .className(let string): return dumpToken(.id(string))
    }
  }
  
  private static func dump(_ node: SubroutineDecAST) -> XMLElement {
    let e = dumpElem(name: .subroutineDec)
    switch node.kind {
      case .constructor: e.addChild(dumpToken(.constructor))
      case .function: e.addChild(dumpToken(.function))
      case .method: e.addChild(dumpToken(.method))
    }
    if let type = node.type {
      e.addChild(dump(type))
    } else {
      e.addChild(dumpToken(.void))
    }
    e.addChild(dumpToken(.id(node.subroutineName)))
    e.addChild(dumpToken(.leftParen))
    e.addChild(dump(node.parameterList))
    e.addChild(dumpToken(.rightParen))
    e.addChild(dump(node.subroutineBody))
    return e
  }
  
  private static func dump(_ node: ParameterListAST) -> XMLElement {
    let e = dumpElem(name: .parameterList)
    if node.list.isEmpty {
      e.addChild(empty())
    }
    for (index, (type, varName)) in node.list.enumerated() {
      e.addChild(dump(type))
      e.addChild(dumpToken(.id(varName)))
      if index != node.list.count - 1 {
        e.addChild(dumpToken(.comma))
      }
    }
    return e
  }
  
  private static func dump(_ node: SubroutineBodyAST) -> XMLElement {
    let e = dumpElem(name: .subroutineBody)
    e.addChild(dumpToken(.leftBrace))
    for varDecl in node.varDecList {
      e.addChild(dump(varDecl))
    }
    e.addChild(dump(node.statements))
    e.addChild(dumpToken(.rightBrace))
    return e
  }
  
  private static func dump(_ node: VarDecAST) -> XMLElement {
    let e = dumpElem(name: .varDec)
    e.addChild(dumpToken(.var))
    e.addChild(dump(node.type))
    for (index, varName) in node.varNameList.enumerated() {
      e.addChild(dumpToken(.id(varName)))
      if index != node.varNameList.count - 1 {
        e.addChild(dumpToken(.comma))
      }
    }
    e.addChild(dumpToken(.semi))
    return e
  }
  
  private static func dump(_ node: StatementAST) -> XMLElement {
    switch node {
      case let s as LetStatementAST: return dump(s)
      case let s as IfStatementAST: return dump(s)
      case let s as WhileStatementAST: return dump(s)
      case let s as DoStatementAST: return dump(s)
      case let s as ReturnStatementAST: return dump(s)
      default: preconditionFailure()
    }
  }
  
  private static func dump(_ node: StatementsAST) -> XMLElement {
    let e = dumpElem(name: .statements)
    if node.list.isEmpty {
      e.addChild(empty())
    }
    for statement in node.list {
      e.addChild(dump(statement))
    }
    return e
  }
  
  private static func dump(_ node: LetStatementAST) -> XMLElement {
    let e = dumpElem(name: .letStatement)
    e.addChild(dumpToken(.let))
    e.addChild(dumpToken(.id(node.varName)))
    if let arrayExpression = node.arrayExpression {
      e.addChild(dumpToken(.leftBracket))
      e.addChild(dump(arrayExpression))
      e.addChild(dumpToken(.rightBracket))
    }
    e.addChild(dumpToken(.eq))
    e.addChild(dump(node.expression))
    e.addChild(dumpToken(.semi))
    return e
  }
  
  private static func dump(_ node: IfStatementAST) -> XMLElement {
    let e = dumpElem(name: .ifStatement)
    e.addChild(dumpToken(.if))
    e.addChild(dumpToken(.leftParen))
    e.addChild(dump(node.expression))
    e.addChild(dumpToken(.rightParen))
    e.addChild(dumpToken(.leftBrace))
    e.addChild(dump(node.thenStatements))
    e.addChild(dumpToken(.rightBrace))
    if let elseStatement = node.elseStatements {
      e.addChild(dumpToken(.else))
      e.addChild(dumpToken(.leftBrace))
      e.addChild(dump(elseStatement))
      e.addChild(dumpToken(.rightBrace))
    }
    return e
  }
  
  private static func dump(_ node: WhileStatementAST) -> XMLElement {
    let e = dumpElem(name: .whileStatement)
    e.addChild(dumpToken(.while))
    e.addChild(dumpToken(.leftParen))
    e.addChild(dump(node.expression))
    e.addChild(dumpToken(.rightParen))
    e.addChild(dumpToken(.leftBrace))
    e.addChild(dump(node.statements))
    e.addChild(dumpToken(.rightBrace))
    return e
  }
  
  private static func dump(_ node: DoStatementAST) -> XMLElement {
    let e = dumpElem(name: .doStatement)
    e.addChild(dumpToken(.do))
    for element in dump(node.subroutineCall) {
      e.addChild(element)
    }
    e.addChild(dumpToken(.semi))
    return e
  }
  
  private static func dump(_ node: ReturnStatementAST) -> XMLElement {
    let e = dumpElem(name: .returnStatement)
    e.addChild(dumpToken(.return))
    if let expression = node.expression {
      e.addChild(dump(expression))
    }
    e.addChild(dumpToken(.semi))
    return e
  }
  
  private static func dump(_ node: ExpressionAST) -> XMLElement {
    let e = dumpElem(name: .expression)
    e.addChild(dump(node.term))
    if let (op, term) = node.other {
      switch op {
        case .plus: e.addChild(dumpToken(.plus))
        case .minus: e.addChild(dumpToken(.minus))
        case .times: e.addChild(dumpToken(.times))
        case .div: e.addChild(dumpToken(.div))
        case .and: e.addChild(dumpToken(.and))
        case .or: e.addChild(dumpToken(.or))
        case .lt: e.addChild(dumpToken(.lt))
        case .gt: e.addChild(dumpToken(.gt))
        case .eq: e.addChild(dumpToken(.eq))
      }
      e.addChild(dump(term))
    }
    return e
  }
  
  private static func dump(_ node: Term) -> XMLElement {
    let e = dumpElem(name: .term)
    switch node {
      case .integer(let value): e.addChild(dumpToken(.integer(value)))
      case .string(let value): e.addChild(dumpToken(.string(value)))
      case .keyword(let value):
        switch value {
          case .true: e.addChild(dumpToken(.true))
          case .false: e.addChild(dumpToken(.false))
          case .null: e.addChild(dumpToken(.null))
          case .this: e.addChild(dumpToken(.this))
        }
      case .varName(let value): e.addChild(dumpToken(.id(value)))
      case .arrayExpression(let varName, let expression):
        e.addChild(dumpToken(.id(varName)))
        e.addChild(dumpToken(.leftBracket))
        e.addChild(dump(expression))
        e.addChild(dumpToken(.rightBracket))
      case .expression(let expression):
        e.addChild(dumpToken(.leftParen))
        e.addChild(dump(expression))
        e.addChild(dumpToken(.rightParen))
      case .unary(let unaryOp, let term):
        switch unaryOp {
          case .minus: e.addChild(dumpToken(.minus))
          case .not: e.addChild(dumpToken(.not))
        }
        e.addChild(dump(term))
      case .subroutineCall(let subroutine):
        for element in dump(subroutine) {
          e.addChild(element)
        }
    }
    return e
  }
  
  private static func dump(_ node: ExpressionListAST) -> XMLElement {
    let e = dumpElem(name: .expressionList)
    if node.list.isEmpty {
      e.addChild(empty())
    }
    for (index, expression) in node.list.enumerated() {
      e.addChild(dump(expression))
      if index != node.list.count - 1 {
        e.addChild(dumpToken(.comma))
      }
    }
    return e
  }
  
  private static func dump(_ node: SubroutineCallAST) -> [XMLElement] {
    var list = [XMLElement]()
    if let classOrVarName = node.classOrVarName {
      list.append(dumpToken(.id(classOrVarName)))
      list.append(dumpToken(.dot))
    }
    list.append(dumpToken(.id(node.subroutineName)))
    list.append(dumpToken(.leftParen))
    list.append(dump(node.expressionList))
    list.append(dumpToken(.rightParen))
    return list
  }
  
  private static func empty() -> XMLElement {
    return XMLElement(kind: .element)
  }
  
}
