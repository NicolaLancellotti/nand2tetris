import Foundation

class SymbolTable {
  private var table = [String: (type: TypeAST, kind: VarKind, index: Int)]()
  
  func startSubroutine() {
    table.removeAll()
  }
  
  func define(name: String, type: TypeAST, kind: VarKind) {
    guard table[name] == nil else { preconditionFailure() }
    table[name] = (type, kind, varCount(kind: kind))
  }
  
  func varCount(kind: VarKind) -> Int {
    table.lazy.filter { $0.value.kind == kind}.count
  }
  
  subscript(name: String) -> (type: TypeAST, kind: VarKind, index: Int)? {
    table[name]
  }
}
