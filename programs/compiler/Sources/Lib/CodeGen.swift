import Foundation

class CodeGen {
  private let writer = VMWriter()
  private let classTable = SymbolTable()
  private let suroutineTable = SymbolTable()
  private var className = ""
  private var labelIndex = -1
  
  func compile(_ node: ClassAST) -> String {
    compile(node) as Void
    return writer.stream
  }
  
  private func compile(_ node: ClassAST) {
    className = node.className
    for classVarDec in node.classVarDecList {
      compile(classVarDec)
    }
    for subroutineDec in node.subroutineDecList {
      compile(subroutineDec)
    }
  }
  
  private func compile(_ node: ClassVarDecAST) {
    for varName in node.varNameList {
      classTable.define(name: varName, type: node.type, kind: node.kind)
    }
  }
  
  private func compile(_ node: SubroutineDecAST) {
    suroutineTable.startSubroutine()
    
    let nLocals = node.subroutineBody.varDecList.reduce(0) {
      $0 + $1.varNameList.count
    }
    writer.writeFunction(name: className + "." + node.subroutineName,
                         nLocals: nLocals)
    
    switch node.kind {
      case .constructor:
        let nFields = classTable.varCount(kind: .field)
        writer.writePush(segment: .constant, index: nFields)
        writer.writeCall(name: "Memory.alloc", nArgs: 1)
        writer.writePop(segment: .pointer, index: 0)
        break
      case .method:
        suroutineTable.define(name: "this", type: .className(className),
                              kind: .arg)
        writer.writePush(segment: .argument, index: 0)
        writer.writePop(segment: .pointer, index: 0)
      case .function:
        break
    }
    
    compile(node.parameterList)
    compile(node.subroutineBody)
  }
  
  private func compile(_ node: ParameterListAST) {
    for (type, varName) in node.list {
      suroutineTable.define(name: varName, type: type, kind: .arg)
    }
  }
  
  private func compile(_ node: SubroutineBodyAST) {
    for varDecl in node.varDecList {
      compile(varDecl)
    }
    compile(node.statements)
  }
  
  private func compile(_ node: VarDecAST) {
    let type = node.type
    for varName in node.varNameList {
      suroutineTable.define(name: varName, type: type, kind: .var)
    }
  }
  
  private func compile(_ node: StatementAST) {
    switch node {
      case let s as LetStatementAST: return compile(s)
      case let s as IfStatementAST: return compile(s)
      case let s as WhileStatementAST: return compile(s)
      case let s as DoStatementAST: return compile(s)
      case let s as ReturnStatementAST: return compile(s)
      default: preconditionFailure()
    }
  }
  
  private func compile(_ node: StatementsAST) {
    for statement in node.list {
      compile(statement)
    }
  }
  
  private func compile(_ node: LetStatementAST) {
    let (_, segment, index) = lookup(name: node.varName)!
    switch node.arrayExpression {
      case .none:
        compile(node.expression)
        writer.writePop(segment: segment, index: Int(index))
      case .some(let arrayExpression):
        compile(arrayExpression)
        writer.writePush(segment: segment, index: index)
        writer.writeArithmentic(.add)
        compile(node.expression)
        writer.writePop(segment: .temp, index: 0)
        writer.writePop(segment: .pointer, index: 1)
        writer.writePush(segment: .temp, index: 0)
        writer.writePop(segment: .that, index: 0)
    }
  }
  
  private func makeLabels(_ text1: String, _ text2: String) -> (String, String) {
    labelIndex += 1
    return ("\(text1)\(labelIndex)", "\(text2)\(labelIndex)")
  }
  
  private func compile(_ node: IfStatementAST) {
    let (elseLabel, endLabel) = makeLabels("ELSE", "IF_END")
    compile(node.expression)
    writer.writeArithmentic(.not)
    writer.writeIf(elseLabel)
    compile(node.thenStatements)
    writer.writeGoto(endLabel)
    writer.writeLabel(elseLabel)
    if let elseStatement = node.elseStatements {
      compile(elseStatement)
    }
    writer.writeLabel(endLabel)
  }
  
  private func compile(_ node: WhileStatementAST) {
    let (whileLabel, endLabel) = makeLabels("WHILE", "WHILE_END")
    writer.writeLabel(whileLabel)
    compile(node.expression)
    writer.writeArithmentic(.not)
    writer.writeIf(endLabel)
    compile(node.statements)
    writer.writeGoto(whileLabel)
    writer.writeLabel(endLabel)
  }
  
