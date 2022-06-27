import Foundation

// Program structure

class ClassAST {
  let className: String
  let classVarDecList: [ClassVarDecAST]
  let subroutineDecList: [SubroutineDecAST]
  
  init(className: String, classVarDecList: [ClassVarDecAST],
       subroutineDecList: [SubroutineDecAST]) {
    self.className = className
    self.classVarDecList = classVarDecList
    self.subroutineDecList = subroutineDecList
  }
}

enum VarKind {
  case `static`
  case field
  case arg
  case `var`
}

class ClassVarDecAST {
  let kind: VarKind
  let type: TypeAST
  let varNameList: [String]
  
  init(kind: VarKind, type: TypeAST,
       varNameList: [String]) {
    precondition(kind == .static || kind == .field)
    self.kind = kind
    self.type = type
    self.varNameList = varNameList
  }
}

enum TypeAST {
  case int
  case char
  case boolean
  case className(String)
}

class SubroutineDecAST {
  enum Kind {
    case constructor
    case function
    case method
  }
  let kind: Kind
  let type: TypeAST?
  let subroutineName: String
  let parameterList: ParameterListAST
  let subroutineBody: SubroutineBodyAST
  
  init(kind: Kind, type: TypeAST?,
       subroutineName: String, parameterList: ParameterListAST,
       subroutineBody: SubroutineBodyAST) {
    self.kind = kind
    self.type = type
    self.subroutineName = subroutineName
    self.parameterList = parameterList
    self.subroutineBody = subroutineBody
  }
}

class ParameterListAST {
  let list: [(type: TypeAST, varName: String)]
  
  init(list: [(type: TypeAST, varName: String)]) {
    self.list = list
  }
}

class SubroutineBodyAST {
  let varDecList: [VarDecAST]
  let statements: StatementsAST
  
  init(varDecList: [VarDecAST], statemens: StatementsAST) {
    self.varDecList = varDecList
    self.statements = statemens
  }
}

class VarDecAST {
  let type: TypeAST
  let varNameList: [String]
  
  init(type: TypeAST, varNameList: [String]) {
    self.type = type
    self.varNameList = varNameList
  }
}

// Statements

protocol StatementAST {}

class StatementsAST: StatementAST {
  let list: [StatementAST]
  
  init(list: [StatementAST]) {
    self.list = list
  }
}

class LetStatementAST: StatementAST {
  let varName: String
  let arrayExpression: ExpressionAST?
  let expression: ExpressionAST
  
  init(varName: String, arrayExpression: ExpressionAST?,
       expression: ExpressionAST) {
    self.varName = varName
    self.arrayExpression = arrayExpression
    self.expression = expression
  }
}

class IfStatementAST: StatementAST {
  let expression: ExpressionAST
  let thenStatements: StatementsAST
  let elseStatements: StatementsAST?
  
  init(expression: ExpressionAST, thenStatements: StatementsAST,
       elseStatements: StatementsAST?) {
    self.expression = expression
    self.thenStatements = thenStatements
    self.elseStatements = elseStatements
  }
}

class WhileStatementAST: StatementAST {
  let expression: ExpressionAST
  let statements: StatementsAST
  
  init(expression: ExpressionAST, statements: StatementsAST) {
    self.expression = expression
    self.statements = statements
  }
}

class DoStatementAST: StatementAST {
  let subroutineCall: SubroutineCallAST
  
  init(subroutineCall: SubroutineCallAST) {
    self.subroutineCall = subroutineCall
  }
}

class ReturnStatementAST: StatementAST {
  let expression: ExpressionAST?
  
  init(expression: ExpressionAST?) {
    self.expression = expression
  }
}

// Expressions

indirect enum Term  {
  enum UnaryOp {
    case minus
    case not
  }
  
  enum Keyword {
    case `true`
    case `false`
    case null
    case this
  }
  
  case integer(UInt16)
  case string(String)
  case keyword(Keyword)
  case varName(String)
  case arrayExpression(varName: String, expression: ExpressionAST)
  case expression(ExpressionAST)
  case unary(UnaryOp, Term)
  case subroutineCall(SubroutineCallAST)
}

class ExpressionAST {
  enum Op {
    case plus
    case minus
    case times
    case div
    case and
    case or
    case lt
    case gt
    case eq
  }
  
  let term: Term
  let other: (Op, Term)?
  
  init(term: Term, other: (Op, Term)?) {
    self.term = term
    self.other = other
  }
}

class SubroutineCallAST{
  let classOrVarName: String?
  let subroutineName: String
  let expressionList: ExpressionListAST
  
  init(classOrVarName: String?, subroutineName:
       String, expressionList: ExpressionListAST) {
    self.classOrVarName = classOrVarName
    self.subroutineName = subroutineName
    self.expressionList = expressionList
  }
}

class ExpressionListAST {
  let list: [ExpressionAST]
  
  init(list: [ExpressionAST]) {
    self.list = list
  }
}
