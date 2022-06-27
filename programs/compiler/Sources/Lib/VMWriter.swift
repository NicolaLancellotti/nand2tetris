import Foundation

class VMWriter {
  internal private(set) var stream = ""
  
  enum Segment: String {
    case argument
    case local
    case `static`
    case constant
    case this
    case that
    case pointer
    case temp
  }
  
  enum Operator {
    case add
    case sub
    case neg
    case eq
    case gt
    case lt
    case and
    case or
    case not
  }
  
  func writePush(segment: Segment, index: Int) {
    """
    push \(segment) \(index)
    
    """.write(to: &stream)
  }
  
  func writePop(segment: Segment, index: Int) {
    """
    pop \(segment) \(index)
    
    """.write(to: &stream)
  }
  
  func writeArithmentic(_ op: Operator) {
    """
    \(op)
    
    """.write(to: &stream)
  }
  
  func writeLabel(_ label: String) {
    """
    label \(label)
    
    """.write(to: &stream)
  }
  
  func writeGoto(_ label: String) {
    """
    goto \(label)
    
    """.write(to: &stream)
  }
  
  func writeIf(_ label: String) {
    """
    if-goto \(label)
    
    """.write(to: &stream)
  }
  
  func writeCall(name: String, nArgs: Int) {
    """
    call \(name) \(nArgs)
    
    """.write(to: &stream)
  }
  
  func writeFunction(name: String, nLocals: Int) {
    """
    function \(name) \(nLocals)
    
    """.write(to: &stream)
  }
  
  func writeReturn() {
    """
    return
    
    """.write(to: &stream)
  }
}