  private func compile(_ node: DoStatementAST) {
    compile(node.subroutineCall)
    writer.writePop(segment: .temp, index: 0)
  }
  
  private func compile(_ node: ReturnStatementAST) {
    switch node.expression {
      case .none:
        writer.writePush(segment: .constant, index: 0)
      case .some(let expression):
        compile(expression)
    }
    writer.writeReturn()
  }
  
  private func compile(_ node: ExpressionAST) {
    compile(node.term)
    if let (op, term) = node.other {
      compile(term)
      switch op {
        case .plus: writer.writeArithmentic(.add)
        case .minus: writer.writeArithmentic(.sub)
        case .times: writer.writeCall(name: "Math.multiply", nArgs: 2)
        case .div: writer.writeCall(name: "Math.divide", nArgs: 2)
        case .and: writer.writeArithmentic(.and)
        case .or: writer.writeArithmentic(.or)
        case .lt: writer.writeArithmentic(.lt)
        case .gt: writer.writeArithmentic(.gt)
        case .eq: writer.writeArithmentic(.eq)
      }
    }
  }
  
  private func compile(_ node: Term) {
    switch node {
      case .integer(let value):
        writer.writePush(segment: .constant, index: Int(value))
      case .string(let string):
        let ascii = string.compactMap(\.asciiValue)
        writer.writePush(segment: .constant, index: ascii.count)
        writer.writeCall(name: "String.new", nArgs: 1)
        for char in ascii {
          writer.writePush(segment: .constant, index: Int(char))
          writer.writeCall(name: "String.appendChar", nArgs: 2)
        }
      case .keyword(let value):
        switch value {
          case .true:
            writer.writePush(segment: .constant, index: 0)
            writer.writeArithmentic(.not)
          case .false: writer.writePush(segment: .constant, index: 0)
          case .null: writer.writePush(segment: .constant, index: 0)
          case .this: writer.writePush(segment: .pointer, index: 0)
            break
        }
      case .varName(let varName):
        let (_, segment, index) = lookup(name: varName)!
        writer.writePush(segment: segment, index: index)
      case .arrayExpression(let varName, let expression):
        compile(expression)
        let (_, segment, index) = lookup(name: varName)!
        writer.writePush(segment: segment, index: index)
        writer.writeArithmentic(.add)
        writer.writePop(segment: .pointer, index: 1)
        writer.writePush(segment: .that, index: 0)
      case .expression(let expression): compile(expression)
      case .unary(let unaryOp, let term):
        compile(term)
        switch unaryOp {
          case .minus: writer.writeArithmentic(.neg)
          case .not: writer.writeArithmentic(.not)
        }
      case .subroutineCall(let subroutine):
        compile(subroutine)
    }
  }
  
  private func compile(_ node: SubroutineCallAST) {
    var nArgs = node.expressionList.list.count
    let name: String
    
    switch node.classOrVarName {
      case .none:
        // Method
        name = className + "." + node.subroutineName
        writer.writePush(segment: .pointer, index: 0)
        nArgs += 1
      case .some(let classOrVarName):
        switch lookup(name: classOrVarName) {
          case .some((.className(let className), let segment, let index)):
            // Method
            writer.writePush(segment: segment, index: index)
            nArgs += 1
            name = className + "." + node.subroutineName
          case .none:
            // Function or constructor
            let className = classOrVarName
            name = className + "." + node.subroutineName
          default: fatalError()
        }
    }
    compile(node.expressionList)
    writer.writeCall(name: name, nArgs: nArgs)
  }
  
  private func compile(_ node: ExpressionListAST) {
    for expression in node.list {
      compile(expression)
    }
  }
  
  private func lookup(name: String) -> (type: TypeAST, segment: VMWriter.Segment,
                                        index: Int)? {
    guard let (type, kind, index) = suroutineTable[name] ?? classTable[name]
    else {
      return nil
    }
    let segment: VMWriter.Segment
    switch kind {
      case .static: segment = .static
      case .field: segment = .this
      case .arg: segment = .argument
      case .var: segment = .local
    }
    return (type, segment, index)
  }
}
