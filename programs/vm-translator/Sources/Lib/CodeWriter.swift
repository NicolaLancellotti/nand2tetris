import Foundation

class CodeWriter {
  
  private static let trueValue = "-1"
  private static let falseValue = "0"
  
  private var fileName = ""
  internal private(set) var stream = ""
  
  private var functionName = ""
  private var functionReturnIndex = -1
  private var functionComparisonIndex = -1
  
  // MARK: - Translate Commands
  
  func translate(commands: [Command], to fileName: String) {
    self.fileName = fileName
    for command in commands {
      write_command(command)
    }
  }
  
  private func write_command(_ command: Command) {
    switch command {
      case let .push(segment, index): // RAM[SP++] = D
        writeLocation(segment: segment, index: index, destination: .A)
        if segment != .constant {
          writeSet("D", to: "M")
        }
        push_d()
      case let .pop(segment, index): // D = RAM[--SP]
        writeLocation(segment: segment, index: index, destination: .D)
        writeAt("R13")
        writeSet("M", to: "D")
        pop_d()
        writeAt("R13")
        writeSet("A", to: "M")
        writeSet("M", to: "D")
      case let .binary(op):
        pop_d()
        writeAt("R13")
        writeSet("M", to: "D")
        pop_d()
        writeAt("R13")
        writeSet("D", to: "D \(op.assembly) M")
        push_d()
      case let .comparison(op):
        functionComparisonIndex += 1
        let truelabel =  "\(functionName)$true.\(functionComparisonIndex)"
        let endlabel =  "\(functionName)$end.\(functionComparisonIndex)"
        
        pop_d()
        writeAt("R13")
        writeSet("M", to: "D")
        pop_d()
        writeAt("R13")
        writeSet("D", to: "D - M")
        writeAt(truelabel)
        writeJump(condition: "D", jumpType: op.assembly)
        writeSet("D", to: Self.falseValue)
        writeAt(endlabel)
        writeJump(condition: "0", jumpType: "JMP")
        writeLabel(truelabel)
        writeSet("D", to: Self.trueValue)
        writeLabel(endlabel)
        push_d()
      case let .unary(op: op):
        pop_d()
        writeSet("D", to: "\(op.assembly) D")
        push_d()
      case let .label(label):
        writeLabel(makeGotoLabel(from: label))
      case let .goto(label):
        writeAt(makeGotoLabel(from: label))
        writeJump(condition: "0", jumpType: "JMP")
      case let.ifGoto(label):
        pop_d()
        writeAt(makeGotoLabel(from: label))
        writeJump(condition: "D", jumpType: "JNE")
      case let .function(name, localVarsCount):
        functionName = name
        functionReturnIndex = -1
        functionComparisonIndex = -1
        writeLabel(name)
        if localVarsCount > 0 {
          writeSet("D", to: "0")
        }
        for _ in 0..<localVarsCount {
          push_d()
        }
      case let .call(name, argsCount):
        functionReturnIndex += 1
        let returnLabel = "\(functionName)$ret.\(functionReturnIndex)"
        
        pushValue(returnLabel)
        pushContentOfRAMLocation(.LCL)
        pushContentOfRAMLocation(.ARG)
        pushContentOfRAMLocation(.THIS)
        pushContentOfRAMLocation(.THAT)
        
        // ARG = SP - 5  - narg
        writeAt("SP")
        writeSet("D", to: "M")
        writeAt("5")
        writeSet("D", to: "D - A")
        writeAt("\(argsCount)")
        writeSet("D", to: "D - A")
        writeAt("ARG")
        writeSet("M", to: "D")
        
        // LCL = SP
        writeAt("SP")
        writeSet("D", to: "M")
        writeAt("LCL")
        writeSet("M", to: "D")
        
        // goto name
        writeAt(name);
        writeJump(condition: "0", jumpType: "JMP")
        
        writeLabel(returnLabel)
      case .return:
        // frame(R13) = LCL
        writeAt("LCL")
        writeSet("D", to: "M")
        writeAt("R13")
        writeSet("M", to: "D")
        
        // retAddr(R14) = *(frame - 5)
        writeAt("5")
        writeSet("A", to: "D - A")
        writeSet("D", to: "M")
        writeAt("R14")
        writeSet("M", to: "D")
        
        // *ARG = pop()
        pop_d()
        writeAt("ARG")
        writeSet("A", to: "M")
        writeSet("M", to: "D")
        
        // SP = ARG + 1
        writeSet("D", to: "A + 1")
        writeAt("SP")
        writeSet("M", to: "D")
        
        // THAT = *(frame - 1)
        // THIS = *(frame - 2)
        // ARG = *(frame - 3)
        // LCL = *(frame - 4)
        for loc in ["THAT", "THIS", "ARG", "LCL"] {
          writeAt("R13")
          writeSet("AM", to: "M - 1")
          writeSet("D", to: "M")
          writeAt(loc)
          writeSet("M", to: "D")
        }
        
        // goto retAddr
        writeAt("R14")
        writeSet("A", to: "M")
        writeJump(condition: "0", jumpType: "JMP")
    }
  }
  
  // MARK: - Labels
  
  private func makeGotoLabel(from label: String) -> String {
    "\(functionName)$\(label)"
  }
  
  // MARK: - Stack
  
  private func pop_d() {
    writeAt("SP")
    writeSet("AM", to: "M - 1")
    writeSet("D", to: "M")
  }
  
  private func push_d() {
    writeAt("SP")
    writeSet("AM", to: "M + 1")
    writeSet("A", to: "A - 1")
    writeSet("M", to: "D")
  }
  
  enum RAMLocation: String {
    case LCL, ARG, THIS, THAT
  }
  
  private func pushContentOfRAMLocation(_ location: RAMLocation) {
    writeAt(location.rawValue)
    writeSet("D", to: "M")
    push_d()
  }
  
  private func pushValue(_ value: String) {
    writeAt(value)
    writeSet("D", to: "A")
    push_d()
  }
  
  // MARK: - Location
  
  private enum Destination: String {
    case A
    case D
  }
  
  private func writeLocation(segment: Segment, index: UInt16, destination: Destination) {
    switch segment {
      case .local, .argument, .this, .that:
        writeAt("\(segment.register)")
        writeSet("D", to: "M")
        writeAt("\(index)")
        writeSet("\(destination.rawValue)", to: "D + A")
      case .pointer:
        switch index {
          case 0: writeAt("THIS")
          case 1: writeAt("THAT")
          default: preconditionFailure()
        }
        if destination == .D {
          writeSet("D", to: "A")
        }
      case .temp:
        writeAt("5")
        writeSet("D", to: "A")
        writeAt("\(index)")
        writeSet("\(destination.rawValue)", to: "A + D")
      case .constant:
        writeAt("\(index)")
        writeSet("D", to: "A")
      case .static:
        writeAt("\(fileName).\(index)")
        if destination == .D {
          writeSet("D", to: "A")
        }
    }
  }
  
  // MARK: - Bootstrap
  
  func writeBootstrap() {
    writeAt("256")
    writeSet("D", to: "A")
    writeAt("SP")
    writeSet("M", to: "D")
    write_command(.call(name: "Sys.init", argsCount: 0))
  }
  
  // MARK: - Assembly Generation
  
  private func writeAt(_ text: String) {
    """
    @\(text)
    
    """.write(to: &stream)
  }
  
  private func writeSet(_ lhs: String, to rhs: String) {
    """
    \(lhs) = \(rhs)
    
    """.write(to: &stream)
  }
  
  private func writeLabel(_ label: String) {
    """
    (\(label))
    
    """.write(to: &stream)
  }
  
  private func writeJump(condition: String, jumpType: String) {
    """
    \(condition); \(jumpType)
    
    """.write(to: &stream)
  }
}
